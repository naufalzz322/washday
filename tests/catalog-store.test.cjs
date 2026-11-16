const { test, beforeEach } = require('node:test');
const assert = require('node:assert/strict');

const api = require('../prototype/assets/js/catalog-store.js');

beforeEach(() => {
  api.resetAll();
});

test('ships four image-backed categories and three services per category', () => {
  assert.deepEqual(api.defaultCategories.map((category) => category.id), ['shirts', 'pants', 'dresses', 'bedding']);
  assert.equal(api.defaultServices.length, 12);
  for (const category of api.defaultCategories) {
    assert.ok(category.name);
    assert.ok(category.description);
    assert.match(category.image, /^\.\.\/assets\/images\//);
    assert.equal(category.active, true);
    assert.equal(api.getServices(category.id).length, 3);
  }
  for (const service of api.defaultServices) {
    assert.ok(api.getCategory(service.categoryId), `${service.id} belongs to a category`);
    assert.ok(service.name);
    assert.ok(service.description);
    assert.ok(service.price >= 0);
    assert.ok(['kg', 'item', 'load'].includes(service.unit));
    assert.ok(service.duration);
    assert.equal(service.active, true);
  }
});

test('returns the current catalog and individual records', () => {
  const catalog = api.getCatalog();
  assert.equal(catalog.categories.length, 4);
  assert.equal(catalog.services.length, 12);
  assert.equal(api.getCategory('shirts').name, 'Shirts');
  assert.equal(api.getService('shirts-wash-fold').name, 'Wash & fold');
  assert.equal(api.getServices('bedding').length, 3);
  assert.equal(api.getServices().length, 12);
});

test('adds a category and records a session audit event', () => {
  const category = api.addCategory({
    name: 'Uniforms',
    description: 'Workwear and matching sets for local teams.',
    image: ''
  });
  assert.equal(category.name, 'Uniforms');
  assert.equal(category.active, true);
  assert.ok(api.getCategory(category.id));
  assert.equal(api.getCatalogState().categories, 5);

  const events = api.getSessionAuditEvents();
  assert.equal(events.length, 1);
  assert.equal(events[0].action, 'category.created');
  assert.equal(events[0].actor, 'Owner');
  assert.equal(events[0].entityName, 'Uniforms');
  assert.ok(events[0].changes.some((change) => change.label === 'Description'));
  assert.ok(events[0].changes.some((change) => change.label === 'Image' && change.to === 'No image'));
});

test('updates a category and keeps old and new values in the trace', () => {
  api.addCategory({
    name: 'Uniforms',
    description: 'Workwear and matching sets for local teams.',
    image: ''
  });
  const before = api.getSessionAuditEvents().length;
  const category = api.getCatalog().categories.find((item) => item.name === 'Uniforms');
  api.updateCategory(category.id, {
    name: 'Work uniforms',
    description: 'Workwear, aprons and matching sets for local teams.'
  });

  const updated = api.getCategory(category.id);
  assert.equal(updated.name, 'Work uniforms');
  const events = api.getSessionAuditEvents();
  assert.equal(events.length, before + 1);
  const change = events[0].changes.find((item) => item.field === 'name');
  assert.deepEqual(change, { field: 'name', label: 'Name', from: 'Uniforms', to: 'Work uniforms' });
});

test('adds and updates a service under its category with a priced audit diff', () => {
  const service = api.addService({
    categoryId: 'shirts',
    name: 'Steam finish',
    description: 'A light steam for a clean, soft finish.',
    image: '',
    price: '2.40',
    unit: 'item',
    duration: '12 h',
    active: true
  });
  assert.equal(service.categoryId, 'shirts');
  assert.equal(service.price, 2.4);
  assert.equal(service.unit, 'item');
  assert.equal(api.getServices('shirts').length, 4);

  const created = api.getSessionAuditEvents()[0];
  assert.equal(created.action, 'service.created');
  assert.ok(created.changes.some((item) => item.label === 'Price' && item.to === '2.40 / item'));
  assert.ok(created.changes.some((item) => item.label === 'Category' && item.to === 'Shirts'));

  api.updateService(service.id, { price: 2.75, unit: 'kg', active: false });
  const updated = api.getService(service.id);
  assert.equal(updated.price, 2.75);
  assert.equal(updated.unit, 'kg');
  assert.equal(updated.active, false);

  const changed = api.getSessionAuditEvents()[0];
  assert.equal(changed.action, 'service.updated');
  const price = changed.changes.find((item) => item.field === 'price');
  assert.deepEqual(price, { field: 'price', label: 'Price', from: '2.40 / item', to: '2.75 / kg' });
  assert.ok(changed.changes.some((item) => item.label === 'Available' && item.to === 'No'));
});

test('no-op updates do not add audit noise', () => {
  const category = api.getCategory('shirts');
  api.updateCategory(category.id, { name: category.name });
  assert.equal(api.getSessionAuditEvents().length, 0);
});

test('rejects invalid catalog input', () => {
  assert.throws(() => api.addCategory({ name: '', description: 'Text' }), /required/i);
  assert.throws(() => api.addCategory({ name: 'Shoes', description: '' }), /required/i);
  assert.throws(() => api.addCategory({ name: 'Shoes', description: 'Shoes', image: 'https://example.com/shoes.jpg' }), /image/i);
  assert.throws(() => api.addService({
    categoryId: 'missing', name: 'Wash', description: 'Wash', price: 1, unit: 'kg', duration: '6 h'
  }), /Unknown category/);
  assert.throws(() => api.addService({
    categoryId: 'shirts', name: 'Wash', description: 'Wash', price: -1, unit: 'kg', duration: '6 h'
  }), /Price/);
  assert.throws(() => api.addService({
    categoryId: 'shirts', name: 'Wash', description: 'Wash', price: 1, unit: 'sack', duration: '6 h'
  }), /Unit/);
});

test('resetAll restores the sample catalog and clears the session trace', () => {
  api.addCategory({ name: 'Temporary', description: 'Temporary category.' });
  api.clearAuditEvents();
  api.resetCatalog();
  assert.equal(api.getCatalogState().categories, 4);
  assert.equal(api.getCatalogState().services, 12);
  assert.equal(api.getCatalogState().customised, false);
  assert.equal(api.getSessionAuditEvents().length, 0);
});

test('formats prices, rates and units for the UI', () => {
  assert.equal(api.formatPrice(2), '2.00');
  assert.equal(api.formatPrice(2.5), '2.50');
  assert.equal(api.formatRate({ price: 3.5, unit: 'item' }), '3.50 / item');
  assert.equal(api.unitLabel('kg'), 'kg');
  assert.equal(api.slugify('Work uniforms & aprons'), 'work-uniforms-aprons');
});

test('compressImage rejects a non-image file', async () => {
  await assert.rejects(api.compressImage({ type: 'text/plain', size: 10 }), /image/i);
});
