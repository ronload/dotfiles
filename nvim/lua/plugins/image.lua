return {
    "3rd/image.nvim",
    build = false,
    opts = {
        backend = "kitty",
        processor = "magick_cli",
        integrations = {
            markdown = { enabled = false },
            neorg = { enabled = false },
            typst = { enabled = false },
            html = { enabled = false },
            css = { enabled = false },
        },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = nil,
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif" },
        editor_only_render_when_focused = false,
        tmux_show_only_in_active_window = false,
        hijack_file_patterns = {},
    },
}
