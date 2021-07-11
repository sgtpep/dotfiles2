local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')
require('awful.autofocus')

function bind_alt_tab()
  local count

  function activate_client(previous)
    if not client.focus then
      return
    end

    count = count + 1
    local clients = {}
    for _, client in ipairs(awful.client.focus.history.list) do
      if not client.hidden then
        local arguments = table.unpack(previous and { 1, client } or { client })
        table.insert(clients, arguments)
      end
    end
    local index = gears.table.hasitem(clients, client.focus) % #clients + 1
    clients[index]:jump_to()
  end

  local key = 'Tab'
  local modifier = 'Mod1'
  awful.keygrabber({
    export_keybindings = true,
    keybindings = {
      {
        { modifier },
        key,
        function()
          activate_client()
        end,
      },
      {
        { modifier, 'Shift' },
        key,
        function()
          activate_client(true)
        end,
      },
    },
    stop_event = 'release',
    stop_key = modifier,

    start_callback = function()
      count = 0
      awful.client.focus.history.disable_tracking()
    end,

    stop_callback = function()
      awful.client.focus.history.enable_tracking()
      if client.focus then
        awful.client.focus.history.add(client.focus)
      end
      if count <= 1 then
        return
      end

      local list = gears.table.reverse(awful.client.focus.history.list)
      gears.table.map(function(client)
        client:emit_signal('request::activate', 'bind_alt_tab', { raise = true })
      end, list)
    end,
  })
end

function configure_notifications()
  local size = 600
  beautiful.notification_max_height = size
  beautiful.notification_max_width = size
  naughty.config.defaults.bg = 'Black'
  naughty.config.defaults.border_color = '#ffffff'
  naughty.config.defaults.border_width = 1
  naughty.config.defaults.font = 'monospace 14'
  naughty.config.defaults.icon_size = 0
  naughty.config.defaults.margin = 5
  naughty.config.padding = 0
  naughty.config.spacing = 0
end

keyboard_layout = {
  {
    { 'Esc', 'Escape' },
    { 'F1 ☼', 'F1' },
    { 'F2 ☀', 'F2' },
    { 'F3 🔇', 'F3' },
    { 'F4 🔈', 'F4' },
    { 'F5 🔉', 'F5' },
    { 'F6 📶', 'F6' },
    { 'F7', 'F7' },
    { 'F8', 'F8' },
    { 'F9', 'F9' },
    { 'F10', 'F10' },
    { 'F11', 'F11' },
    { 'F12 ☾', 'F12' },
    { 'Home', 'Home' },
    { 'End', 'End' },
    { 'Ins', 'Insert' },
    { 'Del', 'Delete' },
    { '×', 'hide' },
  },
  {
    { '`~', 49 },
    { '1!', 10 },
    { '2@', 11 },
    { '3#', 12 },
    { '4$', 13 },
    { '5%', 14 },
    { '6^', 15 },
    { '7&', 16 },
    { '8*', 17 },
    { '9(', 18 },
    { '0)', 19 },
    { '-_', 20 },
    { '=+', 21 },
    { 'Bksp', 'BackSpace' },
  },
  {
    { 'Tab', 'Tab' },
    { 'Q Й', 24 },
    { 'W Ц', 25 },
    { 'E У', 26 },
    { 'R К', 27 },
    { 'T Е', 28 },
    { 'Y Н', 29 },
    { 'U Г', 30 },
    { 'I Ш', 31 },
    { 'O Щ', 32 },
    { 'P З', 33 },
    { '[{Х', 34 },
    { ']}Ъ', 35 },
    { '\\|', 51 },
  },
  {
    { 'Lang', 'ISO_Next_Group' },
    { 'A Ф', 38 },
    { 'S Ы', 39 },
    { 'D В', 40 },
    { 'F А', 41 },
    { 'G П', 42 },
    { 'H Р', 43 },
    { 'J О', 44 },
    { 'K Л', 45 },
    { 'L Д', 46 },
    { '; Ж', 47 },
    { '\' Э', 48 },
    { '', 'Return' },
    { 'Enter', 'Return' },
  },
  {
    { 'Shift', 'Shift_L', true },
    { 'Z Я', 52 },
    { 'X Ч', 53 },
    { 'C С', 54 },
    { 'V М', 55 },
    { 'B И', 56 },
    { 'N Т', 57 },
    { 'M Ь', 58 },
    { ', Б', 59 },
    { '. Ю', 60 },
    { '/ .', 61 },
    { 'PgUp', 'Prior' },
    { '↑', 'Up' },
    { 'PgDn', 'Next' },
  },
  {
    { 'Ctrl', 'Control_L', true },
    { 'Win', 'Super_L', true },
    { 'Alt', 'Alt_L', true },
    { '', 'space' },
    { '', 'space' },
    { '', 'space' },
    { '', 'space' },
    { '', 'space' },
    { 'AltGr', 'Mode_switch', true },
    { 'Menu', 'Menu' },
    { 'Ctrl', 'ISO_Level3_Shift', true },
    { '←', 'Left' },
    { '↓', 'Down' },
    { '→', 'Right' },
  },
}

