/* ucli-kit theme.js: light/dark toggle for the Astro sites (the docs use Material's own toggle).
   Sets data-theme on <html> and remembers the choice in localStorage (inside try/catch).
   The toggle button ([data-theme-toggle], class u-toggle) is rendered `hidden` and revealed here;
   its label names the mode a click switches to ("Light mode" while dark, "Dark mode" while light). Without JavaScript the page follows
   prefers-color-scheme alone.

   Put this inline in <head>, before the stylesheets, so a stored choice applies before first paint:
   <script>try{var t=localStorage.getItem('ucli-theme');if(t==='light'||t==='dark')document.documentElement.setAttribute('data-theme',t)}catch(e){}</script> */
(function () {
  'use strict';
  var KEY = 'ucli-theme';
  var root = document.documentElement;
  var mq = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null;

  function stored() {
    try { var v = localStorage.getItem(KEY); return v === 'light' || v === 'dark' ? v : null; }
    catch (e) { return null; }
  }
  function effective() {
    var attr = root.getAttribute('data-theme');
    if (attr === 'light' || attr === 'dark') return attr;
    return mq && mq.matches ? 'dark' : 'light';
  }
  function sync(buttons) {
    var dark = effective() === 'dark';
    for (var i = 0; i < buttons.length; i++) buttons[i].textContent = dark ? 'Light mode' : 'Dark mode';
  }

  function init() {
    var saved = stored();
    if (saved) root.setAttribute('data-theme', saved);
    var buttons = document.querySelectorAll('[data-theme-toggle]');
    for (var i = 0; i < buttons.length; i++) {
      (function (btn) {
        btn.hidden = false;
        btn.removeAttribute('hidden');
        btn.addEventListener('click', function () {
          var next = effective() === 'dark' ? 'light' : 'dark';
          root.setAttribute('data-theme', next);
          try { localStorage.setItem(KEY, next); } catch (e) { /* storage blocked: choice lasts for this page */ }
          sync(buttons);
        });
      })(buttons[i]);
    }
    sync(buttons);
    if (mq && mq.addEventListener) mq.addEventListener('change', function () { sync(buttons); });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
