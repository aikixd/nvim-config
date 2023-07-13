local util = require('util')
return {
  {
    'nvim-telescope/telescope.nvim', 
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = 
      util.map(
        require('config').get_keys_filtered('telescope'),
	util.key_canon_to_lazy
      ),
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-b>"] = "preview_scrolling_down",
          },
	  n = {
	    ["u"] = "preview_scrolling_up",
	    ["m"] = "preview_scrolling_down",
	  }
        }
      }
    }
  },	
}
