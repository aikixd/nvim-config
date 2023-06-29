return {
  {
    'nvim-telescope/telescope.nvim', 
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find file" }
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-h>"] = "which_key"
          }
        }
      }
    }
  },	
}
