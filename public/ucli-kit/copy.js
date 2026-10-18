/* ucli-kit copy.js: copy buttons. No dependencies.
   Binds every .u-cmd (button .u-cmd__copy, text in the figure's data-copy) and every .u-copy
   (inline button, text in its own data-copy). Removes `hidden` from the buttons, so without
   JavaScript they are absent rather than dead. The command stays ordinary selectable text. */
(function () {
  'use strict';
  var RESET_MS = 1600;

  function liveRegion(scope) {
    var live = scope.querySelector('[aria-live]');
    if (!live) {
      live = document.createElement('span');
      live.className = 'u-visually-hidden';
      live.setAttribute('aria-live', 'polite');
      scope.appendChild(live);
    }
    return live;
  }

  function sourceText(btn) {
    var holder = btn.hasAttribute('data-copy') ? btn : btn.closest('[data-copy]');
    return holder ? holder.getAttribute('data-copy') : '';
  }

  function sourceNode(btn) {
    var fig = btn.closest('.u-cmd');
    if (fig) return fig.querySelector('code');
    var prev = btn.previousElementSibling;
    while (prev && prev.tagName !== 'CODE') prev = prev.previousElementSibling;
    return prev || (btn.parentNode && btn.parentNode.querySelector('code'));
  }

  function selectNode(node) {
    if (!node || !window.getSelection) return;
    var range = document.createRange();
    range.selectNodeContents(node);
    var sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(range);
  }

  function bind(btn) {
    var label = btn.textContent;
    var scope = btn.closest('.u-cmd') || btn.parentNode;
    var live = liveRegion(scope);
    var timer = null;

    function flash(text, message) {
      btn.textContent = text;
      live.textContent = message;
      clearTimeout(timer);
      timer = setTimeout(function () { btn.textContent = label; live.textContent = ''; }, RESET_MS);
    }

    btn.addEventListener('click', function () {
      var text = sourceText(btn);
      function fail() {
        selectNode(sourceNode(btn));
        flash(label, 'Press Ctrl+C');
      }
      if (!text) return fail();
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(function () {
          flash('Copied', 'Copied to clipboard');
        }, fail);
      } else {
        fail();
      }
    });
    btn.hidden = false;
    btn.removeAttribute('hidden');
  }

  function init() {
    var buttons = document.querySelectorAll('.u-cmd__copy, .u-copy');
    for (var i = 0; i < buttons.length; i++) bind(buttons[i]);
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
