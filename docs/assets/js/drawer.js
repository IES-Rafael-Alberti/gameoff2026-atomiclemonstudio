/* Hamburger menu.
 *
 * The navigation panel is completely hidden until it is opened, and it opens OVER the page, so the
 * content never moves. It opens:
 *  - when the mouse hovers over the button (it closes again when the mouse leaves);
 *  - with a click, a tap or Enter / Space on the button, which keeps it open ("pinned").
 * It closes with Escape, with a click outside, or with another click on the button.
 * aria-expanded is kept in sync, and focus goes back to the button when Escape closes it.
 */
(function () {
  var root = document.documentElement;
  var button = document.getElementById('menu-button');
  var nav = document.getElementById('site-nav');
  if (!button || !nav) { return; }

  var FOCUSABLE = 'a[href], button:not([disabled]), input:not([disabled])';
  var CLOSE_DELAY = 250;
  var pinned = false;
  var timer = null;

  function isOpen() { return root.dataset.nav === 'open'; }

  function setOpen(open) {
    root.dataset.nav = open ? 'open' : 'closed';
    button.setAttribute('aria-expanded', String(open));
    nav.inert = !open;
    if (!open) { pinned = false; }
  }

  function cancelClose() { window.clearTimeout(timer); }

  function closeSoon() {
    cancelClose();
    timer = window.setTimeout(function () {
      if (!pinned && !nav.contains(document.activeElement)) { setOpen(false); }
    }, CLOSE_DELAY);
  }

  function isMouse(event) { return event.pointerType === 'mouse'; }

  // Hover: open while the pointer is over the button or the panel.
  [button, nav].forEach(function (element) {
    element.addEventListener('pointerenter', function (event) {
      if (!isMouse(event)) { return; }
      cancelClose();
      setOpen(true);
    });
    element.addEventListener('pointerleave', function (event) {
      if (isMouse(event)) { closeSoon(); }
    });
  });

  // Click, tap or keyboard: toggle and keep it open.
  button.addEventListener('click', function (event) {
    cancelClose();
    if (isOpen() && pinned) {
      setOpen(false);
      return;
    }
    setOpen(true);
    pinned = true;
    // Opened from the keyboard (no pointer): move into the menu.
    if (event.detail === 0) {
      var first = nav.querySelector(FOCUSABLE);
      if (first) { first.focus(); }
    }
  });

  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape' && isOpen()) {
      var hadFocus = nav.contains(document.activeElement);
      setOpen(false);
      if (hadFocus) { button.focus(); }
    }
  });

  // Click or tap anywhere else closes it.
  document.addEventListener('pointerdown', function (event) {
    if (isOpen() && !nav.contains(event.target) && !button.contains(event.target)) { setOpen(false); }
  });

  // Moving the keyboard focus out of the open menu closes it, unless it is pinned.
  nav.addEventListener('focusout', function (event) {
    if (!pinned && !nav.contains(event.relatedTarget) && event.relatedTarget !== button) { closeSoon(); }
  });

  setOpen(false);
})();
