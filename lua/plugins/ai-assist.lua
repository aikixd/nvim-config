local util = require('util')
local config = require('config')

-- Require approval when a tool attempts to read files outside the current working directory
-- Used by: read_file, neovim__read_file, neovim__read_multiple_files
local function path_outside_cwd_approval(tool, _tools)
  -- Resolve and normalize CWD
  local cwd = vim.loop.cwd() or vim.fn.getcwd()
  local cwd_real = vim.loop.fs_realpath(cwd) or cwd
  cwd_real = vim.fs.normalize(cwd_real)

  local function normalize(p)
    if not p or p == '' then return nil end
    local expanded = vim.fn.expand(p) -- expands ~, env vars, etc.
    local abs = expanded
    if not expanded:match('^/') then
      abs = (cwd_real .. '/' .. expanded)
    end
    -- Prefer realpath to resolve symlinks; fall back to normalized absolute path
    local real = vim.loop.fs_realpath(abs) or abs
    return vim.fs.normalize(real)
  end

  local function is_outside_real(real)
    -- Ensure trailing slash for prefix match correctness (avoid prefix collisions)
    local prefix = cwd_real
    if prefix:sub(-1) ~= '/' then prefix = prefix .. '/' end
    -- Allow both exact cwd and any path under it
    return not (real == cwd_real or vim.startswith(real, prefix))
  end

  local function extract_paths(name, args)
    local extractors = {
      read_file = function(a) return { a.filepath } end,
      ["neovim__read_file"] = function(a) return { a.path } end,
      ["neovim__list_directory"] = function(a) return { a.path } end,
      insert_edit_into_file = function(a) return { a.filepath } end,
      create_file = function(a) return { a.filepath } end,
    }
    local ex = extractors[name]
    if ex then return ex(args) end
    if type(args.paths) == 'table' then return args.paths end
    return { args.filepath or args.path }
  end

  local tool_name = tool.name or "<unknown>"
  local args = tool.args or {}
  local raw_paths = extract_paths(tool_name, args)

  local resolved_paths, require_approval = {}, false
  for _, p in ipairs(raw_paths) do
    local real = normalize(p)
    -- Treat empty path for directory listing as the CWD
    if (tool_name == "neovim__list_directory") and (not p or p == "") then
      real = cwd_real
    end
    table.insert(resolved_paths, real) -- keep nils for notification
    if not real or is_outside_real(real) then
      require_approval = true
      break
    end
  end

  -- Notify decision (1-liner, includes tool, resolved path(s), and decision)
  local icon = require_approval and "🔒" or "✅"
  local decision = require_approval and "ask" or "allow"
  local level = require_approval and vim.log.levels.WARN or vim.log.levels.INFO
  local display_paths = {}
  for i, rp in ipairs(resolved_paths) do display_paths[i] = rp or "nil" end
  local msg = string.format("%s %s → %s | %s", icon, tool_name, table.concat(display_paths, ", "), decision)
  vim.notify(msg, level)

  return require_approval
end

