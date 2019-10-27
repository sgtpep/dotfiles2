const copyText = text => {
  addEventListener(
    'copy',
    event => {
      event.preventDefault()
      event.clipboardData.setData('text/plain', text)
    },
    { once: true },
  )
  document.execCommand('copy')
}

const enableJavaScript = (url, incognito = false) =>
  chrome.contentSettings.javascript.set(
    {
      primaryPattern: /^file:/.test(url)
        ? url
        : `${url.match(/^https?:\/\/([^\/]+)/)[0]}/*`,
      scope: incognito ? 'incognito_session_only' : 'regular',
      setting: 'allow',
    },
    () => chrome.tabs.reload(),
  )

const listenCommand = () =>
  chrome.commands.onCommand.addListener(command =>
    chrome.tabs.query({ active: true, currentWindow: true }, ([tab]) =>
      command === 'copy-title-url'
        ? copyText([tab.title, tab.url].filter(Boolean).join(' '))
        : command === 'copy-url'
        ? copyText(tab.url)
        : command === 'enable-javascript'
        ? enableJavaScript(tab.url, tab.incognito)
        : command === 'history-back'
        ? chrome.tabs.executeScript({ code: 'history.back()' })
        : command === 'history-forward'
        ? chrome.tabs.executeScript({ code: 'history.forward()' })
        : command === 'toggle-pinned'
        ? togglePinnedTab(tab)
        : undefined,
    ),
  )

const listenUpdated = () => {
  chrome.tabs.onCreated.addListener(({ id, url }) => onUpdated(id, url))
  chrome.tabs.onUpdated.addListener(
    (id, { status, url }) => status === 'completed' && onUpdated(id, url),
  )
}

const main = () => {
  listenCommand()
  listenUpdated()
}

const onUpdated = (id, url) =>
  chrome.tabs.getZoom(id, factor => {
    const zoom = zooms[url && new URL(url).hostname] || 1
    zoom === factor || chrome.tabs.setZoom(id, zoom)
  })

const togglePinnedTab = tab => chrome.tabs.update({ pinned: !tab.pinned })

const zooms = {
  'app.slack.com': 1.25,
}

main()
