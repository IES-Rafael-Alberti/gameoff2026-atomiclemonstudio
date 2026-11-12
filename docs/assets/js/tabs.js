/* Accessible tabs: one shared tabpanel that is filtered in place (no navigation).
 * Roving tabindex: only the selected tab is in the tab order. Left / Right move between tabs
 * (and wrap around), Home / End jump to the first / last one.
 */
(function () {
  Array.prototype.forEach.call(document.querySelectorAll('[data-tabs]'), function (widget) {
    var list = widget.querySelector('[role="tablist"]');
    var panel = widget.querySelector('[role="tabpanel"]');
    var tabs = Array.prototype.slice.call(widget.querySelectorAll('[role="tab"]'));
    var cards = Array.prototype.slice.call(panel.querySelectorAll('[data-areas]'));
    if (!list || !panel || !tabs.length) { return; }

    function select(tab, moveFocus) {
      tabs.forEach(function (other) {
        var active = other === tab;
        other.setAttribute('aria-selected', String(active));
        other.tabIndex = active ? 0 : -1;
      });
      panel.setAttribute('aria-labelledby', tab.id);

      var filter = tab.dataset.filter;
      cards.forEach(function (card) {
        var areas = card.dataset.areas.split(' ');
        card.hidden = filter !== 'all' && areas.indexOf(filter) === -1;
      });

      if (moveFocus) { tab.focus(); }
    }

    tabs.forEach(function (tab, index) {
      tab.addEventListener('click', function () { select(tab, false); });

      tab.addEventListener('keydown', function (event) {
        var next = null;
        if (event.key === 'ArrowRight') { next = tabs[(index + 1) % tabs.length]; }
        else if (event.key === 'ArrowLeft') { next = tabs[(index - 1 + tabs.length) % tabs.length]; }
        else if (event.key === 'Home') { next = tabs[0]; }
        else if (event.key === 'End') { next = tabs[tabs.length - 1]; }
        if (next) {
          event.preventDefault();
          select(next, true);
        }
      });
    });

    list.hidden = false;
    select(tabs.filter(function (tab) { return tab.getAttribute('aria-selected') === 'true'; })[0] || tabs[0], false);
  });
})();
