return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter").install({
        "go", "gomod", "gosum",
        "typescript", "tsx", "javascript",
        "python", "rust", "lua",
        "json", "yaml", "html", "css", "markdown",
      })

      local function enable_treesitter(buf)
        if pcall(vim.treesitter.start, buf) then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          enable_treesitter(ev.buf)
        end,
      })

      enable_treesitter(vim.api.nvim_get_current_buf())
    end,
  },
}
