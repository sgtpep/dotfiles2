const copyText = (text) => {
  addEventListener(
    "copy",
    (event) => {
      event.preventDefault();
      event.clipboardData.setData("text/plain", text);
    },
    { once: true }
  );
  document.execCommand("copy");
};

const setPinned = (pinned) => chrome.tabs.update({ pinned });

const main = () =>
  chrome.commands.onCommand.addListener((command) =>
    chrome.tabs.query(
      { active: true, currentWindow: true },
      ([{ pinned, title, url }]) =>
        command === "copy-title-url"
          ? copyText([title, url].filter(Boolean).join(" "))
          : command === "copy-url"
          ? copyText(url)
          : command === "toggle-pinned"
          ? setPinned(!pinned)
          : undefined
    )
  );

main();
