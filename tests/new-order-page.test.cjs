const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');

const read = (path) => fs.readFileSync(path, 'utf8');
const html = read('prototype/pages/new-order.html');
const categoryHtml = read('prototype/pages/category-services.html');
const css = read('prototype/assets/css/new-order.css');
const catalogCss = read('prototype/assets/css/catalog.css');

test('new-order page has a home return link and category-first instructions', () => {
  assert.match(html, /href="customer-home\.html"/);
  assert.match(html, /Choose a category/i);
  assert.match(html, /then pick the service/i);
});

test('new-order page exposes the four catalog categories as links to the category page', () => {
  assert.equal((html.match(/class="category-tile"/g) || []).length, 4);
  for (const id of ['shirts', 'pants', 'dresses', 'bedding']) {
    assert.match(html, new RegExp(`href="category-services\\.html\\?category=${id}"`));
  }
  assert.match(html, /class="category-meta"/);
  assert.match(html, /id="catalog-note" aria-live="polite"/);
  assert.doesNotMatch(html, /class="service-option"|id="service-picker"/);
});

test('new-order page loads the shared catalog store and the category renderer', () => {
  assert.match(html, /\.\.\/assets\/js\/catalog-store\.js/);
  assert.match(html, /\.\.\/assets\/js\/new-order\.js/);
  assert.doesNotMatch(html, /order-selection\.js/);
  assert.doesNotMatch(html, /https?:\/\//);
});

test('category tile links keep a usable tap target and local-only styling', () => {
  const tileRule = css.match(/\.category-tile\s*\{([^}]*)\}/s)?.[1] ?? '';
  const minHeight = Number(tileRule.match(/min-height:\s*(\d+)px/)?.[1] ?? 0);
  assert.ok(minHeight >= 44, `category tap target must be at least 44px; got ${minHeight}px`);
  assert.match(css, /category-copy/);
  assert.match(css, /category-meta/);
});

test('category page lists services with a selection summary and pricing note', () => {
  assert.match(categoryHtml, /id="category-hero"/);
  assert.match(categoryHtml, /id="service-list"/);
  assert.match(categoryHtml, /id="selection-summary" aria-live="polite"/);
  assert.match(categoryHtml, /Pricing/);
  assert.match(categoryHtml, /final total is confirmed at weighing/i);
  assert.doesNotMatch(categoryHtml, /Preview only|sample category/i);
  assert.match(categoryHtml, /\.\.\/assets\/js\/catalog-store\.js/);
  assert.match(categoryHtml, /\.\.\/assets\/js\/category-services\.js/);
  assert.match(categoryHtml, /\.\.\/assets\/css\/catalog\.css/);
});

test('category service choices keep a usable tap target and selected state', () => {
  const choiceRule = catalogCss.match(/\.service-choice\s*\{([^}]*)\}/s)?.[1] ?? '';
  const minHeight = Number(choiceRule.match(/min-height:\s*(\d+)px/)?.[1] ?? 0);
  assert.ok(minHeight >= 44, `service tap target must be at least 44px; got ${minHeight}px`);
  assert.match(catalogCss, /aria-pressed="true"/);
  assert.match(catalogCss, /catalog-selection/);
});
