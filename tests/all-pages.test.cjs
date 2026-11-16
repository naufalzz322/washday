const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const pages = path.join(__dirname, '..', 'prototype', 'pages');
const core = [
  'login.html', 'customer-home.html', 'clerk-home.html', 'owner-home.html',
  'new-order.html', 'category-services.html', 'order-detail.html', 'order-history.html',
  'loyalty.html', 'notifications.html', 'customer-vouchers.html', 'customer-profile.html',
  'order-queue.html', 'weigh-and-confirm.html', 'staff-order-detail.html',
  'new-order-for-customer.html', 'services-and-prices.html', 'owner-category-services.html',
  'add-category.html', 'add-service.html', 'vouchers.html', 'owner-orders.html', 'activity-log.html', 'settings.html',
  'shop-tools.html', 'owner-more.html'
];
const expected = ['index.html', ...core];

const readPage = (file) => fs.readFileSync(path.join(pages, file), 'utf8');
const readAsset = (file) => fs.readFileSync(path.join(__dirname, '..', 'prototype', 'assets', file), 'utf8');

test('project ships the 26 app screens and the welcome entry', () => {
  assert.equal(core.length, 26);
  for (const file of expected) assert.ok(fs.existsSync(path.join(pages, file)), `${file} should exist`);
  assert.ok(!fs.existsSync(path.join(pages, 'daily-summary.html')), 'Daily summary is retired in favour of Owner Home');
});

test('the welcome screen starts the app without review or demo copy', () => {
  const welcome = readPage('index.html');
  assert.equal((welcome.match(/<h1/g) || []).length, 1);
  assert.match(welcome, /href="login\.html"/);
  assert.doesNotMatch(welcome, /screens\.html|Screen index|Prototype screen index|rp-catalog|All screens|Reviewer|demo|prototype/i);
  const roleChooser = readPage('login.html');
  assert.match(roleChooser, /Customer/);
  assert.doesNotMatch(roleChooser, /screens\.html|seeded demo accounts|account service is connected|demo account|Demo only|Same demo view|Sample customer/i);
});

test('sign in offers labelled fields and a compact role account dropdown', () => {
  const html = readPage('login.html');
  assert.match(html, /<label for="login-email">Email<\/label>/);
  assert.match(html, /<label for="login-password">Password<\/label>/);
  assert.match(html, /type="email"/);
  assert.match(html, /type="password"/);
  assert.match(html, /<form class="login-form" action="customer-home\.html"/);
  assert.match(html, /Enter your email and password/);
  assert.doesNotMatch(html, /Demo only|credentials aren|sample Customer|demo account/i);
  assert.match(html, /class="login-reveal"/);
  assert.match(html, /src="\.\.\/assets\/js\/login\.js"/);
  assert.match(html, /<select id="login-account"/);
  assert.equal((html.match(/<option value="(?:customer-a|customer-b|clerk|owner)" data-destination=/g) || []).length, 4);
  assert.match(html, /<option value="clerk" data-destination="clerk-home\.html">Clerk/);
  assert.match(html, /<option value="owner" data-destination="owner-home\.html">Owner/);
  assert.doesNotMatch(html, /Continue|class="login-account-submit"/);
  assert.doesNotMatch(html, /demo-tools\.html/);
});

