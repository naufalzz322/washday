(() => {
  const api = window.WashdayCatalog;
  const form = document.querySelector('#service-form');
  if (!api || !form) return;

  const params = new URLSearchParams(window.location.search);
  const category = api.getCategory(params.get('category'));
  const missing = document.querySelector('#category-admin-missing');
  const hero = document.querySelector('#owner-category-hero');
  const formCard = document.querySelector('#service-form-card');
  if (!category) {
    hero?.setAttribute('hidden', '');
    formCard?.setAttribute('hidden', '');
    missing?.removeAttribute('hidden');
    document.title = 'Category not found · Washday';
    return;
  }

  const back = document.querySelector('#service-back-link');
  const cancel = document.querySelector('#service-cancel');
  const categoryHref = `owner-category-services.html?category=${encodeURIComponent(category.id)}`;
  back.href = categoryHref;
  cancel.href = categoryHref;
  document.querySelector('#owner-category-name').textContent = category.name;
  document.querySelector('#owner-category-description').textContent = category.description;
  const heroImage = document.querySelector('#owner-category-image');
  if (category.image) heroImage.src = category.image;
  else hero.classList.add('has-no-image');
  heroImage.addEventListener('error', () => {
    heroImage.hidden = true;
    hero.classList.add('has-no-image');
  });

  const name = form.querySelector('#service-name');
  const description = form.querySelector('#service-description');
  const price = form.querySelector('#service-price');
  const unit = form.querySelector('#service-unit');
  const duration = form.querySelector('#service-duration');
  const imageInput = form.querySelector('#service-image');
  const active = form.querySelector('#service-active');
  const preview = document.querySelector('#service-image-preview');
  const feedback = document.querySelector('[data-service-feedback]');
  const submit = document.querySelector('#service-submit');
  const mode = document.querySelector('#service-form-mode');
  const requested = params.get('service') ? api.getService(params.get('service')) : null;
  const editing = requested && requested.categoryId === category.id ? requested : null;
  let imageData = editing?.image || '';
  document.title = `${category.name} · ${editing ? 'Edit service' : 'Add service'} · Washday`;

  const showPreview = (source) => {
    preview.replaceChildren();
    if (!source) {
      const empty = document.createElement('span');
      empty.textContent = 'No image';
      preview.append(empty);
      return;
    }
    const image = document.createElement('img');
    image.src = source;
    image.alt = '';
    preview.append(image);
  };
  if (editing) {
    name.value = editing.name;
    description.value = editing.description;
    price.value = api.formatPrice(editing.price);
    unit.value = editing.unit;
    duration.value = editing.duration;
    active.checked = editing.active !== false;
    showPreview(imageData);
    document.querySelector('#service-form-title').textContent = 'Edit service';
    mode.textContent = 'Editing';
    submit.textContent = 'Save changes';
  }

  imageInput.addEventListener('change', async () => {
    const file = imageInput.files?.[0];
    if (!file) {
      imageData = editing?.image || '';
      showPreview(imageData);
      return;
    }
    if (file.size > 8 * 1024 * 1024) {
      imageInput.value = '';
      imageData = editing?.image || '';
      showPreview(imageData);
      feedback.textContent = 'Choose an image smaller than 8 MB.';
      return;
    }
    feedback.textContent = 'Resizing the image locally…';
    try {
      imageData = await api.compressImage(file);
      showPreview(imageData);
      feedback.textContent = 'Image ready.';
    } catch (error) {
      imageInput.value = '';
      imageData = editing?.image || '';
      showPreview(imageData);
      feedback.textContent = error.message;
    }
  });

  form.addEventListener('submit', (event) => {
    event.preventDefault();
    const payload = {
      name: name.value,
      description: description.value,
      price: price.value,
      unit: unit.value,
      duration: duration.value,
      image: imageData,
      active: active.checked
    };
    try {
      const saved = editing
        ? api.updateService(editing.id, payload)
        : api.addService({ ...payload, categoryId: category.id });
      window.location.href = `${categoryHref}&saved=${encodeURIComponent(saved.name)}`;
    } catch (error) {
      feedback.textContent = error.message;
    }
  });
})();
