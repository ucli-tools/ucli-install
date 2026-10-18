/* ucli-kit theme.js, version 4. Light/dark button for the Astro sites (the docs use Material's own toggle).
   Binds every .u-theme button, removes `hidden`, toggles data-theme on <html> and remembers the choice in
   localStorage (inside try/catch). It never changes the button's content or aria-label: the icon stays and
   the label stays "Switch colour theme". Without JavaScript the page follows prefers-color-scheme alone.

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

  function init() {
    var saved = stored();
    if (saved) root.setAttribute('data-theme', saved);
    var buttons = document.querySelectorAll('.u-theme');
    for (var i = 0; i < buttons.length; i++) {
      (function (btn) {
        btn.hidden = false;
        btn.removeAttribute('hidden');
        btn.addEventListener('click', function () {
          var next = effective() === 'dark' ? 'light' : 'dark';
          root.setAttribute('data-theme', next);
          try { localStorage.setItem(KEY, next); } catch (e) { /* storage blocked: the choice lasts for this page */ }
        });
      })(buttons[i]);
    }
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
