(() => {
  const api = window.WashdayCatalog;
  const form = document.querySelector('#category-form');
  if (!api || !form) return;

  const nameInput = form.querySelector('#category-name');
  const descriptionInput = form.querySelector('#category-description');
  const imageInput = form.querySelector('#category-image');
  const preview = document.querySelector('#category-image-preview');
  const feedback = document.querySelector('[data-category-feedback]');
  let imageData = '';

  function showPreview(source) {
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
  }

  imageInput?.addEventListener('change', async () => {
    const file = imageInput.files?.[0];
    if (!file) {
      imageData = '';
      showPreview('');
      return;
    }
    if (file.size > 8 * 1024 * 1024) {
      imageInput.value = '';
      imageData = '';
      showPreview('');
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
      imageData = '';
      showPreview('');
      feedback.textContent = error.message;
    }
  });

  form.addEventListener('submit', (event) => {
    event.preventDefault();
    try {
      const category = api.addCategory({
        name: nameInput.value,
        description: descriptionInput.value,
        image: imageData
      });
      window.location.href = `owner-category-services.html?category=${encodeURIComponent(category.id)}`;
    } catch (error) {
      feedback.textContent = error.message;
    }
  });
})();
