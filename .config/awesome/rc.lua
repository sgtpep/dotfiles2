local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
gears.math = require('./math')
gears.table = require('./table')
local naughty = require('naughty')
local wibox = require('wibox')
require('awful.autofocus')

function activate_history_client(offset, focus)
  local client = awful.client.focus.history.list[((gears.table.hasitem(awful.client.focus.history.list, focus or client.focus) or 1) + offset - 1) % #awful.client.focus.history.list + 1]
  if client then
    if client.hidden and not focus then
      activate_history_client(offset, client)
    else
      client:jump_to()
    end
  end
end

function alt_tab(offset)
  local grabber
  local reorder
  grabber = awful.keygrabber.run(function(modifiers, key, event)
    if key == 'Alt_L' and event == 'release' then
      awful.keygrabber.stop(grabber)
      if client.focus then
        awful.client.focus.history.add(client.focus)
      end
      if reorder then
        gears.table.map(function(client)
          client:emit_signal('request::activate', 'alt_tab', { raise = true })
        end, gears.table.reverse(awful.client.focus.history.list))
      end
      awful.client.focus.history.enable_tracking()
    elseif key == 'Tab' and event == 'press' then
      reorder = true
      activate_history_client(offset)
    end
  end)
  awful.client.focus.history.disable_tracking()
  activate_history_client(offset)
end

function configure_chromium(client)
  local copy_command = 'xdotool keyup alt shift key alt+y sleep 0.1'
  local copy_close_command = copy_command .. ' key ctrl+w'
  local keys = {
    awful.key({ 'Mod1' }, 'e', nil, function() run_or_raise(copy_command .. ' && exec x-terminal-emulator -title ebookify -e bash -c \'ebookify "$(xclip -o -selection clipboard)" || read -s\'', { name = 'ebookify' }, true) end),
    awful.key({ 'Mod1' }, 'm', nil, function() run_or_raise(copy_command:gsub(' alt%+y ', ' alt+shift+y ') .. ' && exec x-terminal-emulator -title send-link -e bash -c \'output=$(xclip -o -selection clipboard); mutt -e "set noabort_unmodified" -i <(echo "${output##* }") -s "Link: ${output% *}"\'', { name = 'send-link' }, true) end),
    awful.key({ 'Mod1' }, 'p', nil, function() run_or_raise(copy_command .. ' && exec x-terminal-emulator -title pwdhash -e sh -c \'pwdhash "$(xclip -o -selection clipboard)" | xclip -selection clipboard && sleep 0.1\'', { name = 'pwdhash' }, true) end),
    awful.key({ 'Mod1' }, 'v', nil, function() run_or_raise(copy_close_command .. ' && exec x-terminal-emulator -title mpv -e bash -c \'mpv "$(xclip -o -selection clipboard)" || read -s\'', { class = 'mpv' }, true) end),
    awful.key({ 'Mod1', 'Shift' }, 'p', nil, function() run_or_raise(copy_command .. ' && exec x-terminal-emulator -title pass -e bash -c \'( pass "$(xclip -o -selection clipboard | cut -d / -f 3 | rev | cut -d . -f -2 | rev)" || read -s ) | xclip -selection clipboard && sleep 0.1\'', { name = 'pass' }, true) end),
  }
  client:keys(gears.table.join(unpack(keys)))
end

function configure_notifications()
  naughty.config.defaults.bg = 'Black'
  naughty.config.defaults.border_color = '#ffffff'
  naughty.config.defaults.border_width = 1
  naughty.config.defaults.font = 'monospace 14'
  naughty.config.defaults.icon_size = 0
  naughty.config.defaults.margin = 5
  naughty.config.padding = 0
  naughty.config.spacing = 0
end

function create_keyboard()
  keyboard = awful.wibar({ height = 320, ontop = true, position = 'bottom', visible = io.open('/etc/os-release'):read('*all'):find('ID=raspbian') ~= nil })
  local groups = { Return = {}, space = {} }
  local modifiers = {}
  keyboard:setup(gears.table.join({ layout = wibox.layout.flex.vertical }, gears.table.map(function(keys)
    return gears.table.join({ layout = wibox.layout.flex.horizontal, spacing = -1 }, gears.table.map(function(key)
      local button = wibox.widget({
        widget = wibox.container.background,
        {
          align = 'center',
          markup = type(key[2]) == 'string' and key[1] or string.format('<sup>%s</sup> %s <sub>%s</sub>', key[1]:sub(2, 2), key[1]:sub(1, 1), key[1]:sub(3)),
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
              root.fake_input(unpack(arguments))
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
  end, layout)))
  if keyboard.visible then
    keyboard_toggle = awful.wibar({ height = 5, ontop = true, position = 'bottom', visible = false })
    keyboard_toggle:buttons(awful.button({}, 1, function()
      toggle_keyboard()
    end))
  else
    keyboard_toggle = nil
  end
end

function create_tag()
  awful.tag({ 0 }, awful.screen.focused(), awful.layout.suit.max)
end

keys = {
  { { 'Control', 'Mod1' }, 'Tab', function() naughty.destroy_all_notifications() end },
  { { 'Control', 'Mod1' }, 'a', function() run_or_raise('x-terminal-emulator -e calc', { name = 'calc' }) end },
  { { 'Control', 'Mod1' }, 'b', function() run_or_raise('x-terminal-emulator -title acpi -e bash -c \'acpi; read -s -n 1\'', { name = 'acpi' }) end },
  { { 'Control', 'Mod1' }, 'c', function() run_or_raise('chromium', { class = 'Chromium' }) end },
  { { 'Control', 'Mod1' }, 'd', function() run_or_raise('x-terminal-emulator -e dictionary', { name = 'dictionary' }) end },
  { { 'Control', 'Mod1' }, 'e', function() run_or_raise('x-terminal-emulator -title mutt -e tmux new-session -Ad -s mutt mutt \\; set-option status off \\; attach-session -t mutt', { name = 'mutt' }) end },
  { { 'Control', 'Mod1' }, 'f', function() run_or_raise('x-terminal-emulator -e browse', { name = 'browse' }) end },
  { { 'Control', 'Mod1' }, 'g', function() awful.spawn.with_shell('mv ~/.urls{,~} && exec xargs -r -a ~/.urls~ -d \'\\n\' x-www-browser') end },
  { { 'Control', 'Mod1' }, 'grave', function() toggle_keyboard() end },
  { { 'Control', 'Mod1' }, 'q', function() run_or_raise('x-terminal-emulator -title sshuttle -e execute-online sshuttle -r personal --dns 0/0', { name = 'sshuttle' }) end },
  { { 'Control', 'Mod1' }, 'r', function() run_or_raise('x-terminal-emulator -e launch', { name = 'launch' }) end },
  { { 'Control', 'Mod1' }, 's', function() run_or_raise('x-terminal-emulator -title sync-data -e bash -c \'execute-online sync-data || read -s\'', { name = 'sync-data' }) end },
  { { 'Control', 'Mod1' }, 't', function() run_or_raise('x-terminal-emulator -e tmux new-session -A -s tmux', { name = 'tmux' }) end },
  { { 'Control', 'Mod1' }, 'v', function() run_or_raise('x-terminal-emulator -title cal -e bash -c \'ncal -Mb -A 1; read -s -n 1\'', { name = 'cal' }) end },
  { { 'Control', 'Mod1' }, 'w', function() run_or_raise('x-terminal-emulator -title notes -e tmux new-session -Ad -s notes notes \\; set-option status off \\; attach-session -t notes', { name = 'notes' }) end },
  { { 'Control', 'Mod1' }, 'z', function() awful.spawn('slock') end },
  { { 'Mod1' }, 'Escape', function() tag = root.tags()[1] tag.selected = not tag.selected end },
  { { 'Mod1' }, 'F4', function() if client.focus then client.focus:kill() end end },
  { { 'Mod1' }, 'Tab', function() alt_tab(1) end },
  { { 'Mod1', 'Shift' }, 'Tab', function() alt_tab(-1) end },
  { { 'Shift' }, 'XF86WLAN', function() run_or_raise('x-terminal-emulator -e toggle-wifi block', { name = 'toggle-wifi' }) end },
  { {}, 'XF86AudioLowerVolume', function() awful.spawn.with_shell('pactl set-sink-mute 0 no; pactl set-sink-volume 0 -10%; pactl set-source-mute 1 no') end },
  { {}, 'XF86AudioMute', function() awful.spawn.with_shell('pactl set-sink-mute 0 no; pactl set-sink-volume 0 0%; pactl set-source-mute 1 yes; pactl set-source-volume 1 25%') end },
  { {}, 'XF86AudioRaiseVolume', function() awful.spawn.with_shell('pactl set-sink-mute 0 no; pactl set-sink-volume 0 +10%; pactl set-source-mute 1 no') end },
  { {}, 'XF86WLAN', function() run_or_raise('x-terminal-emulator -e toggle-wifi unblock', { name = 'toggle-wifi' }) end },
}

layout = {
  { { 'Esc', 'Escape' }, { 'F1', 'F1' }, { 'F2', 'F2' }, { 'F3', 'F3' }, { 'F4', 'F4' }, { 'F5', 'F5' }, { 'F6', 'F6' }, { 'F7', 'F7' }, { 'F8', 'F8' }, { 'F9', 'F9' }, { 'F10', 'F10' }, { 'F11', 'F11' }, { 'F12', 'F12' }, { 'Home', 'Home' }, { 'End', 'End' }, { 'Ins', 'Insert' }, { 'Del', 'Delete' }, { '×', 'hide' } },
  { { '`~', 49 }, { '1!', 10 }, { '2@', 11 }, { '3#', 12 }, { '4$', 13 }, { '5%', 14 }, { '6^', 15 }, { '7&', 16 }, { '8*', 17 }, { '9(', 18 }, { '0)', 19 }, { '-_', 20 }, { '=+', 21 }, { 'Bksp', 'BackSpace' } },
  { { 'Tab', 'Tab' }, { 'Q Й', 24 }, { 'W Ц', 25 }, { 'E У', 26 }, { 'R К', 27 }, { 'T Е', 28 }, { 'Y Н', 29 }, { 'U Г', 30 }, { 'I Ш', 31 }, { 'O Щ', 32 }, { 'P З', 33 }, { '[{Х', 34 }, { ']}Ъ', 35 }, { '\\|', 51 } },
  { { 'Lang', 'ISO_Next_Group' }, { 'A Ф', 38 }, { 'S Ы', 39 }, { 'D В', 40 }, { 'F А', 41 }, { 'G П', 42 }, { 'H Р', 43 }, { 'J О', 44 }, { 'K Л', 45 }, { 'L Д', 46 }, { '; Ж', 47 }, { '\' Э', 48 }, { '', 'Return' }, { 'Enter', 'Return' } },
  { { 'Shift', 'Shift_L', true }, { 'Z Я', 52 }, { 'X Ч', 53 }, { 'C С', 54 }, { 'V М', 55 }, { 'B И', 56 }, { 'N Т', 57 }, { 'M Ь', 58 }, { ', Б', 59 }, { '. Ю', 60 }, { '/ .', 61 }, { 'PgUp', 'Prior' }, { '↑', 'Up' }, { 'PgDn', 'Next' } },
  { { 'Ctrl', 'Control_L', true }, { 'Win', 'Super_L', true }, { 'Alt', 'Alt_L', true }, { '', 'space' }, { '', 'space' }, { '', 'space' }, { '', 'space' }, { '', 'space' }, { 'AltGr', 'Mode_switch', true }, { 'Menu', 'Menu' }, { 'Ctrl', 'ISO_Level3_Shift', true }, { '←', 'Left' }, { '↓', 'Down' }, { '→', 'Right' } },
}

function main()
  configure_notifications()
  create_keyboard()
  create_tag()
  set_background()
  set_keys()
  set_rules()
end

naughty.destroy_all_notifications = function()
  for _, positions in pairs(naughty.notifications) do
    for _, notifications in pairs(positions) do
      while #notifications > 0 do
        naughty.destroy(notifications[1])
      end
    end
  end
end

rules = {
  { { class = 'Chromium', type = 'normal' }, { callback = function(client) configure_chromium(client) end } },
  { { class = 'XClipboard' }, { hidden = true } },
  { { name = 'Event Tester' }, { floating = true } },
  { { type = 'dialog' }, { callback = function(client) awful.placement.centered(client) end } },
}

function run_or_raise(command, rule, shell)
  local clients = client.get()
  local client = awful.client.iterate(function(client)
    return awful.rules.match(client, rule)
  end, gears.math.cycle(#clients, (gears.table.hasitem(clients, client.focus) or 1) + 1))()
  if client then
    client:jump_to()
  elseif shell then
    awful.spawn.with_shell(command)
  else
    awful.spawn(command)
  end
end

function set_background()
  gears.wallpaper.set(gears.color())
end

function set_keys()
  root.keys(gears.table.join(unpack(gears.table.map(function(arguments)
    return awful.key(unpack(arguments))
  end, gears.table.join(keys, gears.table.map(function(key)
    return #key[1] == 2 and gears.table.hasitem(key[1], 'Control') and gears.table.hasitem(key[1], 'Mod1') and { { 'Mod4' },  key[2], key[3] } or nil
  end, keys))))))
end

function set_rules()
  awful.rules.rules = gears.table.join({
    { properties = { callback = function(client)
      client:connect_signal('request::geometry', function(client)
        if client.fullscreen then
          client.fullscreen = false
        end
      end)
    end, focus = awful.client.focus.filter, raise = true, size_hints_honor = false }, rule = {} },
    { properties = { buttons = awful.button({ 'Mod1' }, 1, function(client)
      awful.mouse.client.move(client)
    end) }, rule = { floating = true } },
  }, gears.table.map(function(rule)
    return { properties = rule[2], rule = rule[1] }
  end, rules))
end

function toggle_keyboard()
  keyboard.visible = not keyboard.visible
  if keyboard_toggle then
    keyboard_toggle.visible = not keyboard_toggle.visible
  end
end

main()
