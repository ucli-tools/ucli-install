/* ucli-kit copy.js, version 4. Copy buttons. No dependencies.
   Binds every .u-copy and removes `hidden`, so without JavaScript the buttons are absent rather than dead.
   `data-copy` is an element id: the script copies that element's textContent (generated "$ " text is not
   part of it) through the Clipboard API. Fallback: select that element and show "Selected".
   The label reads "Copied" or "Selected" and returns to "Copy" after 1800ms. The live region keeps the
   .u-visually-hidden class. The command stays ordinary selectable text. */
(function () {
  'use strict';
  var RESET_MS = 1800;

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
    var scope = btn.parentNode;
    var live = liveRegion(scope);
    var timer = null;

    function flash(text, message) {
      btn.textContent = text;
      live.textContent = message;
      clearTimeout(timer);
      timer = setTimeout(function () { btn.textContent = label; live.textContent = ''; }, RESET_MS);
    }

    btn.addEventListener('click', function () {
      var node = document.getElementById(btn.getAttribute('data-copy'));
      if (!node) return;
      var text = node.textContent;
      function fallback() {
        selectNode(node);
        flash('Selected', 'Selected, press Ctrl+C to copy');
      }
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(function () {
          flash('Copied', 'Copied to clipboard');
        }, fallback);
      } else {
        fallback();
      }
    });
    btn.hidden = false;
    btn.removeAttribute('hidden');
  }

  function init() {
    var buttons = document.querySelectorAll('.u-copy');
    for (var i = 0; i < buttons.length; i++) bind(buttons[i]);
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
