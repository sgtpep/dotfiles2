const copy = text => {
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
chrome.commands.onCommand.addListener(command =>
  chrome.tabs.query({ active: true, currentWindow: true }, ([tab]) =>
    command === 'close-tab'
      ? chrome.tabs.query({ windowId: tab.windowId }, tabs =>
          tabs.length > 1 || tab.url === 'chrome://newtab/'
            ? chrome.tabs.remove(tab.id)
            : chrome.tabs.update(tab.id, { url: 'chrome://newtab/' })
        )
      : command === 'copy-title-url'
      ? copy([tab.title, tab.url].filter(Boolean).join(' '))
      : command === 'copy-url'
      ? copy(tab.url)
      : command === 'toggle-pinned'
      ? chrome.tabs.update(null, { pinned: !tab.pinned })
      : undefined
  )
);
