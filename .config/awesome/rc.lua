local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
gears.math = require('./math')
gears.string = require('./string')
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

function change_volume(change)
  local source = product_name():find('^HP Stream ') and 1 or 0
  awful.spawn.with_shell(change < 0 and string.format('pactl set-sink-mute 0 no; pactl set-sink-volume 0 -10%%; pactl set-source-mute %d no', source) or change > 0 and string.format('pactl set-sink-mute 0 no; pactl set-sink-volume 0 +10%%; pactl set-source-mute %d no', source) or string.format('pactl set-sink-mute 0 %s; pactl set-sink-volume 0 %d%%; pactl set-source-mute %d yes', unpack(product_name():find('^HP Stream ') and { 'no', 0, source } or { 'yes', 25, source })))
end

function configure_chromium(client)
  local copy_command = 'xdotool keyup alt shift key alt+y sleep 0.1'
  local copy_close_command = string.format('%s key ctrl+w', copy_command)
  local copy_paste_command = 'xclip -selection clipboard && xdotool key --delay=300 alt+Tab key ctrl+v'
  client:keys(gears.table.join(unpack({
    awful.key({ 'Mod1' }, 'e', nil, function() run_or_raise(string.format('%s && exec x-terminal-emulator -title ebookify -e bash -c \'ebookify "$(xclip -o -selection clipboard)" || read -s\'', copy_command), { name = 'ebookify' }, true) end),
    awful.key({ 'Mod1' }, 'm', nil, function() run_or_raise(string.format('%s && exec x-terminal-emulator -title sending -e bash -c \'output=$(xclip -o -selection clipboard); mutt -e "set noabort_unmodified" -i <(echo "${output##* }") -s "Link: ${output%% *}"\'', copy_command:gsub(' alt%+y ', ' alt+shift+y ')), { name = 'sending' }, true) end),
    awful.key({ 'Mod1' }, 'p', nil, function() run_or_raise(string.format('%s && exec x-terminal-emulator -title pwdhash -e bash -c \'output=$(xclip -o -selection clipboard); hostname=${output#*://}; pwdhash "${hostname%%%%/*}" 2> /dev/null | %s\'', copy_command, copy_paste_command), { name = 'pwdhash' }, true) end),
    awful.key({ 'Mod1' }, 'v', nil, function() run_or_raise(string.format('%s && exec x-terminal-emulator -title mpv -e bash -c \'mpv "$(xclip -o -selection clipboard)" || read -s\'', copy_close_command), { class = 'mpv' }, true) end),
    awful.key({ 'Mod1', 'Shift' }, 'p', nil, function() run_or_raise(string.format('%s && exec x-terminal-emulator -title pass -e bash -c \'output=$(xclip -o -selection clipboard); hostname=${output#*://}; (pass "${hostname%%%%/*}" || read -s) | %s\'', copy_command, copy_paste_command), { name = 'pass' }, true) end),
  })))
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
  keyboard = awful.wibar({ height = 200, ontop = true, position = 'bottom', visible = io.open('/etc/os-release'):read('*all'):find('ID=raspbian') ~= nil })
  local groups = { Return = {}, space = {} }
  local modifiers = {}
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

function format_geometry(string)
  geometry = awful.screen.focused().geometry
  return string.format(string, geometry.width / 11, geometry.height / 24)
end

