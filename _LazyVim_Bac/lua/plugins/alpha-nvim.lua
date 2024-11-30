return {
  "goolord/alpha-nvim",
  optional = true,
  opts = function(_, dashboard)
    -- dashboard.section.header.val = {
    --   [[                                                                       ]],
    --   [[                                                                       ]],
    --   [[                                                                       ]],
    --   [[                                                                       ]],
    --   [[                                                                     ]],
    --   [[       ████ ██████           █████      ██                     ]],
    --   [[      ███████████             █████                             ]],
    --   [[      █████████ ███████████████████ ███   ███████████   ]],
    --   [[     █████████  ███    █████████████ █████ ██████████████   ]],
    --   [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
    --   [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
    --   [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
    --   [[                                                                       ]],
    --   [[                                                                       ]],
    --   [[                                                                       ]],
    -- }

    dashboard.section.header.val = {
      [[                                                 ]],
      [[                                                 ]],
      [[                                                 ]],
      [[                                                 ]],
      [[ ██████╗  █████╗ ███████╗██╗   ██╗██╗███╗   ███╗ ]],
      [[ ██╔══██╗██╔══██╗╚══███╔╝██║   ██║██║████╗ ████║ ]],
      [[ ██████╔╝███████║  ███╔╝ ██║   ██║██║██╔████╔██║ ]],
      [[ ██╔══██╗██╔══██║ ███╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
      [[ ██║  ██║██║  ██║███████╗ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
      [[ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝  ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
      [[                                                 ]],
      [[                                                 ]],
      [[                                                 ]],
    }

    dashboard.section.header.opts.hl = { {"GreenHLGroup",10,2000 } } 

    local projects_button = dashboard.button("p", " " .. " Projects", ":Telescope projects <CR>")
    projects_button.opts.hl = "AlphaButtons"
    projects_button.opts.hl_shortcut = "AlphaShortcut"

    table.insert(dashboard.section.buttons.val, 4, projects_button)

    local notes_button = dashboard.button("N", " " .. " Notes", ":Neorg <CR>")
    notes_button.opts.hl = "AlphaButtons"
    notes_button.opts.hl_shortcut = "AlphaShortcut"

    table.insert(dashboard.section.buttons.val, 5, notes_button)
  end,
}
