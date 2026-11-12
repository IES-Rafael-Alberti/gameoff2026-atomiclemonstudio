/* Hamburger menu + navigation drawer / docked sidebar.
 *
 * One <nav> serves both layouts:
 *  - narrow screens: off-canvas drawer over a scrim (scroll locked, Escape and scrim close it,
 *    focus is trapped inside and goes back to the button on close);
 *  - wide screens: docked, collapsible left column (the choice is remembered).
 */
(function () {
  var root = document.documentElement;
  var button = document.getElementById('menu-button');
  var nav = document.getElementById('site-nav');
  var scrim = document.getElementById('nav-scrim');
  var detail = document.getElementById('detail');
  if (!button || !nav || !scrim || !detail) { return; }

  var wide = window.matchMedia('(min-width: 60em)');
  var FOCUSABLE = 'a[href], button:not([disabled]), input:not([disabled]), [tabindex]:not([tabindex="-1"])';

  function isDrawer() { return !wide.matches; }
  function isOpen() { return root.dataset.nav === 'open'; }

  function apply(open) {
    var modal = open && isDrawer();
    root.dataset.nav = open ? 'open' : 'closed';
    button.setAttribute('aria-expanded', String(open));
    nav.inert = !open;
    detail.inert = modal;
    scrim.hidden = !modal;
    root.classList.toggle('is-locked', modal);
  }

  function open() {
    apply(true);
    if (isDrawer()) {
      var first = nav.querySelector(FOCUSABLE);
      if (first) { first.focus(); }
    } else {
      try { localStorage.setItem('sidebar', 'open'); } catch (e) {}
    }
  }

  function close(restoreFocus) {
    apply(false);
    if (!isDrawer()) {
      try { localStorage.setItem('sidebar', 'closed'); } catch (e) {}
    }
    if (restoreFocus) { button.focus(); }
  }

  button.addEventListener('click', function () {
    if (isOpen()) { close(true); } else { open(); }
  });

  scrim.addEventListener('click', function () { close(true); });

  document.addEventListener('keydown', function (event) {
    if (!isOpen() || !isDrawer()) { return; }

    if (event.key === 'Escape') {
      event.preventDefault();
      close(true);
      return;
    }

    if (event.key === 'Tab') {
      var items = nav.querySelectorAll(FOCUSABLE);
      if (!items.length) { return; }
      var first = items[0];
      var last = items[items.length - 1];
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      } else if (!nav.contains(document.activeElement)) {
        event.preventDefault();
        first.focus();
      }
    }
  });

  // Crossing the breakpoint switches between drawer and docked sidebar.
  function sync() {
    var stored = null;
    try { stored = localStorage.getItem('sidebar'); } catch (e) {}
    apply(wide.matches && stored !== 'closed');
  }
  if (wide.addEventListener) { wide.addEventListener('change', sync); } else { wide.addListener(sync); }

  sync();
})();
