(() => {
  const api = window.WashdayCatalog;
  const categoryId = new URLSearchParams(window.location.search).get('category');
  const category = categoryId ? api?.getCategory(categoryId) : null;
  const hero = document.querySelector('#owner-category-hero');
  const listCard = document.querySelector('#service-list-card');
  const missing = document.querySelector('#category-admin-missing');
  const list = document.querySelector('#service-admin-list');
  if (!api || !category) {
    hero?.setAttribute('hidden', '');
    listCard?.setAttribute('hidden', '');
    missing?.removeAttribute('hidden');
    document.title = 'Category not found · Washday';
    return;
  }

  document.title = `${category.name} services · Washday`;
  document.querySelector('#owner-category-name').textContent = category.name;
  document.querySelector('#owner-category-description').textContent = category.description;
  const heroImage = document.querySelector('#owner-category-image');
  if (category.image) heroImage.src = category.image;
  else hero.classList.add('has-no-image');
  heroImage.addEventListener('error', () => {
    heroImage.hidden = true;
    hero.classList.add('has-no-image');
  });

  const addLink = document.querySelector('#add-service-link');
  addLink.href = `add-service.html?category=${encodeURIComponent(category.id)}`;
  const services = api.getServices(category.id);
  const activeCount = services.filter((service) => service.active !== false).length;
  document.querySelector('#owner-category-count').textContent = services.length === 1 ? '1 service' : `${services.length} services`;
  document.querySelector('#service-list-count').textContent = `${activeCount} available`;

  const icon = () => {
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('viewBox', '0 0 24 24');
    svg.innerHTML = '<path d="M4 7h16v13H4zM4 10h16M8 4v6m8-6v6"/><path d="M8 14h3m2 0h3"/>';
    return svg;
  };
  const cards = services.map((service) => {
    const card = document.createElement('article');
    card.className = 'admin-service';
    const thumb = document.createElement('span');
    thumb.className = 'catalog-thumb';
    thumb.setAttribute('aria-hidden', 'true');
    thumb.append(icon());
    const imageSource = service.image || category.image;
    if (imageSource) {
      const image = document.createElement('img');
      image.src = imageSource;
      image.alt = '';
      image.loading = 'lazy';
      image.addEventListener('error', () => thumb.classList.add('has-no-image'));
      thumb.append(image);
    } else thumb.classList.add('has-no-image');
    card.append(thumb);
    const copy = document.createElement('span');
    copy.className = 'admin-service-copy';
    const name = document.createElement('strong');
    name.textContent = service.name;
    const description = document.createElement('small');
    description.textContent = service.description;
    copy.append(name, description);
    card.append(copy);
    const foot = document.createElement('div');
    foot.className = 'admin-service-foot';
    const tags = document.createElement('span');
    tags.className = 'admin-service-tags';
    const tag = (text, tone = 'neutral') => {
      const value = document.createElement('span');
      value.className = `rp-status rp-status-${tone}`;
      value.textContent = text;
      return value;
    };
    tags.append(
      tag(api.formatRate(service)),
      tag(service.duration),
      service.active === false ? tag('Hidden', 'warning') : tag('Available')
    );
    const edit = document.createElement('a');
    edit.className = 'rp-button rp-button-secondary';
    edit.href = `add-service.html?category=${encodeURIComponent(category.id)}&service=${encodeURIComponent(service.id)}`;
    edit.textContent = 'Edit';
    foot.append(tags, edit);
    card.append(foot);
    return card;
  });
  list.replaceChildren(...cards);
  list.hidden = services.length === 0;
  document.querySelector('#service-admin-empty').hidden = services.length > 0;

  const saved = new URLSearchParams(window.location.search).get('saved');
  if (saved) {
    const status = document.createElement('p');
    status.className = 'rp-feedback';
    status.setAttribute('role', 'status');
    status.textContent = `${saved} saved.`;
    listCard.insertBefore(status, list);
  }
})();
