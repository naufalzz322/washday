(() => {
  const api = window.WashdayCatalog;
  const list = document.querySelector('#service-list');
  if (!api || !list) return;

  const hero = document.querySelector('#category-hero');
  const heroImage = document.querySelector('#category-image');
  const name = document.querySelector('#category-name');
  const description = document.querySelector('#category-description');
  const count = document.querySelector('#category-count');
  const serviceCount = document.querySelector('#service-count');
  const empty = document.querySelector('#service-empty');
  const summary = document.querySelector('#selection-summary');
  const missing = document.querySelector('#category-missing');
  const serviceCard = document.querySelector('#service-card');
  const serviceTitle = document.querySelector('#service-title');

  const params = new URLSearchParams(window.location.search);
  const categoryId = params.get('category');
  const category = categoryId ? api.getCategory(categoryId) : null;

  function showMissing() {
    hero?.setAttribute('hidden', '');
    serviceCard?.setAttribute('hidden', '');
    missing?.removeAttribute('hidden');
    if (name) name.textContent = 'Category not found';
    document.title = 'Category not found · Washday';
  }

  if (!category || category.active === false) {
    showMissing();
    return;
  }

  document.title = `${category.name} services · Washday`;
  if (name) name.textContent = category.name;
  if (description) description.textContent = category.description;
  if (heroImage) {
    heroImage.src = category.image;
    heroImage.alt = '';
    heroImage.addEventListener('error', () => {
      heroImage.hidden = true;
      hero?.classList.add('has-no-image');
    });
  }

  const services = api.getServices(category.id).filter((service) => service.active !== false);
  const serviceWord = services.length === 1 ? '1 service' : `${services.length} services`;
  if (count) count.textContent = serviceWord;
  if (serviceCount) serviceCount.textContent = String(services.length);
  if (serviceTitle) serviceTitle.textContent = services.length ? 'Choose a service' : 'No services yet';

  function serviceIcon() {
    const wrap = document.createElement('span');
    wrap.className = 'catalog-thumb';
    wrap.setAttribute('aria-hidden', 'true');
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('viewBox', '0 0 24 24');
    svg.innerHTML = '<path d="M4 7h16v13H4zM4 10h16M8 4v6m8-6v6"/><path d="M8 14h3m2 0h3"/>';
    wrap.append(svg);
    return wrap;
  }

  function renderService(service) {
    const button = document.createElement('button');
    button.className = 'service-choice';
    button.type = 'button';
    button.dataset.serviceId = service.id;
    button.setAttribute('aria-pressed', 'false');

    const thumb = serviceIcon();
    const image = document.createElement('img');
    image.src = service.image || category.image;
    image.alt = '';
    image.loading = 'lazy';
    image.addEventListener('error', () => thumb.classList.add('has-no-image'));
    thumb.append(image);
    button.append(thumb);

    const copy = document.createElement('span');
    copy.className = 'service-choice-copy';

    const top = document.createElement('span');
    top.className = 'service-choice-top';
    const title = document.createElement('strong');
    title.textContent = service.name;
    const rate = document.createElement('span');
    rate.className = 'service-rate';
    rate.append(document.createTextNode(api.formatPrice(service.price) + ' '));
    const unit = document.createElement('small');
    unit.textContent = `/ ${api.unitLabel(service.unit)}`;
    rate.append(unit);
    top.append(title, rate);

    const desc = document.createElement('span');
    desc.className = 'service-description';
    desc.textContent = service.description;

    const meta = document.createElement('span');
    meta.className = 'service-meta';
    const duration = document.createElement('span');
    duration.textContent = `Ready in ${service.duration}`;
    const available = document.createElement('span');
    available.textContent = 'Available';
    meta.append(duration, available);

    copy.append(top, desc, meta);
    button.append(copy);

    const check = document.createElement('span');
    check.className = 'service-check';
    check.setAttribute('aria-hidden', 'true');
    check.innerHTML = '<svg viewBox="0 0 20 20"><path d="m4.5 10 3.5 3.5L15.5 6"/></svg>';
    button.append(check);

    button.addEventListener('click', () => {
      const wasSelected = button.getAttribute('aria-pressed') === 'true';
      list.querySelectorAll('.service-choice').forEach((choice) => {
        choice.setAttribute('aria-pressed', 'false');
      });
      if (!wasSelected) button.setAttribute('aria-pressed', 'true');
      if (!summary) return;
      if (wasSelected) {
        summary.hidden = true;
        summary.textContent = '';
        return;
      }
      summary.textContent = `${service.name} selected · ${api.formatRate(service)}`;
      summary.hidden = false;
    });

    return button;
  }

  list.replaceChildren(...services.map(renderService));
  if (empty) empty.hidden = services.length > 0;
  if (count) count.textContent = serviceWord;
})();
