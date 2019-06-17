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
    command === 'copy-title-url'
      ? copy([tab.title, tab.url].filter(Boolean).join(' '))
      : command === 'copy-url'
      ? copy(tab.url)
      : command === 'toggle-pinned'
      ? chrome.tabs.update(null, { pinned: !tab.pinned })
      : undefined
  )
);