return {
  { "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    enabled = true,
    event = "BufReadPost",
    opts = {
      panel = {
      },
      suggestion = {
        auto_trigger = true,
        hide_during_completion = true,
        keymap = {
          accept = false, -- Managed by tab_action in mappings.
          next = "<M-j>",
          prev = "<M-k>",
          dismiss = "<C-e>",
          accept_word = "<M-w>",
          accept_line = "<M-l>",
        },
      },
    },
    config = function (_, opts)
      require("copilot").setup(opts)

      local suggestion = require("copilot.suggestion")

      -- Hide copilot suggestions when the completion menu is open
      -- Taken from: https://github.com/zbirenbaum/copilot.lua#suggestion
      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuOpen",
        callback = function()
          suggestion.dismiss() -- Why have I set this?
          vim.b.copilot_suggestion_hidden = true
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuClose",
        callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
      })
    end,
  },
  { "olimorris/codecompanion.nvim",
    keys = util.map(
      config.mapping.get_filtered('code-companion'),
      util.key_canon_to_lazy
    ),
    enabled = true,
    -- dir = "~/Dev/web/codecompanion.nvim/",
    -- https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
    opts = {
      display = {
        action_palette = {
          provider = "snacks"
        },
        chat = {
          window = {
            position = 'right',
            width = 0.35,
          }
        },
      },
      interactions = {
        chat = {
          adapter = {
            name = "copilot",
            model = "gpt-5"
          },
          tools = {
            opts = {
              wait_timeout = 15 * 60 * 1000, -- 15 mins.
              -- Automatically feed successful / error tool outputs back to the LLM
              -- (Helps iterative exploration without manual resubmission noise)
              auto_submit_success = true,
              auto_submit_errors = true,
              -- Can't load this group here, as mcphub hasn't registered its tools yet.
              -- default_tools = { "perception", "neovim"  },
            },

            -- Require approval if a read resolves outside the cwd
            ["read_file"] = {
              opts = {
                require_approval_before = path_outside_cwd_approval,
              },
            },
            ["cmd_runner"] = {
              opts = {
                require_approval_before = true, -- Keep explicit
              },
            },
            ["insert_edit_into_file"] = {
              opts = {
                requires_approval = { buffer = false, file = true }, -- Explicitly safe
                user_confirmation = true, -- Prompt before moving on
              },
            },
            groups = {
              perception = {
                description = "Read-only workspace + external inspection tools (file/grep/git/web).",
                system_prompt =
                  [[ # Perception Tool Group
- Prefer file_search/grep_search to locate targets before read_file.
- Limit broad grep patterns; refine if result set is too large.
- Use search_web for broad discovery, then fetch_webpage for a specific source URL.
- Tool notes:
  - Reading files
    - read_file: Deterministic, raw file content for a given 0-based range.
    - neovim__read_file: Reads a file via Neovim for a 1-based range. The output is annotated with line numbers.
]];
                tools = {
                  "file_search",
                  "grep_search",
                  "read_file",
                  "get_changed_files",
                  "web_search",
                  "fetch_webpage",
                  -- "neovim__read_multiple_files", 
                  "neovim__list_directory",
                  "neovim__read_file",
                  -- "vectorcode_toolbox",
                  -- "vectorcode_files_ls",
                  -- "vectorcode_files_rm",
                },
                opts = {
                  collapse_tools = true, -- show as single @perception reference
                },
              },
              edits = {
                description = "Editing and code manipulation tools (safe-by-default).",
                system_prompt = [[
- Prefer small, targeted edits and keep changes logically grouped.
- Use insert_edit_into_file for code changes. For multi-file changes, proceed file-by-file with clear intent.
- After making changes, use get_changed_files to summarize diffs before further actions.
- Use cmd_runner for format/lint/test commands only when appropriate. Prefer running tests after applying edits that might affect behavior.
- Do not edit outside the current working directory.
- If uncertain about usage or target symbol locations, use list_code_usages before refactoring.
- Use next_edit_suggestion to navigate to the next edit location when needed.
]],
                tools = {
                  "insert_edit_into_file",
                  "create_file",
                  "cmd_runner",
                  "get_changed_files",
                  "list_code_usages",
                  "next_edit_suggestion",
                },
                opts = {
                  collapse_tools = true,
                },
              },
            },
          },
          opts = {
            system_prompt = function (opts)
              local filepath = vim.fn.stdpath('config') .. '/lua/config/ai/prompts/gpt5.3-codex.md'

              local file = io.open(filepath, "r")
              if not file then
                vim.notify("Error: Could not open file at " .. filepath, vim.log.levels.ERROR)
                return nil
              end

              local content = file:read("*a")
              file:close()

              -- Collect working directory
              local cwd = vim.loop.cwd() or vim.fn.getcwd() or "<UNKNOWN_WORKING_DIR>"

              local entries = vim.tbl_map(function (x) return x:to_string() end, util.fs.list_entries(cwd, 100))
              ---@diagnostic disable-next-line: redefined-local
              local entries = table.concat(entries, ", ")

              local bufs = util.get_user_bufs()

              if entries == "" then entries = "<EMPTY>" end
              if bufs == "" then bufs = "<NONE>" end

              local function esc_repl(s) return (s:gsub("%%", "%%%%")) end

              content = content
                :gsub("<WORKING_DIR>", esc_repl(cwd), 1)
                :gsub("<TOP_LEVEL_DIR_ENTRIES>", esc_repl(entries))
                :gsub("<OPEN_BUFFERS>", esc_repl(bufs))

              return content
            end
          }
        }
      },
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            -- MCP Tools 
            make_tools = true,                    -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
            show_server_tools_in_chat = true,     -- Show individual tools in chat completion (when make_tools=true)
            add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
            show_result_in_chat = true,           -- Show tool results directly in chat buffer
            format_tool = nil,                    -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
            -- MCP Resources
            make_vars = true,                     -- Convert MCP resources to #variables for prompts
            -- MCP Prompts 
            make_slash_commands = true,           -- Add MCP prompts as /slash commands
          },
        },
        history = {
          opts = {
            picker = "snacks"
          }
        },
        vectorcode = {
          ---@type VectorCode.CodeCompanion.ExtensionOpts
          opts = {
          },
        },
      },
      adapters = {
        http = {
          tavily = function()
            return require("codecompanion.adapters").extend("tavily", {
              env = {
                api_key = vim.fn.getenv("TAVILY_API_KEY")
              },
            })
          end,
        }
      }
    },
    config = function (_, opts)
      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeCompanionChatCreated",
        callback = function()
          -- McpHub registers its tools by scheduling during the setup, so we
          -- don't have the mcp tools ready here yet.
          -- Thus, we schedule our addition of the perception group after the current event loop.
          vim.schedule(function()
            ---@diagnostic disable-next-line: undefined-field
            local chat = require("codecompanion").last_chat()
            local cc_config = require("codecompanion.config")

            if chat then
              -- _G.dd(cc_config.interactions.chat.tools)
              vim.notify("Adding codecompanion perception tool group", vim.log.levels.INFO)
              chat.tool_registry:add_group("perception", cc_config.interactions.chat.tools)
            else
              vim.notify("codecompanion chat is empty", vim.log.levels.WARN)
            end
          end)
        end,
      })

      ---@diagnostic disable-next-line: undefined-field
      require("codecompanion").setup(opts)
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
      "ravitemer/codecompanion-history.nvim",
    },
  },
  { "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- dir = "~/Dev/web/mcphub.nvim/",
    build = "npm install -g mcp-hub@latest",  -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup({
        config = vim.fn.stdpath('config') .. '/mcphub/servers.json',
        auto_approve = function(params)
          -- Only handle tool calls
          if params.action ~= "use_mcp_tool" or not params.tool_name then
            return false -- show confirmation
          end

          -- Delegate neovim file/dir reads to path-based approval
          if params.server_name == "neovim" and (
             params.tool_name == "read_file" or
             params.tool_name == "list_directory" or
             params.tool_name == "read_multiple_files"
          ) then
            local fake_tool = {
              name = params.tool_name,
              args = params.arguments or {},
            }
            local requires = path_outside_cwd_approval(fake_tool, nil)
            return not requires -- auto-approve when within cwd
          end

          -- Default: require approval
          return false
        end,
      })
    end
  },
  { "Davidyz/VectorCode",
    version = "*",
    build = "uv tool upgrade vectorcode", -- This helps keeping the CLI up-to-date
    opts = {
      async_backend = "lsp"
    },
    dependencies = { "nvim-lua/plenary.nvim" },
  },
}
