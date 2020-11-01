const getVisibleElements = () =>
  [
    ...document.querySelectorAll(
      "a, button, input:not([type=hidden]), select, textarea"
    ),
  ].filter((element) => isElementVisible(element));

const isElementVisible = (element) => {
  const rects = element.getClientRects();
  return rects.length && rects[0].bottom >= 0 && rects[0].top <= innerHeight;
};

const characters = "fdsagrewcx";

const clickElement = (element, isBackground = false) => {
  let target;
  if (element.target === "_blank") {
    ({ target } = element);
    element.removeAttribute("target");
  }
  element.dispatchEvent(
    new MouseEvent("click", {
      bubbles: true,
      cancelable: true,
      ctrlKey: isBackground,
      view: window,
    })
  );
  target && (element.target = target);
  isElementVisible(element) && element.focus({ preventScroll: true });
};

const id = "gcpccpgdkmihefbjbhkipbjcpfaokokd-hints";

const hideHints = () => document.getElementById(id).remove();

const listenHintsEvents = (hints, elements) => {
  addEventListener("scroll", () => hideHints(), { once: true });
  hints.addEventListener("click", () => hideHints());
  let input = "";
  hints.addEventListener("keydown", (event) => {
    event.preventDefault();
    event.stopPropagation();
    const character = event.key.toLowerCase();
    if (characters.includes(character)) {
      input += character;
      if (input.length > Object.keys(elements)[0]?.length ?? 0) {
        hideHints();
      } else if (elements[input]) {
        clickElement(elements[input], !event.shiftKey);
        hideHints();
      }
    } else if (event.key !== "Shift") {
      hideHints();
    }
  });
};

const showHints = () => {
  const hints = document.createElement("div");
  hints.id = id;
  hints.tabIndex = 0;
  const elements = {};
  getVisibleElements().forEach((element, index, { length }) => {
    const label = [...index.toString().padStart(length.toString().length, "0")]
      .map((digit) => characters[digit])
      .join("");
    elements[label] = element;
    const hint = document.createElement("span");
    hint.dataset.label = label;
    const [{ left, top }] = element.getClientRects();
    hint.style.left = `${left}px`;
    hint.style.top = `${top}px`;
    hint.textContent = label.toUpperCase();
    hints.appendChild(hint);
  });
  const style = document.createElement("style");
  style.textContent = `
  #${id} {
    bottom: 0;
    left: 0;
    overflow: hidden;
    position: fixed;
    right: 0;
    top: 0;
    z-index: 2147483647;
  }
  #${id}:focus {
    outline: none;
  }
  #${id} > * {
    background-color: black;
    color: white;
    font: 16px / 1.2 monospace;
    margin: 0;
    padding: 0;
    position: absolute;
  }
  `.replace(/;/g, " !important$&");
  hints.appendChild(style);
  document.body.append(hints);
  hints.focus();
  listenHintsEvents(hints, elements);
};

const main = () => {
  const hintsKey = "f";
  addEventListener("DOMContentLoaded", () =>
    document
      .querySelector(`[accesskey="${hintsKey}"]`)
      ?.removeAttribute("accesskey")
  );
  addEventListener("keydown", (event) => {
    if (event.altKey && !event.ctrlKey && event.key === hintsKey) {
      event.preventDefault();
      event.stopPropagation();
      showHints();
    }
  });
};

main();
