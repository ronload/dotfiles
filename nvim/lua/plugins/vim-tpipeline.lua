return {
    "vimpostor/vim-tpipeline",
    -- lazy.nvim sets loadplugins=false and loads "start" plugins outside the
    -- normal startup sequence, which breaks tpipeline's lualine integration
    -- (statusline not embedded on first launch, or a duplicate native bar). The
    -- plugin author's fix is to load it on VeryLazy so the sequence is intact.
    -- https://github.com/vimpostor/vim-tpipeline/issues/67
    event = "VeryLazy",
    init = function()
        -- Embed the bridge once from tmux.conf instead of re-running `tmux set`
        -- on every nvim launch (see tmux/appearance.conf).
        vim.g.tpipeline_autoembed = 0
        -- Keep the bridge file on FocusLost so returning to a session/pane shows
        -- the statusline again without depending on a FocusGained event.
        vim.g.tpipeline_focuslost = 1
    end,
}
