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

const main = () => {
  chrome.commands.onCommand.addListener((command) => {
    chrome.tabs.query(
      { active: true, currentWindow: true },
      ([{ pinned, title, url }]) => {
        if (command === "copy-title-url") {
          copyText([title, url].filter(Boolean).join(" "));
        } else if (command === "copy-url") {
          copyText(url);
        } else if (command === "history-back") {
          chrome.tabs.executeScript({ code: "history.back()" });
        } else if (command === "history-forward") {
          chrome.tabs.executeScript({ code: "history.forward()" });
        } else if (command === "toggle-pinned") {
          chrome.tabs.update({ pinned: !pinned });
        }
      }
    );
  });
};

main();