test('choosing a role fills the sign-in fields and retains its destination', () => {
  const script = readAsset('js/login.js');
  assert.match(script, /addEventListener\('change'/);
  assert.match(script, /customer\.a@washday\.test/);
  assert.match(script, /customer\.b@washday\.test/);
  assert.match(script, /clerk@washday\.test/);
  assert.match(script, /owner@washday\.test/);
  assert.match(script, /input\.value = account\.password/);
  assert.match(script, /loginForm && destination/);
});

test('every screen is reachable through the app from the welcome entry', () => {
  const targetFiles = (file) => {
    const html = readPage(file);
    const refs = [
      ...[...html.matchAll(/(?:href|src)=["']([^"']+\.html)(?:[?#][^"']*)?["']/gi)].map(([, href]) => href),
      ...[...html.matchAll(/<option\b[^>]*data-destination=["']([^"']+\.html)["']/gi)].map(([, href]) => href)
    ];
    return refs
      .map((href) => path.basename(href))
      .filter((name) => fs.existsSync(path.join(pages, name)));
  };
  const seen = new Set(['index.html']);
  const queue = ['index.html'];
  while (queue.length) {
    for (const file of targetFiles(queue.shift())) {
      if (!seen.has(file)) {
        seen.add(file);
        queue.push(file);
      }
    }
  }
  for (const file of expected) assert.ok(seen.has(file), `${file} should be reachable from index.html`);
  assert.ok(!fs.existsSync(path.join(pages, 'screens.html')), 'review-index pages are not part of the demo');
});

test('role screens keep review tooling out of the app chrome', () => {
  for (const file of core) {
    const html = readPage(file);
    assert.doesNotMatch(html, /Reviewer|All screens|role chooser/, `${file} should not show review tooling`);
  }
});

test('customer flow links to order detail, category services, promo, profile, and notifications', () => {
  const home = readPage('customer-home.html');
  assert.match(home, /href="order-detail\.html"/);
  assert.match(home, /href="new-order\.html"/);
  assert.match(home, /class="order-dock"/);
  assert.doesNotMatch(home, /new-order-card|new-order-button/);
  assert.match(home, /href="customer-vouchers\.html"/);
  assert.match(home, /href="customer-profile\.html"/);
  assert.match(home, /href="notifications\.html"/);
  assert.match(readPage('order-history.html'), /href="order-detail\.html"/);
  assert.match(readPage('customer-profile.html'), /href="loyalty\.html"/);
  assert.match(readPage('new-order.html'), /href="category-services\.html\?category=shirts"/);
});

test('role navigation uses the shared app shell and icon-plus-label tabs', () => {
  const navPages = core.filter((file) => !['login.html', 'category-services.html', 'new-order.html'].includes(file));
  for (const file of navPages) {
    const html = readPage(file);
    assert.match(html, /class="topbar"/i, `${file} uses the Home topbar shell`);
    assert.doesNotMatch(html, /class="statusline"/i, `${file} leaves device status chrome to the browser`);
    assert.match(html, /class="account-row"/i, `${file} includes the account row`);
    assert.match(html, /class="bottom-nav"/i, `${file} uses shared bottom navigation`);
    assert.ok(/class="nav-item[^\"]*"[^>]*>.*?<svg[^>]*>.*?<span>/s.test(html), `${file} nav items include icons and labels`);
    assert.match(html, /aria-current="page"/, `${file} shows a selected nav item`);
  }
});

test('the compact app shell is used on every page', () => {
  for (const file of expected) {
    const html = readPage(file);
    assert.match(html, /class="topbar"/i, `${file} has the shared app bar`);
    assert.doesNotMatch(html, /class="statusline"/i, `${file} does not fake a device status bar`);
  }
});

test('only Home and Orders carry the floating order dock', () => {
  const withDock = expected.filter((file) => /class="order-dock"/.test(readPage(file)));
  assert.deepEqual(withDock.sort(), ['customer-home.html', 'order-history.html']);
});

test('Orders replaces its inline start button with the floating order dock', () => {
  const orders = readPage('order-history.html');
  assert.match(orders, /<body class="rp-page has-order-dock"/);
  assert.match(orders, /<a class="order-dock" href="new-order\.html"/);
  assert.doesNotMatch(orders, /class="rp-button rp-button-primary" href="new-order\.html"/);
});

test('customer destinations reuse Home navigation icons and unread indicator', () => {
  const home = readPage('customer-home.html');
  const tabs = (html) => {
    const start = html.indexOf('<nav class="bottom-nav"');
    const end = html.indexOf('</nav>', start);
    const nav = start >= 0 && end >= 0 ? html.slice(start, end) : '';
    return [...nav.matchAll(/<a class="nav-item(?: active)?" href="([^"]+)"[^>]*>([\s\S]*?)<\/a>/g)]
      .map(([, href, body]) => ({
        href,
        label: body.match(/<span>([^<]+)<\/span>/)?.[1],
        icon: body.match(/<svg[^>]*>([\s\S]*?)<\/svg>/)?.[1]?.replace(/\s+/g, '')
      }));
  };
  const expectedTabs = tabs(home);
  for (const file of [
    'order-detail.html', 'order-history.html', 'loyalty.html', 'notifications.html',
    'customer-vouchers.html', 'customer-profile.html', 'new-order.html', 'category-services.html'
  ]) {
    const html = readPage(file);
    assert.deepEqual(tabs(html), expectedTabs, `${file} matches Customer Home tab icons and links`);
    assert.match(html, /class="unread-dot"/, `${file} shows the one unread notification`);
  }
});

test('clerk navigation is Home, Queue and New order on every clerk screen', () => {
  for (const file of ['clerk-home.html', 'order-queue.html', 'weigh-and-confirm.html', 'staff-order-detail.html', 'new-order-for-customer.html']) {
    const html = readPage(file);
    const start = html.indexOf('<nav class="bottom-nav"');
    const end = html.indexOf('</nav>', start);
    const nav = html.slice(start, end);
    assert.equal((nav.match(/class="nav-item/g) || []).length, 3, `${file} has three clerk tabs`);
    assert.match(nav, /<span>Home<\/span>/);
    assert.match(nav, /<span>Queue<\/span>/);
    assert.match(nav, /<span>New order<\/span>/);
    assert.match(html, /href="clerk-home\.html"/);
  }
});

test('owner navigation is Home, Services, Vouchers and More on every owner screen', () => {
  const ownerPages = [
    'owner-home.html', 'services-and-prices.html', 'owner-category-services.html',
    'vouchers.html', 'owner-orders.html', 'activity-log.html', 'settings.html',
    'shop-tools.html', 'owner-more.html'
  ];
  for (const file of ownerPages) {
    const html = readPage(file);
    const start = html.indexOf('<nav class="bottom-nav"');
    const end = html.indexOf('</nav>', start);
    const nav = html.slice(start, end);
    assert.equal((nav.match(/class="nav-item/g) || []).length, 4, `${file} has four owner tabs`);
    assert.match(nav, /<span>Home<\/span>/);
    assert.match(nav, /<span>Services<\/span>/);
    assert.match(nav, /<span>Vouchers<\/span>/);
    assert.match(nav, /<span>More<\/span>/);
    assert.doesNotMatch(nav, /<span>Summary<\/span>/);
  }
});

test('owner More links to oversight, activity, settings and shop tools', () => {
  const more = readPage('owner-more.html');
  assert.match(more, /href="owner-orders\.html"/);
  assert.match(more, /href="activity-log\.html"/);
  assert.match(more, /href="settings\.html"/);
  assert.match(more, /href="shop-tools\.html"/);
  assert.doesNotMatch(more, /daily-summary\.html|demo-tools\.html/);
});

test('clerk and owner dashboards show operational figures through the shared fixture', () => {
  for (const [file, role, fixtureRole] of [
    ['clerk-home.html', 'clerk', 'clerk'],
    ['owner-home.html', 'owner', 'owner']
  ]) {
    const html = readPage(file);
    assert.match(html, new RegExp(`data-role="${role}"`));
    assert.match(html, new RegExp(`data-dashboard="${fixtureRole}"`));
    assert.doesNotMatch(html, /Sample data|fixed sample|No live|not live/i);
    assert.match(html, /dashboard-data\.js/);
    assert.match(html, /dashboard\.js/);
  }
  const fixture = require('../prototype/assets/js/dashboard-data.js');
  assert.equal(fixture.clerk.metrics.length, 4);
  assert.equal(fixture.owner.metrics.length, 4);
  assert.equal(fixture.owner.week.length, 7);
  assert.equal(fixture.owner.mix.length, 4);
  assert.equal(fixture.clerk.recentOrders.length, 3);
  assert.equal(fixture.owner.metrics[0].value, '412.80');
  assert.equal(fixture.owner.metrics[0].note, 'Cash and transfer');
});

test('owner order oversight is read-only and covers multiple orders', () => {
  const html = readPage('owner-orders.html');
  assert.equal((html.match(/class="owner-order"/g) || []).length, 7);
  assert.equal((html.match(/data-order-row/g) || []).length, 7);
  assert.match(html, /data-order-filters/);
  assert.match(html, /data-order-search/);
  assert.match(html, /View only/);
  assert.match(html, /managed at the counter/);
  assert.doesNotMatch(html, /data-payment=|data-action="pickup"|data-action="save/);
});

test('queue and oversight expose multiple rows with combined search and filters', () => {
  const queue = readPage('order-queue.html');
  assert.equal((queue.match(/data-order-row/g) || []).length, 6);
  assert.match(queue, /data-order-filters/);
  assert.match(queue, /data-order-search/);
  assert.match(queue, /data-order-empty/);
  assert.match(queue, /Search by order ID, customer or service/);
});

test('activity log shows actor, time and old to new values for recent and catalog events', () => {
  const html = readPage('activity-log.html');
  assert.match(html, /Catalog history/);
  assert.match(html, /data-activity-filter="catalog"/);
  assert.match(html, /data-activity-feed/);
  assert.match(html, /class="audit-actor"/);
  assert.match(html, /class="audit-time"/);
  assert.match(html, /class="audit-old"/);
  assert.match(html, /class="audit-new"/);
  assert.match(html, /Today · /);
  assert.match(html, /class="audit-badge is-history"/);
  assert.doesNotMatch(html, /Sample history|This session|No server audit log/);
  assert.match(html, /activity-log\.js/);
  assert.match(html, /catalog-store\.js/);
});

test('owner can add an image-backed category and manage category-specific services', () => {
  const catalog = readPage('services-and-prices.html');
  assert.match(catalog, /href="add-category\.html"/);
  assert.doesNotMatch(catalog, /id="category-form"/);
  assert.match(catalog, /id="category-admin-list"/);
  assert.match(catalog, /services-admin\.js/);

  const addCategory = readPage('add-category.html');
  assert.match(addCategory, /id="category-form"/);
  assert.match(addCategory, /id="category-name"/);
  assert.match(addCategory, /id="category-description"/);
  assert.match(addCategory, /id="category-image" type="file"/);
  assert.match(addCategory, /id="category-image-preview"/);
  assert.match(addCategory, /category-form\.js/);

  const editor = readPage('owner-category-services.html');
  assert.match(editor, /id="service-admin-list"/);
  assert.match(editor, /id="add-service-link"/);
  assert.match(editor, /href="add-service\.html"/);
  assert.doesNotMatch(editor, /id="service-form"/);
  assert.match(editor, /services-list\.js/);

  const addService = readPage('add-service.html');
  for (const id of ['service-name', 'service-description', 'service-price', 'service-unit', 'service-duration', 'service-image', 'service-active']) {
    assert.match(addService, new RegExp(`id="${id}"`), `${id} is present`);
  }
  assert.match(addService, /Add a service/);
  assert.match(addService, /Description or benefit/);
  assert.match(addService, /Falls back to the category image/);
  assert.match(addService, /services-editor\.js/);
  assert.equal((catalog.match(/owner-category-services\.html\?category=/g) || []).length, 4);
  assert.match(catalog, /catalog-store\.js/);
});

test('only interactive screens load the shared page script', () => {
  const withScript = expected.filter((file) => /review-pages\.js/.test(readPage(file)));
  assert.deepEqual(withScript.sort(), [
    'shop-tools.html', 'new-order-for-customer.html', 'order-queue.html',
    'owner-orders.html', 'settings.html', 'staff-order-detail.html', 'weigh-and-confirm.html'
  ].sort());
});

test('shop tools exposes a real catalog restore and no fake time control', () => {
  const html = readPage('shop-tools.html');
  assert.doesNotMatch(html, /advance-time|\+1 day|\+3 days/);
  assert.doesNotMatch(html, /Not built|local only|this tab/i);
  assert.match(html, /data-action="reset-catalog"/);
  assert.match(html, /data-catalog-summary/);
  assert.match(html, /href="shop-tools\.html">Reload</);
});

test('voucher screens show offer terms consistently', () => {
  const customer = readPage('customer-vouchers.html');
  const owner = readPage('vouchers.html');
  assert.match(customer, /WELCOME10/);
  assert.match(customer, /Applied at weighing/i);
  assert.match(owner, /Active vouchers/i);
  assert.match(owner, /Voucher rules/i);
  assert.doesNotMatch(customer, /demo voucher|not a claim/i);
  assert.doesNotMatch(owner, /does not issue, edit or redeem vouchers/i);
});

test('home pricing and order-detail copy keep the final price pending weighing', () => {
  const detail = readPage('order-detail.html');
  assert.match(detail, /confirm the total once .* bag is weighed/i);
  assert.match(detail, /Unit rate/);
  assert.match(readPage('customer-home.html'), /LDR-0042/);
});

test('generator is repeatable and leaves no review-only pages behind', () => {
  const { execFileSync } = require('node:child_process');
  execFileSync('python', [path.join(__dirname, '..', 'prototype', 'tools', 'generate-review-pages.py')], { stdio: 'pipe' });
  const htmlFiles = fs.readdirSync(pages).filter((name) => name.endsWith('.html')).sort();
  assert.deepEqual(htmlFiles, [...expected].sort());
});

test('every page points to the local favicon', () => {
  for (const file of expected) {
    assert.match(readPage(file), /<link rel="icon" href="\.\.\/assets\/images\/favicon\.svg" type="image\/svg\+xml">/, `${file} has the local favicon`);
  }
  assert.ok(fs.existsSync(path.join(__dirname, '..', 'prototype', 'assets', 'images', 'favicon.svg')));
});

test('all pages load local assets and every local reference resolves', () => {
  for (const file of expected) {
    const full = path.join(pages, file);
    const html = fs.readFileSync(full, 'utf8');
    assert.match(html, /<!doctype html>/i, `${file} has a document type`);
    assert.doesNotMatch(html, /https?:\/\/(?!unsplash\.com\/license|unsplash\.com\/photos)[^"']+\.(?:css|js|png|jpg|svg|woff2?)/i, `${file} should not load remote assets`);
    for (const [, href] of html.matchAll(/(?:href|src)=["']([^"']+)["']/gi)) {
      if (/^(?:https?:|data:|#|mailto:|tel:|javascript:)/i.test(href)) continue;
      const target = path.resolve(path.dirname(full), href.split(/[?#]/)[0]);
      assert.ok(fs.existsSync(target), `${file} has a broken local reference: ${href}`);
    }
  }
});

test('app screens avoid demo, sample and prototype disclaimers', () => {
  const banned = /fixed sample|sample data|sample order|sample catalog|sample service|demo account|demo offer|demo only|prototype|preview only|no live|not built|local-only|this session|this tab/i;
  for (const file of expected) {
    const html = readPage(file);
    assert.doesNotMatch(html, banned, `${file} should read like the real app`);
  }
});

test('shared CSS assets referenced by the new screens exist', () => {
  for (const file of ['dashboard.css', 'catalog.css', 'activity.css', 'new-order.css']) {
    assert.ok(fs.existsSync(path.join(__dirname, '..', 'prototype', 'assets', 'css', file)), `${file} exists`);
  }
  assert.match(readAsset('js/dashboard-data.js'), /412\.80/);
  assert.match(readAsset('js/new-order.js'), /category-services\.html/);
  assert.match(readAsset('js/catalog-store.js'), /sessionStorage/);
});

test('hidden panels stay hidden and dashboard mix bars keep a visible track', () => {
  assert.match(readAsset('css/base.css'), /\[hidden\]\s*\{\s*display:\s*none\s*!important;\s*\}/);
  assert.match(readAsset('css/dashboard.css'), /\.dash-mix-track\s*\{[^}]*display:\s*block/s);
});
