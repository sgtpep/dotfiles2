const copyText = text => {
  addEventListener(
    'copy',
    event => {
      event.preventDefault();
      event.clipboardData.setData('text/plain', text);
    },
    { once: true }
  );
  document.execCommand('copy');
};

const enableJavaScript = (url, incognito = false) =>
  chrome.contentSettings.javascript.set(
    {
      primaryPattern: /^file:/.test(url)
        ? url
        : `${url.match(/^https?:\/\/([^\/]+)/)[0]}/*`,
      scope: incognito ? 'incognito_session_only' : 'regular',
      setting: 'allow',
    },
    () => chrome.tabs.reload()
  );

const listenCommands = () =>
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
        : undefined
    )
  );

const main = () => listenCommands();

const togglePinnedTab = tab => chrome.tabs.update({ pinned: !tab.pinned });

main();