function toggle_keyboard()
  keyboard.visible = not keyboard.visible
  if keyboard_toggle then
    keyboard_toggle.visible = not keyboard_toggle.visible
  end
end

function create_keyboard()
  local groups = {
    Return = {},
    space = {},
  }
  local modifiers = {}

  keyboard = awful.wibar({ height = 200, ontop = true, position = 'bottom', visible = false })
  keyboard:setup(gears.table.join({ layout = wibox.layout.flex.vertical }, gears.table.map(function(keys)
    return gears.table.join({ layout = wibox.layout.flex.horizontal, spacing = -1 }, gears.table.map(function(key)
      local button = wibox.widget({
        widget = wibox.container.background,
        {
          align = 'center',
          markup = type(key[2]) == 'string' and gears.string.xml_escape(key[1]) or string.format('<sup>%s</sup> %s <sub>%s</sub>', gears.string.xml_escape(key[1]:sub(2, 2)), gears.string.xml_escape(key[1]:sub(1, 1)), gears.string.xml_escape(key[1]:sub(3))),
          valign = 'center',
          widget = wibox.widget.textbox,
        },
      })

      button:buttons(awful.button({}, 1, function()
        if key[3] then
          modifiers[key[2]] = not modifiers[key[2]] or nil                                              
        else
          for modifier in pairs(modifiers) do
            root.fake_input('key_press', modifier)
          end

          if key[2] == 'ISO_Next_Group' then
            for _, arguments in ipairs({ { 'key_press', 'Shift_L' }, { 'key_press', 'Shift_R' }, { 'key_release', 'Shift_R' }, { 'key_release', 'Shift_L' } }) do
              root.fake_input(table.unpack(arguments))
            end
          else
            root.fake_input('key_press', key[2])
          end

          for modifier in pairs(modifiers) do
            root.fake_input('key_release', modifier)
            modifiers[modifier] = nil
          end
        end
        for _, button in ipairs(groups[key[2]] or { button }) do
          button.bg, button.fg = 'White', 'Black'
        end
      end, function()
        button:emit_signal('mouse::leave')
      end))

      button:connect_signal('mouse::leave', function()                                                  
        if button.bg and button.fg then
          for _, button in ipairs(groups[key[2]] or { button }) do                                      
            button.bg, button.fg = nil, nil
          end

          if key[2] == 'hide' then
            toggle_keyboard()
          elseif not key[3] then
            root.fake_input('key_release', key[2])
          end
        end
      end)

      if groups[key[2]] then
        table.insert(groups[key[2]], button)
      end

      return button
    end, keys))
  end, keyboard_layout)))

  if keyboard.visible then
    keyboard_toggle = awful.wibar({
      height = 5,
      ontop = true,
      position = 'bottom',
      visible = false,
    })
    local button = awful.button({}, 1, function()
      toggle_keyboard()
    end)
    keyboard_toggle:buttons(button)
  else
    keyboard_toggle = nil
  end
end

function create_tag()
  local screen = awful.screen.focused()
  awful.tag({ 0 }, screen, awful.layout.suit.max)
end

function run_or_raise(name, command, rule, shell)
  local default_rule = { name = ('^%s$'):format(name) }
  function match(client)
    return awful.rules.match(client, rule or default_rule)
  end

  if client.focus and match(client.focus) then
    local iterator = awful.client.iterate(match)
    iterator()
    local client = iterator()
    if client then
      client:jump_to()
    end
    return
  end

  local screen = awful.screen.focused()
  local client = awful.client.focus.history.get(screen, 0, match)
  if client then
    client:jump_to()
    return
  end

  local formatted_command = command:format(name, name, name, name)
  if shell then
    awful.spawn.with_shell(formatted_command)
  else
    awful.spawn(formatted_command, false)
  end
end

