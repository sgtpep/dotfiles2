local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
require('awful.autofocus')

function activate_previous_client()
  local clients = {}
  for _, client in ipairs(awful.client.focus.history.list) do
    if not client.hidden then
      table.insert(clients, client)
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
      activate_previous_client()
    end },
  }, start_callback = function()
    count = 0
    awful.client.focus.history.disable_tracking()
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

function configure_chromium(client)
  local copy = function(callback, with_title)
    input_shortcut(table.unpack(with_title and {{'Alt_L', 'Shift_L', 'y'}} or {{'Shift_L'}, {'Alt_L', 'y'}}))
    gears.timer.start_new(0.1, callback)
  end
  local ebookify = function(arguments)
    copy(function() run_or_raise(string.format('urxvtcd -title ebookify -e bash -c \'ebookify %s "$(xclip -o -selection clipboard)" || read -s\'', arguments or ''), { name = 'ebookify' }) end)
  end
  client:keys(gears.table.join(table.unpack({
    awful.key({ 'Mod1' }, 'e', nil, function() ebookify() end),
    awful.key({ 'Mod1' }, 'm', nil, function() copy(function() run_or_raise('urxvtcd -title sharing -e bash -c $\'output=$(xclip -o -selection clipboard); exec mutt -e \\\'set noabort_unmodified\\\' -i <(echo "${output##* }") -s "Link: ${output% *}"\'', { name = 'sharing' }, true) end, true) end),
    awful.key({ 'Mod1' }, 'p', nil, function() copy(function() run_or_raise('urxvtcd -title password -e bash -c \': "$(xclip -o -selection clipboard)"; : "${_#*://}"; hostname=${_%%/*}; if [[ -f ~/.password-store/$hostname.gpg ]]; then pass "$hostname"; else pwdhash "$hostname" 2> /dev/null; fi | xclip -selection clipboard; [[ ${PIPESTATUS[0]} != 0 ]] || awesome-client <<< $1\' -- "input_shortcut({\'Alt_L\', \'Tab\'}) require(\'gears\').timer.start_new(0.1, function() input_shortcut({\'Control_L\', \'v\'}) require(\'gears\').timer.start_new(0.1, function() require(\'awful\').spawn.with_shell(\'xclip -selection clipboard <<< \\\'\\\'\') end) end)"', { name = 'password' }) end) end),
    awful.key({ 'Mod1' }, 'v', nil, function() copy(function() run_or_raise('urxvtcd -title mpv -e bash -c \'mpv "$(xclip -o -selection clipboard)" || read -s\'', { class = 'mpv' }) end) end),
    awful.key({ 'Mod1', 'Shift' }, 'e', nil, function() ebookify('-d') end),
  })))
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

function hp_stream()
  return product_name():find('^HP Stream ') ~= nil
end

function input_shortcut(...)
  for _, group in ipairs({...}) do
    for _, key in ipairs(group) do
      root.fake_input('key_press', key)
    end
    for _, key in ipairs(group) do
      root.fake_input('key_release', key)
    end
  end
end

keys = {
  { { 'Control', 'Mod1' }, 'Tab', function() naughty.destroy_all_notifications() end },
  { { 'Control', 'Mod1' }, 'a', function() run_or_raise('urxvtcd -e calc', { name = 'calc' }) end },
  { { 'Control', 'Mod1' }, 'b', function() run_or_raise('urxvtcd -title acpi -e bash -c \'acpi; read -s -n 1\'', { name = 'acpi' }) end },
  { { 'Control', 'Mod1' }, 'c', function() run_or_raise('pgrep -x chromium > /dev/null || exec chromium', { class = 'Chromium' }, true) end },
  { { 'Control', 'Mod1' }, 'd', function() run_or_raise('urxvtcd -e dictionary', { name = 'dictionary' }) end },
  { { 'Control', 'Mod1' }, 'e', function() run_or_raise(tmux_command('mutt'), { name = 'mutt' }) end },
  { { 'Control', 'Mod1' }, 'f', function() run_or_raise(tmux_command('mutt -f =Feeds', 'feeds'), { name = 'feeds' }) end },
  { { 'Control', 'Mod1' }, 'g', function() awful.spawn.with_shell('[[ -f ~/.urls ]] && uniq ~/.urls{,~} && rm ~/.urls && exec xargs -r -a ~/.urls~ -d \'\\n\' x-www-browser') end },
  { { 'Control', 'Mod1' }, 'q', function() run_or_raise('urxvtcd -title sshuttle -e bash -c \'online sshuttle -r personal -x danil.mobi --dns 0/0 |& grep -v DeprecationWarning\'', { name = 'sshuttle' }) end },
  { { 'Control', 'Mod1' }, 'r', function() run_or_raise('urxvtcd -e launch', { name = 'launch' }) end },
  { { 'Control', 'Mod1' }, 's', function() run_or_raise('urxvtcd -title syncing -e bash -c \'online sync-all || read -s\'', { name = 'syncing' }) end },
  { { 'Control', 'Mod1' }, 't', function() run_or_raise('urxvtcd -e tmux new-session -A -s tmux', { name = 'tmux' }) end },
  { { 'Control', 'Mod1' }, 'w', function() run_or_raise(tmux_command('notes'), { name = 'notes' }) end },
  { { 'Control', 'Mod1' }, 'x', function() run_or_raise('urxvtcd -title calendar -e bash -c $\'printf \\\'%(%F %a %R)T\\n\\n\\\'; ncal -Mb -A 1; read -s -n 1\'', { name = 'calendar' }, true) end },
  { { 'Control', 'Mod1' }, 'z', function() awful.spawn('slock') end },
  { { 'Mod1' }, 'Escape', function() tag = root.tags()[1] tag.selected = not tag.selected end },
  { { 'Mod1' }, 'F4', function() if client.focus then client.focus:kill() end end },
  { {}, 'XF86AudioLowerVolume', function() awful.spawn.with_shell(string.format('pactl set-sink-mute 0 no; pactl set-sink-volume 0 -10%%; pactl set-source-mute %d no', hp_stream() and 1 or 0)) end },
  { {}, 'XF86AudioMute', function() awful.spawn.with_shell(string.format('pactl set-sink-mute 0 %s; pactl set-sink-volume 0 %d%%; pactl set-source-mute %d yes', table.unpack(hp_stream() and { 'no', 0, 1 } or { 'yes', 25, 0 }))) end },
  { {}, 'XF86AudioRaiseVolume', function() awful.spawn.with_shell(string.format('pactl set-sink-mute 0 no; pactl set-sink-volume 0 +10%%; pactl set-source-mute %d no', hp_stream() and 1 or 0)) end },
}

function main()
  bind_alt_tab()
  configure_notifications()
  create_tag()
  set_background()
  set_keys()
  set_rules()
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
  { { role = 'GtkFileChooserDialog' }, { maximized_vertical = hp_stream() } },
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
  root.keys(gears.table.join(table.unpack(gears.table.map(function(arguments)
    return awful.key(table.unpack(arguments))
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

function tmux_command(command, title)
  geometry = awful.screen.focused().geometry
  if not title then
    title = command
  end
  return string.format('urxvtcd -g %dx%d -title %s -e tmux new-session -Ad -s %s %s \\; set-option status off \\; attach-session -t %s', geometry.width // 11, geometry.height // 24, title, title, command, title)
end

main()
