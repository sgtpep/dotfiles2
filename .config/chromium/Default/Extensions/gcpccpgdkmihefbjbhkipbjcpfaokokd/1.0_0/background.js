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

const insertCSS = () =>
  chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
    if (tab.url && changeInfo.status === 'loading') {
      const { host } = new URL(tab.url);
      styles[host] &&
        chrome.tabs.insertCSS(tabId, {
          code: styles[host].replace(/;| }/g, ' !important$&'),
        });
    }
  });

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

const main = () => {
  insertCSS();
  listenCommands();
};

const styles = {
  'app.slack.com': `
    .c-message, .c-message_kit__message, .c-texty_input .ql-editor, .c-texty_input .ql-placeholder { font-size: 19px }
    .p-channel_sidebar__channel--muted > .c-mention_badge { display: none }
  `,
  'stackoverflow.com':
    'body, .top-bar { margin-top: 0 } #js-gdpr-consent-banner, #noscript-warning { display: none }',
  'www.reddit.com':
    '.kkVTOP { max-height: none } .kkVTOP::before { display: none }',
};

const togglePinnedTab = tab => chrome.tabs.update({ pinned: !tab.pinned });

main();
