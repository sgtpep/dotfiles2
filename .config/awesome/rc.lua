local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local naughty = require('naughty')
require('awful.autofocus')

function bind_alt_tab()
  local count
  function activate_client(previous)
    count = count + 1
    local clients = {}
    for _, client in ipairs(awful.client.focus.history.list) do
      if not client.hidden then
        table.insert(clients, table.unpack(previous and { 1, client } or { client }))
      end
    end
    clients[gears.table.hasitem(clients, client.focus) % #clients + 1]:jump_to()
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
    start_callback = function()
      count = 0
      awful.client.focus.history.disable_tracking()
    end,
    stop_callback = function()
      if client.focus then
        awful.client.focus.history.add(client.focus)
      end
      if count > 1 then
        gears.table.map(function(client)
          client:emit_signal('request::activate', 'bind_alt_tab', { raise = true })
        end, gears.table.reverse(awful.client.focus.history.list))
      end
      awful.client.focus.history.enable_tracking()
    end,
    stop_event = 'release',
    stop_key = modifier,
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

function create_tag()
  awful.tag({ 0 }, awful.screen.focused(), awful.layout.suit.max)
end

function run_or_raise(name, command, rule, shell)
  function match(client)
    return awful.rules.match(client, rule or { name = ('^%s$'):format(name) })
  end
  if client.focus and match(client.focus) then
    local iterator = awful.client.iterate(match)
    iterator()
    local client = iterator()
    if client then
      client:jump_to()
    end
  else
    local client = awful.client.focus.history.get(awful.screen.focused(), 0, match)
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
end

function set_background()
  gears.wallpaper.set(gears.color())
end

function set_keys()
  local terminal_command = 'x-terminal-emulator -title %q -e '
  local xon_command = 'sh -c \'stty -ixon && exec "$@"\' -- %q'
  local terminal_tmux_command = terminal_command .. 'tmux new-session -Ad -s %q ' .. xon_command .. ' \\; set-option status off \\; attach-session -t %q'
  local terminal_xon_command = terminal_command .. xon_command
  root.keys(gears.table.join(
    awful.key({ 'Control' }, 'F1', function()
      awful.spawn('parallels-keyboard')
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
    awful.key({ 'Control', 'Mod1' }, 'r', function()
      run_or_raise('dmenu_run', '%q -i -fn monospace-14 -nb Black -nf White -sb White -sf Black', { class = 'dmenu' })
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
      tag = root.tags()[1]
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
  ))
end

function set_rules()
  awful.rules.rules = {
    {
      properties = {
        callback = function(client)
          client:connect_signal('focus', function()
            awesome.xkb_set_layout_group(0)
          end)
        end,
        focus = awful.client.focus.filter,
        raise = true,
        size_hints_honor = false,
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
  create_tag()
  set_background()
  set_keys()
  set_rules()
end

main()