function set_keys()
  local groups = gears.string.split(gears.string.split(awesome.xkb_get_group_names():gsub('^[^+]++', ''), ':')[1], '+')
  local terminal_command = 'x-terminal-emulator -title %q -e '
  local xon_command = 'sh -c \'stty -ixon && exec "$@"\' -- %q'
  local terminal_tmux_command = terminal_command .. 'tmux new-session -Ad -s %q ' .. xon_command .. ' \\; set-option status off \\; attach-session -t %q'
  local terminal_xon_command = terminal_command .. xon_command
  local keys = gears.table.join(
    awful.key({ 'Control' }, 'F1', function()
      awful.spawn('parallels-keyboard', false)
    end),
    awful.key({ 'Control' }, 'space', function()
      local group = awesome.xkb_get_layout_group()
      local next_group = (group + 1) % #groups
      awesome.xkb_set_layout_group(next_group)
    end),
    awful.key({ 'Control', 'Mod1' }, 'Tab', function()
      naughty.destroy_all_notifications()
    end),
    awful.key({ 'Control', 'Mod1' }, 'a', function()
      run_or_raise('calc', terminal_xon_command)
    end),
    awful.key({ 'Control', 'Mod1' }, 'b', function()
      run_or_raise('acpi', terminal_command .. 'bash -c \'%s; read -s -n 1\'')
    end),
    awful.key({ 'Control', 'Mod1' }, 'c', function()
      run_or_raise('chromium', 'pgrep \'^%s$\' > /dev/null || exec %q', { class = 'Chromium' }, true)
    end),
    awful.key({ 'Control', 'Mod1' }, 'd', function()
      run_or_raise('sdcv', terminal_xon_command)
    end),
    awful.key({ 'Control', 'Mod1' }, 'e', function()
      local command = terminal_tmux_command:gsub(' exec ', ' while [ "$(stty size)" = 24\\ 80 ]]; do sleep 0.1; done &&%0')
      run_or_raise('mutt', command)
    end),
    awful.key({ 'Control', 'Mod1' }, 'f', function()
      awful.spawn.with_shell('path=~/.urls && [[ -f $path ]] && uniq "$path"{,~} && rm "$path" && exec xargs -r -a "$path"~ -d \'\\n\' x-www-browser')
    end),
    awful.key({ 'Control', 'Mod1' }, 'grave', function()
      toggle_keyboard()
    end),
    awful.key({ 'Control', 'Mod1' }, 'r', function()
      run_or_raise('dmenu_run', '%q -i -fn monospace-14 -nb Black -nf White -sb White -sf Black', { class = 'dmenu' })
    end),
    awful.key({ 'Control', 'Mod1' }, 's', function()
      run_or_raise('code', 'pgrep \'^codium$\' > /dev/null || exec %q', { class = 'VSCodium' }, true)
    end),
    awful.key({ 'Control', 'Mod1' }, 't', function()
      run_or_raise('tmux', terminal_command .. '%q new-session -A -s %q')
    end),
    awful.key({ 'Control', 'Mod1' }, 'w', function()
      run_or_raise('notes', terminal_tmux_command)
    end),
    awful.key({ 'Control', 'Mod1' }, 'x', function()
      run_or_raise('calendar', terminal_command .. 'bash -c \'printf "%%(%%F %%a %%I:%%M %%p)T\n\n" && cal -A 1 && read -s -n 1\'')
    end),
    awful.key({ 'Mod1' }, 'Escape', function()
      local tag = root.tags()[1]
      tag.selected = not tag.selected
    end),
    awful.key({ 'Mod1' }, 'F4', function()
      if client.focus then
        client.focus:kill()
      end
    end),
    awful.key({}, 'XF86AudioLowerVolume', function()
      awful.spawn.with_shell('pactl set-sink-mute 0 no && pactl set-sink-volume 0 -10%')
    end),
    awful.key({}, 'XF86AudioMute', function()
      awful.spawn.with_shell('pactl set-sink-mute 0 toggle')
    end),
    awful.key({}, 'XF86AudioRaiseVolume', function()
      awful.spawn.with_shell('pactl set-sink-mute 0 no && pactl set-sink-volume 0 +10%')
    end)
  )
  root.keys(keys)
end

function set_rules()
  awful.rules.rules = {
    {
      properties = {
        focus = awful.client.focus.filter,
        raise = true,
        size_hints_honor = false,

        callback = function(client)
          client:connect_signal('focus', function()
            awesome.xkb_set_layout_group(0)
          end)
        end,
      },
      rule = {},
    },
    {
      properties = {
        buttons = awful.button({ 'Mod1' }, 1, function(client)
          awful.mouse.client.move(client)
        end),
      },
      rule = { floating = true },
    },
    {
      properties = { floating = true },
      rule = { name = 'Event Tester' },
    },
    {
      properties = {
        border_width = 1,

        callback = function(client)
          awful.placement.centered(client)
        end
      },
      rule = { type = 'dialog' },
    },
  }
end

function main()
  bind_alt_tab()
  configure_notifications()
  create_keyboard()
  create_tag()
  set_keys()
  set_rules()
end

main()
