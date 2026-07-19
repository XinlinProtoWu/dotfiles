return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "super-tab",
      -- If you want absolute granular control, you can manually define keys here:
      -- ["<CR>"] = { "fallback" }, -- Enter only creates a newline
      -- ["<Tab>"] = { "select_and_accept", "fallback" },
    },
    completion = {
      documentation = {
        auto_show = false,
      },

      ghost_text = {

        enabled = false,
      },
    },
  },
}
