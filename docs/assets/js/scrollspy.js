/* Scrollspy for the "On this page" rail.
 *
 * An IntersectionObserver watches every section anchor target (the h2 each link points to).
 * rootMargin pushes the activation zone below the sticky header, so a section becomes current when
 * its heading enters the band just under the header. Exactly one link carries aria-current="location".
 */
(function () {
  var rail = document.getElementById('toc');
  if (!rail || !('IntersectionObserver' in window)) { return; }

  var links = Array.prototype.slice.call(rail.querySelectorAll('a[href^="#"]'));
  var targets = links.map(function (link) {
    return document.getElementById(decodeURIComponent(link.getAttribute('href').slice(1)));
  });
  if (!links.length || targets.some(function (target) { return !target; })) { return; }

  var inZone = new Set();
  var observer = null;
  var current = -1;

  function headerHeight() {
    var header = document.getElementById('topbar');
    return header ? Math.round(header.getBoundingClientRect().height) : 0;
  }

  function setCurrent(index) {
    if (index === current) { return; }
    current = index;
    links.forEach(function (link, i) {
      if (i === index) { link.setAttribute('aria-current', 'location'); }
      else { link.removeAttribute('aria-current'); }
    });
  }

  // Which section is the reader in? The first heading inside the zone wins; if none is, the last
  // heading that already went above the zone; at the very bottom of the page, the last section.
  function update() {
    var nearBottom = window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 2;
    if (nearBottom) { setCurrent(targets.length - 1); return; }

    for (var i = 0; i < targets.length; i++) {
      if (inZone.has(targets[i])) { setCurrent(i); return; }
    }

    var line = headerHeight() + 1;
    var found = 0;
    for (var j = 0; j < targets.length; j++) {
      if (targets[j].getBoundingClientRect().top <= line) { found = j; }
    }
    setCurrent(found);
  }

  function observe() {
    if (observer) { observer.disconnect(); }
    inZone.clear();
    // Zone: from just under the sticky header down to 35% of the viewport height.
    observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) { inZone.add(entry.target); } else { inZone.delete(entry.target); }
      });
      update();
    }, { rootMargin: '-' + headerHeight() + 'px 0px -65% 0px', threshold: 0 });
    targets.forEach(function (target) { observer.observe(target); });
  }

  rail.addEventListener('click', function (event) {
    var link = event.target.closest('a[href^="#"]');
    if (link) { setCurrent(links.indexOf(link)); }
  });

  window.addEventListener('resize', function () { observe(); update(); });
  window.addEventListener('scroll', function () {
    // Cheap check only needed for the bottom of the page, where the last heading may never enter the zone.
    if (window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 2) { update(); }
  }, { passive: true });

  observe();
  update();
})();
