local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
require('awful.autofocus')

function activate_history_client(previous)
  local clients = {}
  for _, client in ipairs(awful.client.focus.history.list) do
    if not client.hidden then
      table.insert(clients, table.unpack(previous and { 1, client } or { client }))
    end
  end
  clients[gears.table.hasitem(clients, client.focus) % #clients + 1]:jump_to()
end

function bind_alt_tab()
  local count
  local modifier = 'Mod1'
  awful.keygrabber({ export_keybindings = true, keybindings = {
    { { modifier }, 'Tab', function()
      count = count + 1
      activate_history_client()
    end },
    { { modifier, 'Shift' }, 'Tab', function()
      count = count + 1
      activate_history_client(true)
    end },
  }, start_callback = function()
    count = 0
    awful.client.focus.history.disable_tracking()
    awesome.xkb_set_layout_group(0)
  end, stop_callback = function()
    if client.focus then
      awful.client.focus.history.add(client.focus)
    end
    if count > 1 then
      gears.table.map(function(client)
        client:emit_signal('request::activate', 'bind_alt_tab', { raise = true })
      end, gears.table.reverse(awful.client.focus.history.list))
    end
    awful.client.focus.history.enable_tracking()
  end, stop_event = 'release', stop_key = modifier })
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

function create_tag()
  awful.tag({ 0 }, awful.screen.focused(), awful.layout.suit.max)
end

keys = {
  { { 'Control', 'Mod1' }, 'Delete', function() awful.spawn('sudo poweroff') end },
  { { 'Control', 'Mod1' }, 'Tab', function() naughty.destroy_all_notifications() end },
  { { 'Control', 'Mod1' }, 'a', function() run_or_raise('calc', 'x-terminal-emulator -e %q') end },
  { { 'Control', 'Mod1' }, 'b', function() run_or_raise('acpi', 'x-terminal-emulator -title %q -e bash -c \'%s; read -s -n 1\'') end },
  { { 'Control', 'Mod1' }, 'c', function() run_or_raise('chromium', 'pgrep \'^%s\\b\' > /dev/null || exec %q', { class = 'Chromium' }, true) end },
  { { 'Control', 'Mod1' }, 'd', function() run_or_raise('dictionary', 'x-terminal-emulator -e %q') end },
  { { 'Control', 'Mod1' }, 'e', function() run_or_raise('mutt', tmux_command) end },
  { { 'Control', 'Mod1' }, 'f', function() local workarea = awful.screen.focused().workarea run_or_raise('firefox', ('pgrep \'^%%s\\b\' > /dev/null || exec %%q --width=%d --height=%d'):format(workarea.width, workarea.height), { class = 'Firefox' }, true) end },
  { { 'Control', 'Mod1' }, 'g', function() awful.spawn.with_shell('path=~/.urls; [[ -f $path ]] && uniq "$path"{,~} && rm "$path" && exec xargs -r -a "$path"~ -d \'\\n\' x-www-browser') end },
  { { 'Control', 'Mod1' }, 'q', function() run_or_raise('sshuttle', 'x-terminal-emulator -title %q -e bash -c \'%s -r personal -x danil.mobi --dns 0/0 |& grep -v DeprecationWarning\'') end },
  { { 'Control', 'Mod1' }, 'r', function() run_or_raise('launch', 'x-terminal-emulator -e %q') end },
  { { 'Control', 'Mod1' }, 's', function() run_or_raise('sync-all', 'x-terminal-emulator -title %q -e bash -c \'%s || read -s -n 1\'') end },
  { { 'Control', 'Mod1' }, 't', function() run_or_raise('tmux', 'x-terminal-emulator -e %q new-session -A -s %q') end },
  { { 'Control', 'Mod1' }, 'w', function() run_or_raise('notes', tmux_command) end },
  { { 'Control', 'Mod1' }, 'x', function() run_or_raise('calendar', 'x-terminal-emulator -title %q -e bash -c \'calendar; read -s -n 1\'') end },
  { { 'Control', 'Mod1' }, 'z', function() awful.spawn('slock') end },
  { { 'Mod1' }, 'Escape', function() tag = root.tags()[1] tag.selected = not tag.selected end },
  { { 'Mod1' }, 'F4', function() if client.focus then client.focus:kill() end end },
  { {}, 'XF86AudioLowerVolume', function() awful.spawn.with_shell('pactl set-sink-mute 0 no; pactl set-sink-volume 0 -10%; pactl set-source-mute 0 no') end },
  { {}, 'XF86AudioMute', function() awful.spawn.with_shell('pactl set-sink-mute 0 yes; pactl set-source-mute 0 yes') end },
  { {}, 'XF86AudioRaiseVolume', function() awful.spawn.with_shell('pactl set-sink-mute 0 no; pactl set-sink-volume 0 +10%; pactl set-source-mute 0 no') end },
}

function main()
  bind_alt_tab()
  configure_notifications()
  create_tag()
  set_background()
  set_keys()
  set_rules()
end

function raspbian()
  return io.open('/etc/os-release'):read('*all'):find('ID=raspbian') ~= nil
end

rules = {
  { { class = 'XClipboard' }, { hidden = true } },
  { { name = 'Event Tester' }, { floating = true } },
  { { type = 'dialog' }, { callback = function(client) awful.placement.centered(client) end, maximized = raspbian() and true or nil } },
}

function run_or_raise(name, command, rule, shell)
  local client = awful.client.focus.history.get(awful.screen.focused(), 0, function(client)
    return awful.rules.match(client, rule or { name = ('^%s$'):format(name) })
  end)
  if client then
    client:jump_to()
  else
    local formatted_command = command:format(name, name, name, name)
    if shell then
      awful.spawn.with_shell(formatted_command)
    else
      awful.spawn(formatted_command)
    end
  end
end

function set_background()
  gears.wallpaper.set(gears.color())
end

function set_keys()
  root.keys(gears.table.join(table.unpack(gears.table.map(function(key)
    return awful.key(table.unpack(key))
  end, keys))))
end

function set_rules()
  awful.rules.rules = gears.table.join({
    { properties = { focus = awful.client.focus.filter, raise = true, size_hints_honor = false }, rule = {} },
    { properties = { buttons = awful.button({ 'Mod1' }, 1, function(client)
      awful.mouse.client.move(client)
    end) }, rule = { floating = true } },
  }, gears.table.map(function(rule)
    return { properties = rule[2], rule = rule[1] }
  end, rules))
end

tmux_command = 'x-terminal-emulator -title %q -e tmux new-session -Ad -s %q %q \\; set-option status off \\; attach-session -t %q'

main()
