/* Light / dark theme toggle. The first paint is handled by the inline script in head.html. */
(function () {
  var root = document.documentElement;
  var button = document.getElementById('theme-toggle');
  if (!button) { return; }

  var system = window.matchMedia('(prefers-color-scheme: dark)');

  function current() { return root.dataset.theme === 'dark' ? 'dark' : 'light'; }

  function show(theme) {
    root.dataset.theme = theme;
    button.setAttribute('aria-label', theme === 'dark' ? 'Switch to light theme' : 'Switch to dark theme');
  }

  button.addEventListener('click', function () {
    var next = current() === 'dark' ? 'light' : 'dark';
    show(next);
    try { localStorage.setItem('theme', next); } catch (e) {}
  });

  // Until the user picks a theme, follow the system one.
  function onSystemChange(event) {
    var saved = null;
    try { saved = localStorage.getItem('theme'); } catch (e) {}
    if (!saved) { show(event.matches ? 'dark' : 'light'); }
  }
  if (system.addEventListener) { system.addEventListener('change', onSystemChange); }

  show(current());
})();
