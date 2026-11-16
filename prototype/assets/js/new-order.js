(() => {
  const api = window.WashdayCatalog;
  const grid = document.querySelector('#category-grid');
  if (!api || !grid) return;

  const total = document.querySelector('#category-total');
  const note = document.querySelector('#catalog-note');

  const icons = {
    shirts: '<path d="m8 4 4 2 4-2 5 3-2 4-3-1v10H8V10l-3 1-2-4 5-3Z"/><path d="M9 5.5c.5 1.6 1.5 2.5 3 2.5s2.5-.9 3-2.5"/>',
    pants: '<path d="M6 3h12l-1 18h-4l-1-8-1 8H7L6 3Z"/><path d="M7 7h10"/>',
    dresses: '<path d="M9 4h6l1 4 5 12H3L8 8l1-4Z"/><path d="M9 4c0 2 1 3 3 3s3-1 3-3M8 10h8"/>',
    bedding: '<path d="M3 19V6m0 9h18v4M3 11h18v4M7 11V8h5v3m9 0V9a2 2 0 0 0-2-2h-1"/>'
  };
  const fallbackIcon = '<path d="M4 7h16v13H4zM4 10h16M8 4v6m8-6v6"/><path d="M8 14h3m2 0h3"/>';

  function categoryIcon(id) {
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('viewBox', '0 0 24 24');
    svg.innerHTML = icons[id] ?? fallbackIcon;
    return svg;
  }

  function renderCategory(category) {
    const services = api.getServices(category.id).filter((service) => service.active !== false);
    const tile = document.createElement('a');
    tile.className = 'category-tile';
    tile.href = `category-services.html?category=${encodeURIComponent(category.id)}`;
    tile.dataset.category = category.id;

    const image = document.createElement('img');
    image.src = category.image;
    image.alt = '';
    image.loading = 'lazy';
    image.addEventListener('error', () => {
      image.hidden = true;
      tile.classList.add('has-no-image');
    });
    tile.append(image);

    const iconWrap = document.createElement('span');
    iconWrap.className = 'category-icon';
    iconWrap.setAttribute('aria-hidden', 'true');
    iconWrap.append(categoryIcon(category.id));
    tile.append(iconWrap);

    const copy = document.createElement('span');
    copy.className = 'category-copy';
    const name = document.createElement('span');
    name.className = 'category-name';
    name.textContent = category.name;
    const meta = document.createElement('span');
    meta.className = 'category-meta';
    meta.textContent = services.length === 1 ? '1 service' : `${services.length} services`;
    copy.append(name, meta);
    tile.append(copy);

    const arrow = document.createElement('span');
    arrow.className = 'tile-arrow';
    arrow.setAttribute('aria-hidden', 'true');
    arrow.innerHTML = '<svg viewBox="0 0 20 20"><path d="M6 14 14 6M7 6h7v7"/></svg>';
    tile.append(arrow);

    return tile;
  }

  const categories = api.getCategories().filter((category) => category.active !== false);
  grid.replaceChildren(...categories.map(renderCategory));

  if (total) total.textContent = categories.length === 1 ? '1 category' : `${categories.length} categories`;
  if (note) {
    const state = api.getCatalogState();
    const source = state.customised ? 'Updated catalog' : 'Catalog';
    note.textContent = `${source} · ${state.services} services`;
  }
})();
