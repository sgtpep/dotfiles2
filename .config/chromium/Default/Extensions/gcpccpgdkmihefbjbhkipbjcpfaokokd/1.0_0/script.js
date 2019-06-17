const characters = 'fdsagrewcx';

const clickElement = (element, ctrlKey = false) => {
  if (element.target === '_blank') {
    var { target } = element;
    element.removeAttribute('target');
  }
  element.dispatchEvent(
    new MouseEvent('click', {
      bubbles: true,
      cancelable: true,
      ctrlKey,
      view: window,
    })
  );
  target && (element.target = target);
  element.focus();
};

const generateLabel = (index, length) =>
  [...index.toString().padStart(length.toString().length, '0')]
    .map(digit => characters[digit])
    .join('');

const hideHints = () => {
  document.getElementById(`${id}-hints`).remove();
  removeEventListener('scroll', onScroll);
};

const hintsItem = (label, element) => {
  const item = document.createElement('span');
  item.dataset.label = label;
  const [{ left, top }] = element.getClientRects();
  item.style.left = `${left}px`;
  item.style.top = `${top}px`;
  item.textContent = label.toUpperCase();
  return item;
};

const hintsStyle = () => {
  const style = document.createElement('style');
  style.textContent = `
  #${id}-hints {
    bottom: 0;
    left: 0;
    overflow: hidden;
    position: fixed;
    right: 0;
    top: 0;
    z-index: 2147483647;
  }
  #${id}-hints:focus {
    outline: none;
  }
  #${id}-hints > span {
    background-color: black;
    color: white;
    font: 16px / 1.2 monospace;
    margin: 0;
    padding: 0;
    position: absolute;
  }
  `.replace(/;/g, ' !important$&');
  return style;
};

const id = 'gcpccpgdkmihefbjbhkipbjcpfaokokd';

const listenKeyDown = () =>
  addEventListener('keydown', event => {
    if (event.altKey && !event.ctrlKey && event.key === 'f') {
      event.preventDefault();
      event.stopPropagation();
      showHints();
    }
  });

const listenLoaded = () =>
  addEventListener('DOMContentLoaded', () => {
    const element = document.querySelector('[accesskey="f"]');
    element && element.removeAttribute('accesskey');
  });

const main = () => {
  listenKeyDown();
  listenLoaded();
};

const onHintsKey = (event, elements, updateInput) => {
  event.preventDefault();
  event.stopPropagation();
  const character = event.key.toLowerCase();
  if (characters.includes(character)) {
    const input = updateInput(character);
    if (input.length > (Object.keys(elements)[0] || '').length) {
      hideHints();
    } else if (elements[input]) {
      clickElement(elements[input], event.shiftKey);
      hideHints();
    }
  } else if (event.key !== 'Shift') {
    hideHints();
  }
};

const onScroll = () => hideHints();

const showHints = () => {
  const hints = document.createElement('div');
  hints.id = `${id}-hints`;
  hints.tabIndex = 0;
  hints.appendChild(hintsStyle());
  const elements = {};
  visibleElements().forEach((element, index, { length }) => {
    const label = generateLabel(index, length);
    elements[label] = element;
    hints.appendChild(hintsItem(label, element));
  });
  document.body.append(hints);
  hints.focus();
  let input = '';
  hints.addEventListener('click', () => hideHints());
  hints.addEventListener('keydown', event =>
    onHintsKey(event, elements, character => (input += character))
  );
  addEventListener('scroll', onScroll);
};

const visibleElements = () =>
  [
    ...document.querySelectorAll(
      'a, button, input:not([type=hidden]), select, textarea'
    ),
  ].filter(element => {
    const rects = element.getClientRects();
    return rects.length && rects[0].bottom >= 0 && rects[0].top <= innerHeight;
  });

main();
