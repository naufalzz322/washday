const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');

const html = fs.readFileSync('prototype/pages/customer-home.html', 'utf8');

test('Home New order action is a floating dock to the separate category page', () => {
  assert.match(html, /<a\b[^>]*\bclass="order-dock"[^>]*\bhref="new-order\.html"[^>]*>/s);
  assert.match(html, /<body class="has-order-dock"/);
  assert.doesNotMatch(html, /class="new-order-card"|new-order-button/);
});

test('Home retains the current READY order card without an order list', () => {
  assert.match(html, /class="order-card"/);
  assert.match(html, /LDR-0042/);
  assert.match(html, /<span class="status-dot"(?: aria-hidden="true")?><\/span> Ready/);
  assert.match(html, /class="progress-steps"/);
  assert.doesNotMatch(html, /class="order-disclosure"|How it works|class="process-step"/);
});

test('Home features the active voucher with its verified discount terms', () => {
  assert.match(html, /class="promo-card"/);
  assert.match(html, /Current offer/i);
  assert.match(html, /WELCOME10/);
  assert.match(html, /10%/);
  assert.match(html, /5\.00/);
  assert.match(html, /3\.00/);
  assert.match(html, /checked at weighing|applied at weighing/i);
  assert.doesNotMatch(html, /demo offer|expires|ends on|valid until|first order/i);
});

test('Home retains the loyalty progress card', () => {
  assert.match(html, /Loyalty card/);
  assert.match(html, /5\s*<span>\/\s*10<\/span>/);
});

test('Home references only local resources', () => {
  assert.doesNotMatch(html, /\b(?:src|href)=["']https?:\/\//i);
});
