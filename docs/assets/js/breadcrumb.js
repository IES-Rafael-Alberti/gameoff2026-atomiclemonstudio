/* Breadcrumb: when it does not fit, the middle ancestors collapse into an ellipsis button.
 * The first item (Home) and the current page always stay visible; the button expands the rest.
 */
(function () {
  var nav = document.getElementById('breadcrumb');
  if (!nav) { return; }

  var list = nav.querySelector('.breadcrumb__list');
  var middle = nav.querySelectorAll('.breadcrumb__item--middle');
  if (!list || !middle.length) { return; }

  var item = document.createElement('li');
  item.className = 'breadcrumb__item breadcrumb__item--ellipsis';
  var more = document.createElement('button');
  more.type = 'button';
  more.className = 'breadcrumb__more';
  more.textContent = '…';
  more.setAttribute('aria-label', 'Show hidden levels');
  more.setAttribute('aria-expanded', 'false');
  item.appendChild(more);
  list.insertBefore(item, middle[0]);

  more.addEventListener('click', function () {
    nav.classList.add('is-expanded');
    more.setAttribute('aria-expanded', 'true');
    list.style.flexWrap = 'wrap';
    var firstHidden = middle[0].querySelector('a');
    if (firstHidden) { firstHidden.focus(); }
  });

  function layout() {
    if (nav.classList.contains('is-expanded')) { return; }
    nav.classList.remove('is-collapsed');
    nav.classList.add('is-measuring');
    var tight = list.scrollWidth > list.clientWidth + 1;
    nav.classList.remove('is-measuring');
    nav.classList.toggle('is-collapsed', tight);
  }

  if ('ResizeObserver' in window) { new ResizeObserver(layout).observe(nav); }
  else { window.addEventListener('resize', layout); }
  if (document.fonts && document.fonts.ready) { document.fonts.ready.then(layout); }
  layout();
})();
