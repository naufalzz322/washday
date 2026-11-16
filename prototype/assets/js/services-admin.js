(() => {
  const api = window.WashdayCatalog;
  const list = document.querySelector('#category-admin-list');
  if (!api || !list) return;
  const countLabel = document.querySelector('#category-admin-count');
  const sourceLabel = document.querySelector('#catalog-source-label');

  function categoryIcon() {
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('viewBox', '0 0 24 24');
    svg.innerHTML = '<path d="M4 7h16v13H4zM4 10h16M8 4v6m8-6v6"/><path d="M8 14h3m2 0h3"/>';
    return svg;
  }

  function renderCategories() {
    const categories = api.getCategories();
    const cards = categories.map((category) => {
      const services = api.getServices(category.id);
      const activeServices = services.filter((service) => service.active !== false);
      const card = document.createElement('a');
      card.className = 'admin-category-card';
      card.href = `owner-category-services.html?category=${encodeURIComponent(category.id)}`;
      card.dataset.categoryCard = category.id;

      const thumb = document.createElement('span');
      thumb.className = 'catalog-thumb';
      thumb.setAttribute('aria-hidden', 'true');
      thumb.append(categoryIcon());
      if (category.image) {
        const image = document.createElement('img');
        image.src = category.image;
        image.alt = '';
        image.loading = 'lazy';
        image.addEventListener('error', () => thumb.classList.add('has-no-image'));
        thumb.append(image);
      } else {
        thumb.classList.add('has-no-image');
      }
      card.append(thumb);

      const copy = document.createElement('span');
      copy.className = 'admin-category-copy';
      const title = document.createElement('strong');
      title.textContent = category.name;
      const note = document.createElement('small');
      note.textContent = category.description;
      copy.append(title, note);
      card.append(copy);

      const count = document.createElement('span');
      count.className = 'rp-count';
      count.textContent = activeServices.length === 1 ? '1 svc' : `${activeServices.length} svc`;
      if (category.active === false) {
        count.textContent = 'Hidden';
        count.classList.add('is-hidden');
      }
      card.append(count);

      const arrow = document.createElement('span');
      arrow.className = 'admin-category-arrow';
      arrow.setAttribute('aria-hidden', 'true');
      arrow.textContent = '›';
      card.append(arrow);
      return card;
    });

    list.replaceChildren(...cards);
    if (countLabel) countLabel.textContent = categories.length === 1 ? '1 category' : `${categories.length} categories`;
    const state = api.getCatalogState();
    if (sourceLabel) {
      sourceLabel.textContent = state.customised ? 'Updated recently' : 'Default catalog';
    }
  }

  renderCategories();
})();
