return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
      },
    })

    local select_textobject = function(query)
      return function()
        require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
      end
    end

    vim.keymap.set({ "x", "o" }, "af", select_textobject("@function.outer"), { desc = "Select outer function" })
    vim.keymap.set({ "x", "o" }, "if", select_textobject("@function.inner"), { desc = "Select inner function" })
    vim.keymap.set({ "x", "o" }, "ac", select_textobject("@class.outer"), { desc = "Select outer class" })
    vim.keymap.set({ "x", "o" }, "ic", select_textobject("@class.inner"), { desc = "Select inner class" })
  end,
}
