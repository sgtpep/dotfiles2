const closeTab = tab =>
  chrome.tabs.query({ windowId: tab.windowId, windowType: 'normal' }, tabs =>
    tabs.length > 1 ||
    !tabs.length ||
    tab.incognito ||
    tab.url === 'chrome://newtab/'
      ? chrome.tabs.remove(tab.id)
      : chrome.tabs.update(tab.id, { url: 'chrome://newtab/' })
  );

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

const main = () =>
  chrome.commands.onCommand.addListener(command =>
    chrome.tabs.query({ active: true, currentWindow: true }, ([tab]) =>
      command === 'close-tab'
        ? closeTab(tab)
        : command === 'copy-title-url'
        ? copyText([tab.title, tab.url].filter(Boolean).join(' '))
        : command === 'copy-url'
        ? copyText(tab.url)
        : command === 'toggle-pinned'
        ? togglePinnedTab(tab)
        : undefined
    )
  );

const togglePinnedTab = tab =>
  chrome.tabs.update(null, { pinned: !tab.pinned });

main();
