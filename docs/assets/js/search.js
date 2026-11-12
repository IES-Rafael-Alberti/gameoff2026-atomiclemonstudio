/* Search field (web version of a native search field):
 *  - leading search button, trailing clear button that only shows while there is text;
 *  - a "Recent searches" menu when the field is focused and empty;
 *  - live results from search.json (title + description), keyboard driven (combobox + listbox).
 */
(function () {
  var form = document.getElementById('site-search-form');
  if (!form) { return; }

  var input = form.querySelector('.search__input');
  var clear = form.querySelector('.search__clear');
  var panel = form.querySelector('.search__panel');
  var options = form.querySelector('.search__options');
  var forget = form.querySelector('.search__forget');
  var status = document.getElementById('search-status');

  var RECENT_KEY = 'recent-searches';
  var MAX_RECENT = 5;
  var index = null;
  var loading = null;
  var active = -1;

  function loadIndex() {
    if (!loading) {
      loading = fetch(form.dataset.index)
        .then(function (response) { return response.json(); })
        .catch(function () { return []; })
        .then(function (data) { index = data; return data; });
    }
    return loading;
  }

  function getRecent() {
    try { return JSON.parse(localStorage.getItem(RECENT_KEY)) || []; } catch (e) { return []; }
  }

  function saveRecent(query) {
    var list = getRecent().filter(function (item) { return item !== query; });
    list.unshift(query);
    try { localStorage.setItem(RECENT_KEY, JSON.stringify(list.slice(0, MAX_RECENT))); } catch (e) {}
  }

  function search(query) {
    var words = query.toLowerCase().split(/\s+/).filter(Boolean);
    return (index || []).map(function (entry) {
      var title = entry.title.toLowerCase();
      var text = (entry.text || '').toLowerCase();
      var score = 0;
      for (var i = 0; i < words.length; i++) {
        var inTitle = title.indexOf(words[i]) !== -1;
        var inText = text.indexOf(words[i]) !== -1;
        if (!inTitle && !inText) { return null; }
        score += (inTitle ? 3 : 0) + (inText ? 1 : 0);
      }
      return { entry: entry, score: score };
    }).filter(Boolean).sort(function (a, b) { return b.score - a.score; }).map(function (hit) { return hit.entry; });
  }

  function addItem(className, role, html) {
    var li = document.createElement('li');
    li.className = className;
    if (role) { li.setAttribute('role', role); }
    if (html) { li.appendChild(html); }
    options.appendChild(li);
    return li;
  }

  function textNode(tag, className, text) {
    var node = document.createElement(tag);
    node.className = className;
    node.textContent = text;
    return node;
  }

  function addOption(label, hint, data) {
    var li = addItem('search__option', 'option');
    li.id = 'search-option-' + options.querySelectorAll('[role="option"]').length;
    li.setAttribute('aria-selected', 'false');
    li.appendChild(textNode('span', 'search__title', label));
    if (hint) { li.appendChild(textNode('span', 'search__hint', hint)); }
    Object.keys(data).forEach(function (key) { li.dataset[key] = data[key]; });
    return li;
  }

  function open() {
    panel.hidden = false;
    input.setAttribute('aria-expanded', 'true');
  }

  function close() {
    panel.hidden = true;
    input.setAttribute('aria-expanded', 'false');
    input.removeAttribute('aria-activedescendant');
    active = -1;
  }

  function render() {
    var query = input.value.trim();
    clear.hidden = !input.value;
    options.textContent = '';
    active = -1;
    input.removeAttribute('aria-activedescendant');
    forget.hidden = true;

    if (!query) {
      var recent = getRecent();
      if (!recent.length) { close(); status.textContent = ''; return; }
      addItem('search__heading', 'presentation', document.createTextNode('Recent searches'));
      recent.forEach(function (item) { addOption(item, '', { recent: item }); });
      forget.hidden = false;
      status.textContent = recent.length + ' recent searches';
      open();
      return;
    }

    var hits = search(query);
    if (!hits.length) {
      addItem('search__empty', 'presentation', document.createTextNode('No results for "' + query + '"'));
      status.textContent = 'No results';
    } else {
      hits.slice(0, 6).forEach(function (hit) {
        addOption(hit.title, hit.text, { url: hit.url });
      });
      status.textContent = hits.length + (hits.length === 1 ? ' result' : ' results');
    }
    open();
  }

  function setActive(next) {
    var items = options.querySelectorAll('[role="option"]');
    if (!items.length) { return; }
    if (active >= 0 && items[active]) { items[active].setAttribute('aria-selected', 'false'); }
    active = (next + items.length) % items.length;
    items[active].setAttribute('aria-selected', 'true');
    input.setAttribute('aria-activedescendant', items[active].id);
    items[active].scrollIntoView({ block: 'nearest' });
  }

  function choose(item) {
    if (!item) { return; }
    if (item.dataset.recent) {
      input.value = item.dataset.recent;
      loadIndex().then(function () { render(); input.focus(); });
      return;
    }
    saveRecent(input.value.trim());
    window.location.href = item.dataset.url;
  }

  input.addEventListener('focus', function () { loadIndex().then(render); });
  input.addEventListener('input', function () { loadIndex().then(render); });

  input.addEventListener('keydown', function (event) {
    if (event.key === 'ArrowDown') { event.preventDefault(); if (panel.hidden) { render(); } setActive(active + 1); }
    else if (event.key === 'ArrowUp') { event.preventDefault(); setActive(active < 0 ? -1 : active - 1); }
    else if (event.key === 'Escape') {
      event.preventDefault();
      if (input.value) { input.value = ''; render(); } else { close(); }
    }
  });

  form.addEventListener('submit', function (event) {
    event.preventDefault();
    var items = options.querySelectorAll('[role="option"]');
    var item = active >= 0 ? items[active] : items[0];
    if (!input.value.trim()) { input.focus(); return; }
    loadIndex().then(function () {
      if (!options.querySelector('[role="option"]')) { render(); }
      items = options.querySelectorAll('[role="option"]');
      item = active >= 0 ? items[active] : items[0];
      if (item && item.dataset.url) { choose(item); }
    });
  });

  clear.addEventListener('click', function () {
    input.value = '';
    render();
    input.focus();
  });

  forget.addEventListener('click', function () {
    try { localStorage.removeItem(RECENT_KEY); } catch (e) {}
    render();
    input.focus();
  });

  // Keep the field focused while clicking inside the panel.
  panel.addEventListener('mousedown', function (event) { event.preventDefault(); });
  options.addEventListener('click', function (event) { choose(event.target.closest('[role="option"]')); });

  form.addEventListener('focusout', function (event) {
    if (!form.contains(event.relatedTarget)) { close(); }
  });
})();
