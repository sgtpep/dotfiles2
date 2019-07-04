const closeTab = tab =>
  chrome.tabs.query({ windowId: tab.windowId, windowType: 'normal' }, tabs => {
    tabs.length === 1 &&
      tab.url !== 'chrome://newtab/' &&
      !tab.incognito &&
      chrome.tabs.create({});
    chrome.tabs.remove(tab.id);
  });

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

const insertCSS = () =>
  chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
    if (tab.url && changeInfo.status === 'loading') {
      const { host } = new URL(tab.url);
      styles[host] &&
        chrome.tabs.insertCSS(tabId, {
          code: styles[host].replace(/;/g, ' !important$&'),
        });
    }
  });

const listenCommands = () =>
  chrome.commands.onCommand.addListener(command =>
    chrome.tabs.query({ active: true, currentWindow: true }, ([tab]) =>
      command === 'close-tab'
        ? closeTab(tab)
        : command === 'copy-title-url'
        ? copyText([tab.title, tab.url].filter(Boolean).join(' '))
        : command === 'copy-url'
        ? copyText(tab.url)
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
  'stackoverflow.com':
    'body, .top-bar { margin-top: 0; } #js-gdpr-consent-banner, #noscript-warning { display: none; }',
  'www.reddit.com': '.kkVTOP { max-height: none; } .kkVTOP::before { display: none; }',
};

const togglePinnedTab = tab => chrome.tabs.update({ pinned: !tab.pinned });

main();