keys = {
  { { 'Control', 'Mod1' }, 'F1', function() awful.spawn('sudo /etc/acpi/default.sh video/brightnessdown') end },
  { { 'Control', 'Mod1' }, 'F12', function() awful.spawn('sudo poweroff') end },
  { { 'Control', 'Mod1' }, 'F2', function() awful.spawn('sudo /etc/acpi/default.sh video/brightnessup') end },
  { { 'Control', 'Mod1' }, 'F3', function() change_volume(0) end },
  { { 'Control', 'Mod1' }, 'F4', function() change_volume(-1) end },
  { { 'Control', 'Mod1' }, 'F5', function() change_volume(1) end },
  { { 'Control', 'Mod1' }, 'F6', function() toggle_wifi('unblock') end },
  { { 'Control', 'Mod1' }, 'Tab', function() naughty.destroy_all_notifications() end },
  { { 'Control', 'Mod1' }, 'a', function() run_or_raise('x-terminal-emulator -e calc', { name = 'calc' }) end },
  { { 'Control', 'Mod1' }, 'b', function() run_or_raise('x-terminal-emulator -title acpi -e bash -c \'acpi; read -s -n 1\'', { name = 'acpi' }) end },
  { { 'Control', 'Mod1' }, 'c', function() run_or_raise('pgrep -x chromium || chromium', { class = 'Chromium' }, true) end },
  { { 'Control', 'Mod1' }, 'd', function() run_or_raise('x-terminal-emulator -e dictionary', { name = 'dictionary' }) end },
  { { 'Control', 'Mod1' }, 'e', function() run_or_raise(format_geometry('x-terminal-emulator -g %dx%d -title mutt -e tmux new-session -Ad -s mutt mutt \\; set-option status off \\; attach-session -t mutt'), { name = 'mutt' }) end },
  { { 'Control', 'Mod1' }, 'f', function() awful.spawn.with_shell('mv ~/.urls{,~} && exec xargs -r -a ~/.urls~ -d \'\\n\' x-www-browser') end },
  { { 'Control', 'Mod1' }, 'grave', function() toggle_keyboard() end },
  { { 'Control', 'Mod1' }, 'q', function() run_or_raise('x-terminal-emulator -title sshuttle -e execute-online bash -c \'while :; do sshuttle -r personal --dns 0/0; [[ $? != 1 ]] || break; sleep 1; done\'', { name = 'sshuttle' }) end },
  { { 'Control', 'Mod1' }, 'r', function() run_or_raise('x-terminal-emulator -e launch', { name = 'launch' }) end },
  { { 'Control', 'Mod1' }, 's', function() run_or_raise('x-terminal-emulator -title syncing -e bash -c \'execute-online sync-all || read -s\'', { name = 'syncing' }) end },
  { { 'Control', 'Mod1' }, 't', function() run_or_raise('x-terminal-emulator -e tmux new-session -A -s tmux', { name = 'tmux' }) end },
  { { 'Control', 'Mod1' }, 'w', function() run_or_raise(format_geometry('x-terminal-emulator -g %dx%d -title notes -e tmux new-session -Ad -s notes notes \\; set-option status off \\; attach-session -t notes'), { name = 'notes' }) end },
  { { 'Control', 'Mod1' }, 'x', function() run_or_raise('x-terminal-emulator -title calendar -e bash -c \'date +%F\\ %a\\ %R; echo; ncal -Mb -A 1; read -s -n 1\'', { name = 'calendar' }) end },
  { { 'Control', 'Mod1' }, 'z', function() awful.spawn('slock') end },
  { { 'Control', 'Mod1', 'Shift' }, 'F6', function() toggle_wifi('block') end },
  { { 'Mod1' }, 'Escape', function() tag = root.tags()[1] tag.selected = not tag.selected end },
  { { 'Mod1' }, 'F4', function() if client.focus then client.focus:kill() end end },
  { { 'Mod1' }, 'Tab', function() alt_tab(1) end },
  { { 'Mod1', 'Shift' }, 'Tab', function() alt_tab(-1) end },
  { { 'Shift' }, 'XF86WLAN', function() toggle_wifi('block') end },
  { {}, 'XF86AudioLowerVolume', function() change_volume(-1) end },
  { {}, 'XF86AudioMute', function() change_volume(0) end },
  { {}, 'XF86AudioRaiseVolume', function() change_volume(1) end },
  { {}, 'XF86WLAN', function() toggle_wifi('unblock') end },
}

layout = {
  { { 'Esc', 'Escape' }, { 'F1 ☼', 'F1' }, { 'F2 ☀', 'F2' }, { 'F3 🔇', 'F3' }, { 'F4 🔈', 'F4' }, { 'F5 🔉', 'F5' }, { 'F6 📶', 'F6' }, { 'F7', 'F7' }, { 'F8', 'F8' }, { 'F9', 'F9' }, { 'F10', 'F10' }, { 'F11', 'F11' }, { 'F12 ☾', 'F12' }, { 'Home', 'Home' }, { 'End', 'End' }, { 'Ins', 'Insert' }, { 'Del', 'Delete' }, { '×', 'hide' } },
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

function product_name()
  if not _product_name then
    local file = io.open('/sys/class/dmi/id/product_name')
    _product_name = file and file:read('*all') or ''
  end
  return _product_name
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

function toggle_wifi(command)
  run_or_raise(string.format('x-terminal-emulator -e toggle-wifi %s', command), { name = 'toggle-wifi' })
end

main()
