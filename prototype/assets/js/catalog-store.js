((root, factory) => {
  const api = factory(root);
  if (typeof module === 'object' && module.exports) module.exports = api;
  if (root) root.WashdayCatalog = api;
})(typeof globalThis === 'undefined' ? this : globalThis, (root) => {
  const CATALOG_KEY = 'washday.catalog.v1';
  const AUDIT_KEY = 'washday.catalog.audit.v1';
  const STORAGE_VERSION = 1;
  const MAX_AUDIT_EVENTS = 40;

  const DEFAULT_CATEGORIES = [
    {
      id: 'shirts',
      name: 'Shirts',
      description: 'Everyday shirts, blouses and light tops, finished neatly.',
      image: '../assets/images/hero-shirt.jpg',
      active: true
    },
    {
      id: 'pants',
      name: 'Pants',
      description: 'Trousers, jeans and casual bottoms, washed and folded.',
      image: '../assets/images/category-pants.jpg',
      active: true
    },
    {
      id: 'dresses',
      name: 'Dresses',
      description: 'Dresses, skirts and delicate pieces that need a gentler clean.',
      image: '../assets/images/category-dresses.jpg',
      active: true
    },
    {
      id: 'bedding',
      name: 'Bedding',
      description: 'Sheets, duvet covers and household linen for a fresh reset.',
      image: '../assets/images/category-bedding.jpg',
      active: true
    }
  ];

  const DEFAULT_SERVICES = [
    {
      id: 'shirts-wash-fold',
      categoryId: 'shirts',
      name: 'Wash & fold',
      description: 'Everyday shirts washed, dried and neatly folded.',
      image: '',
      price: 2.00,
      unit: 'kg',
      duration: '6 h',
      active: true
    },
    {
      id: 'shirts-press-only',
      categoryId: 'shirts',
      name: 'Press only',
      description: 'Already clean? Returned crisp on a hanger.',
      image: '',
      price: 3.50,
      unit: 'item',
      duration: '24 h',
      active: true
    },
    {
      id: 'shirts-express',
      categoryId: 'shirts',
      name: 'Express wash',
      description: 'Priority wash for same-day pickup.',
      image: '',
      price: 4.00,
      unit: 'kg',
      duration: '3 h',
      active: true
    },
    {
      id: 'pants-wash-fold',
      categoryId: 'pants',
      name: 'Wash & fold',
      description: 'Trousers and jeans washed, dried and folded.',
      image: '',
      price: 2.00,
      unit: 'kg',
      duration: '6 h',
      active: true
    },
    {
      id: 'pants-press-only',
      categoryId: 'pants',
      name: 'Press only',
      description: 'Neatly pressed with a sharp centre crease.',
      image: '',
      price: 3.00,
      unit: 'item',
      duration: '24 h',
      active: true
    },
    {
      id: 'pants-express',
      categoryId: 'pants',
      name: 'Express wash',
      description: 'Fast turnaround for a favourite pair.',
      image: '',
      price: 4.00,
      unit: 'kg',
      duration: '3 h',
      active: true
    },
    {
      id: 'dresses-dry-clean',
      categoryId: 'dresses',
      name: 'Dry clean',
      description: 'Gentle solvent clean for structured or delicate dresses.',
      image: '',
      price: 8.00,
      unit: 'item',
      duration: '48 h',
      active: true
    },
    {
      id: 'dresses-gentle-wash',
      categoryId: 'dresses',
      name: 'Gentle wash',
      description: 'Low-heat wash for everyday dresses and skirts.',
      image: '',
      price: 3.00,
      unit: 'kg',
      duration: '24 h',
      active: true
    },
    {
      id: 'dresses-press-only',
      categoryId: 'dresses',
      name: 'Press only',
      description: 'Light pressing for a smooth finish.',
      image: '',
      price: 4.00,
      unit: 'item',
      duration: '24 h',
      active: true
    },
    {
      id: 'bedding-wash-fold',
      categoryId: 'bedding',
      name: 'Wash & fold',
      description: 'Sheets and covers washed, dried and folded.',
      image: '',
      price: 2.50,
      unit: 'kg',
      duration: '8 h',
      active: true
    },
    {
      id: 'bedding-deep-clean',
      categoryId: 'bedding',
      name: 'Deep clean',
      description: 'A warmer, longer cycle for household linen.',
      image: '',
      price: 3.20,
      unit: 'kg',
      duration: '24 h',
      active: true
    },
    {
      id: 'bedding-express',
      categoryId: 'bedding',
      name: 'Express wash',
      description: 'Priority bedding for a quick room reset.',
      image: '',
      price: 4.50,
      unit: 'kg',
      duration: '4 h',
      active: true
    }
  ];

  const memoryStorage = new Map();
  let eventSequence = 0;

  const clone = (value) => JSON.parse(JSON.stringify(value));
  const defaultCategories = Object.freeze(DEFAULT_CATEGORIES.map((item) => Object.freeze({ ...item })));
  const defaultServices = Object.freeze(DEFAULT_SERVICES.map((item) => Object.freeze({ ...item })));

  function storageGet(key) {
    try {
      const value = root?.sessionStorage?.getItem(key);
      if (value !== null && value !== undefined) return value;
    } catch {
      /* file:// and private modes can block storage; the in-memory copy still works. */
    }
    return memoryStorage.has(key) ? memoryStorage.get(key) : null;
  }

  function storageSet(key, value) {
    memoryStorage.set(key, value);
    try {
      root?.sessionStorage?.setItem(key, value);
    } catch {
      /* Keep the in-memory copy only. */
    }
  }

  function storageRemove(key) {
    memoryStorage.delete(key);
    try {
      root?.sessionStorage?.removeItem(key);
    } catch {
      /* Ignore blocked storage. */
    }
  }

  function statusToStorage() {
    return storageGet(CATALOG_KEY) !== null;
  }

  function readCatalog() {
    const raw = storageGet(CATALOG_KEY);
    if (!raw) return null;
    try {
      const parsed = JSON.parse(raw);
      if (
        !parsed ||
        parsed.version !== STORAGE_VERSION ||
        !Array.isArray(parsed.categories) ||
        !Array.isArray(parsed.services)
      ) {
        return null;
      }
      return {
        categories: parsed.categories.filter((item) => item && typeof item.id === 'string'),
        services: parsed.services.filter((item) => item && typeof item.id === 'string')
      };
    } catch {
      return null;
    }
  }

  function writeCatalog(catalog) {
    storageSet(CATALOG_KEY, JSON.stringify({
      version: STORAGE_VERSION,
      categories: catalog.categories,
      services: catalog.services
    }));
  }

  function getCatalog() {
    const stored = readCatalog();
    if (stored) return clone(stored);
    return { categories: clone(defaultCategories), services: clone(defaultServices) };
  }

  function getCategories() {
    return getCatalog().categories;
  }

  function getCategory(id) {
    return getCategories().find((category) => category.id === id) ?? null;
  }

  function getServices(categoryId) {
    const services = getCatalog().services;
    return typeof categoryId === 'string'
      ? services.filter((service) => service.categoryId === categoryId)
      : services;
  }

  function getService(id) {
    return getCatalog().services.find((service) => service.id === id) ?? null;
  }

  function slugify(value) {
    return String(value ?? '')
      .normalize('NFKD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '')
      .slice(0, 48);
  }

  function uniqueId(catalog, base) {
    const ids = new Set([
      ...catalog.categories.map((category) => category.id),
      ...catalog.services.map((service) => service.id)
    ]);
    const seed = slugify(base) || 'item';
    let id = seed;
    let suffix = 2;
    while (ids.has(id)) {
      id = `${seed}-${suffix}`;
      suffix += 1;
    }
    return id;
  }

  function readText(value, label, maxLength) {
    const text = String(value ?? '').trim();
    if (!text) throw new TypeError(`${label} is required.`);
    if (text.length > maxLength) throw new RangeError(`${label} must be ${maxLength} characters or fewer.`);
    return text;
  }

  function readImage(value) {
    const image = String(value ?? '').trim();
    if (!image) return '';
    if (/^data:image\/(?:png|jpe?g|webp|gif);base64,/i.test(image)) return image;
    if (/^\.\.\/assets\/images\/[a-z0-9._-]+$/i.test(image)) return image;
    throw new TypeError('Use a JPG or PNG image.');
  }

  function readPrice(value) {
    const price = typeof value === 'number' ? value : Number(String(value ?? '').trim().replace(',', '.'));
    if (!Number.isFinite(price) || price < 0) throw new RangeError('Price must be a non-negative number.');
    return Math.round((price + Number.EPSILON) * 100) / 100;
  }

  function readUnit(value) {
    const unit = String(value ?? '').trim().toLowerCase();
    if (!['kg', 'item', 'load'].includes(unit)) throw new RangeError('Unit must be kg, item or load.');
    return unit;
  }

  function unitLabel(unit) {
    if (unit === 'kg') return 'kg';
    if (unit === 'item') return 'item';
    return 'load';
  }

  function formatPrice(value) {
    const price = Number(value);
    return Number.isFinite(price) ? price.toFixed(2) : '—';
  }

  function formatRate(service) {
    return `${formatPrice(service.price)} / ${unitLabel(service.unit)}`;
  }

  function imageSummary(image) {
    if (!image) return 'No image';
    if (/^data:/i.test(image)) return 'Uploaded image';
    return 'Shop image';
  }

  function boolLabel(value) {
    return value ? 'Yes' : 'No';
  }

  function change(field, label, from, to) {
    if (String(from) === String(to)) return null;
    return { field, label, from: String(from), to: String(to) };
  }

  function recordEvent(action, entity, entityName, changes) {
    const events = readEvents();
    eventSequence += 1;
    events.unshift({
      id: `ev-${Date.now().toString(36)}-${eventSequence}`,
      at: new Date().toISOString(),
      actor: 'Owner',
      action,
      entity,
      entityName,
      changes: changes.filter(Boolean)
    });
    storageSet(AUDIT_KEY, JSON.stringify(events.slice(0, MAX_AUDIT_EVENTS)));
  }

  function readEvents() {
    const raw = storageGet(AUDIT_KEY);
    if (!raw) return [];
    try {
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }

  function getSessionAuditEvents() {
    return clone(readEvents());
  }

  function clearAuditEvents() {
    storageRemove(AUDIT_KEY);
  }

  function resetCatalog() {
    storageRemove(CATALOG_KEY);
  }

  function resetAll() {
    resetCatalog();
    clearAuditEvents();
  }

  function addCategory(input = {}) {
    const catalog = getCatalog();
    const category = {
      id: uniqueId(catalog, readText(input.name, 'Category name', 60)),
      name: readText(input.name, 'Category name', 60),
      description: readText(input.description, 'Category description', 220),
      image: readImage(input.image),
      active: input.active !== false
    };
    catalog.categories.push(category);
    writeCatalog(catalog);
    recordEvent('category.created', 'category', category.name, [
      change('name', 'Name', '—', category.name),
      change('description', 'Description', '—', category.description),
      change('image', 'Image', '—', imageSummary(category.image)),
      change('active', 'Available', '—', boolLabel(category.active))
    ]);
    return clone(category);
  }

  function updateCategory(id, patch = {}) {
    const catalog = getCatalog();
    const index = catalog.categories.findIndex((category) => category.id === id);
    if (index < 0) throw new RangeError(`Unknown category: ${id}`);
    const current = catalog.categories[index];
    const next = { ...current };
    if (Object.prototype.hasOwnProperty.call(patch, 'name')) {
      next.name = readText(patch.name, 'Category name', 60);
    }
    if (Object.prototype.hasOwnProperty.call(patch, 'description')) {
      next.description = readText(patch.description, 'Category description', 220);
    }
    if (Object.prototype.hasOwnProperty.call(patch, 'image')) next.image = readImage(patch.image);
    if (Object.prototype.hasOwnProperty.call(patch, 'active')) next.active = Boolean(patch.active);

    const changes = [
      change('name', 'Name', current.name, next.name),
      change('description', 'Description', current.description, next.description),
      change('image', 'Image', imageSummary(current.image), imageSummary(next.image)),
      change('active', 'Available', boolLabel(current.active), boolLabel(next.active))
    ];
    catalog.categories[index] = next;
    writeCatalog(catalog);
    if (changes.some(Boolean)) {
      recordEvent('category.updated', 'category', next.name, changes);
    }
    return clone(next);
  }

  function addService(input = {}) {
    const catalog = getCatalog();
    const categoryId = readText(input.categoryId, 'Category', 60);
    const category = catalog.categories.find((item) => item.id === categoryId);
    if (!category) throw new RangeError(`Unknown category: ${categoryId}`);
    const name = readText(input.name, 'Service name', 60);
    const service = {
      id: uniqueId(catalog, `${categoryId}-${slugify(name)}`),
      categoryId,
      name,
      description: readText(input.description, 'Service description', 220),
      image: readImage(input.image),
      price: readPrice(input.price),
      unit: readUnit(input.unit),
      duration: readText(input.duration, 'Duration', 40),
      active: input.active !== false
    };
    catalog.services.push(service);
    writeCatalog(catalog);
    recordEvent('service.created', 'service', `${service.name} · ${category.name}`, [
      change('category', 'Category', '—', category.name),
      change('name', 'Name', '—', service.name),
      change('price', 'Price', '—', formatRate(service)),
      change('duration', 'Duration', '—', service.duration),
      change('description', 'Description', '—', service.description),
      change('image', 'Image', '—', imageSummary(service.image)),
      change('active', 'Available', '—', boolLabel(service.active))
    ]);
    return clone(service);
  }

  function updateService(id, patch = {}) {
    const catalog = getCatalog();
    const index = catalog.services.findIndex((service) => service.id === id);
    if (index < 0) throw new RangeError(`Unknown service: ${id}`);
    const current = catalog.services[index];
    const next = { ...current };
    if (Object.prototype.hasOwnProperty.call(patch, 'name')) {
      next.name = readText(patch.name, 'Service name', 60);
    }
    if (Object.prototype.hasOwnProperty.call(patch, 'description')) {
      next.description = readText(patch.description, 'Service description', 220);
    }
    if (Object.prototype.hasOwnProperty.call(patch, 'image')) next.image = readImage(patch.image);
    if (Object.prototype.hasOwnProperty.call(patch, 'price')) next.price = readPrice(patch.price);
    if (Object.prototype.hasOwnProperty.call(patch, 'unit')) next.unit = readUnit(patch.unit);
    if (Object.prototype.hasOwnProperty.call(patch, 'duration')) {
      next.duration = readText(patch.duration, 'Duration', 40);
    }
    if (Object.prototype.hasOwnProperty.call(patch, 'active')) next.active = Boolean(patch.active);

    const changes = [
      change('name', 'Name', current.name, next.name),
      change('description', 'Description', current.description, next.description),
      change('price', 'Price', formatRate(current), formatRate(next)),
      change('duration', 'Duration', current.duration, next.duration),
      change('image', 'Image', imageSummary(current.image), imageSummary(next.image)),
      change('active', 'Available', boolLabel(current.active), boolLabel(next.active))
    ];
    catalog.services[index] = next;
    writeCatalog(catalog);
    if (changes.some(Boolean)) {
      const category = catalog.categories.find((item) => item.id === next.categoryId);
      recordEvent('service.updated', 'service', `${next.name} · ${category?.name ?? 'Category'}`, changes);
    }
    return clone(next);
  }

  function readFileAsDataUrl(file) {
    return new Promise((resolve, reject) => {
      if (typeof FileReader === 'undefined') {
        reject(new Error('Image preview needs a browser file reader.'));
        return;
      }
      const reader = new FileReader();
      reader.onload = () => resolve(String(reader.result));
      reader.onerror = () => reject(new Error('The image could not be read.'));
      reader.readAsDataURL(file);
    });
  }

  function loadBrowserImage(source) {
    return new Promise((resolve, reject) => {
      if (typeof Image === 'undefined') {
        reject(new Error('Image preview needs a browser.'));
        return;
      }
      const image = new Image();
      image.onload = () => resolve(image);
      image.onerror = () => reject(new Error('The selected file is not a readable image.'));
      image.src = source;
    });
  }

  async function compressImage(file, options = {}) {
    if (!file || !/^image\//i.test(file.type ?? '')) {
      throw new TypeError('Choose an image file.');
    }
    const source = await readFileAsDataUrl(file);
    const maxEdge = Number.isFinite(options.maxEdge) ? options.maxEdge : 720;
    const quality = Number.isFinite(options.quality) ? options.quality : 0.72;
    if (typeof document === 'undefined') return source;

    const image = await loadBrowserImage(source);
    const width = image.naturalWidth || image.width;
    const height = image.naturalHeight || image.height;
    if (!width || !height) return source;
    const scale = Math.min(1, maxEdge / Math.max(width, height));
    const canvas = document.createElement('canvas');
    canvas.width = Math.max(1, Math.round(width * scale));
    canvas.height = Math.max(1, Math.round(height * scale));
    const context = canvas.getContext('2d');
    if (!context) return source;
    context.fillStyle = '#ffffff';
    context.fillRect(0, 0, canvas.width, canvas.height);
    context.drawImage(image, 0, 0, canvas.width, canvas.height);
    return canvas.toDataURL('image/jpeg', quality);
  }

  function getCatalogState() {
    const catalog = getCatalog();
    return {
      categories: catalog.categories.length,
      activeCategories: catalog.categories.filter((category) => category.active).length,
      services: catalog.services.length,
      customised: statusToStorage(),
      auditEvents: readEvents().length
    };
  }

  return {
    CATALOG_KEY,
    AUDIT_KEY,
    defaultCategories,
    defaultServices,
    getCatalog,
    getCategories,
    getCategory,
    getServices,
    getService,
    addCategory,
    updateCategory,
    addService,
    updateService,
    resetCatalog,
    resetAll,
    getSessionAuditEvents,
    clearAuditEvents,
    getCatalogState,
    compressImage,
    slugify,
    formatPrice,
    formatRate,
    unitLabel
  };
});
