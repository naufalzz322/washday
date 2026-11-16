from html import escape
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

CUSTOMER_NAV = [
    ("Home", "customer-home.html"),
    ("Orders", "order-history.html"),
    ("Vouchers", "customer-vouchers.html"),
    ("Profile", "customer-profile.html"),
]
CLERK_NAV = [
    ("Home", "clerk-home.html"),
    ("Queue", "order-queue.html"),
    ("New order", "new-order-for-customer.html"),
]
OWNER_NAV = [
    ("Home", "owner-home.html"),
    ("Services", "services-and-prices.html"),
    ("Vouchers", "vouchers.html"),
    ("More", "owner-more.html"),
]

NAV_ICONS = {
    "Home": '<path d="m3 10 9-7 9 7M5 9v12h14V9M9 21v-7h6v7"/>',
    "Orders": '<path d="M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Zm-2 5h18M7 5.5h.01M10 5.5h.01"/><circle cx="12" cy="14" r="4"/>',
    "Vouchers": '<path d="M4 7h16v13H4zM4 10h16M8 4v6m8-6v6M8 14h3m2 0h3m-8 3h3m2 0h3"/>',
    "Profile": '<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/><path d="M18 4.5h3m-1.5-1.5v3"/>',
    "Queue": '<path d="M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Zm-2 5h18M7 5.5h.01M10 5.5h.01"/><circle cx="12" cy="14" r="4"/>',
    "Weigh": '<path d="M4 20h16M6 20l2-12h8l2 12M10 11l2 2 3-4M12 4v2"/>',
    "New order": '<circle cx="9" cy="7" r="3"/><path d="M3 19a6 6 0 0 1 12 0M19 8v8m-4-4h8"/>',
    "Services": '<path d="m8 4 4 2 4-2 5 3-2 4-3-1v10H8V10l-3 1-2-4 5-3Z"/><path d="M9 5.5c.5 1.6 1.5 2.5 3 2.5s2.5-.9 3-2.5"/>',
    "More": '<circle cx="5" cy="12" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/>',
}

ACTIVE_NAV = {
    "order-detail.html": "Orders", "order-history.html": "Orders",
    "loyalty.html": "Profile", "customer-vouchers.html": "Vouchers",
    "customer-profile.html": "Profile", "notifications.html": "Home",
    "clerk-home.html": "Home", "order-queue.html": "Queue",
    "weigh-and-confirm.html": "Queue", "staff-order-detail.html": "Queue",
    "new-order-for-customer.html": "New order",
    "owner-home.html": "Home", "services-and-prices.html": "Services",
    "owner-category-services.html": "Services",
    "add-category.html": "Services", "add-service.html": "Services",
    "vouchers.html": "Vouchers",
    "owner-orders.html": "More", "activity-log.html": "More",
    "settings.html": "More", "shop-tools.html": "More",
    "owner-more.html": "More",
}

ORDER_DOCK = '''<a class="order-dock" href="new-order.html" aria-label="Start a new order">
    <span>New order</span>
    <span class="order-dock-arrow" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M7 17 17 7M7 7h10v10"/></svg></span>
  </a>'''

PAGES = [
    {
        "file": "login.html", "title": "Sign in", "role": "Everyone", "nav": [],
        "lead": "Sign in to manage your laundry.",
        "heading": False, "body_class": "login-page", "styles": ["login.css"], "scripts": ["login.js"],
        "body": '''
<a class="login-back" href="index.html"><span aria-hidden="true">←</span> Welcome</a>
<header class="login-head">
  <p class="rp-kicker">Welcome back</p>
  <h1>Sign in to<br><span>Washday.</span></h1>
  <p class="login-lede">Use your details to sign in.</p>
</header>
<section class="rp-card login-panel" aria-label="Sign in">
  <form class="login-form" action="customer-home.html" novalidate>
    <div class="login-field">
      <label for="login-email">Email</label>
      <input id="login-email" type="email" inputmode="email" autocomplete="username" placeholder="you@example.com" aria-describedby="login-hint">
    </div>
    <div class="login-field">
      <label for="login-password">Password</label>
      <div class="login-field-wrap">
        <input id="login-password" type="password" autocomplete="current-password" placeholder="Your password" aria-describedby="login-hint">
        <button class="login-reveal" type="button" aria-label="Show password" aria-pressed="false">Show</button>
      </div>
    </div>
    <button class="login-submit" type="submit">Sign in</button>
  </form>
  <p class="login-hint" id="login-hint">Enter your email and password.</p>
</section>
<form class="login-account-form" aria-label="Choose an account">
  <label class="login-account-label" for="login-account">Or continue as</label>
  <div class="login-account-row">
    <select id="login-account" class="login-account-select" aria-label="Choose an account">
      <option value="" selected disabled>Select account</option>
      <option value="customer-a" data-destination="customer-home.html">Customer A</option>
      <option value="customer-b" data-destination="customer-home.html">Customer B</option>
      <option value="clerk" data-destination="clerk-home.html">Clerk</option>
      <option value="owner" data-destination="owner-home.html">Owner</option>
    </select>
  </div>
</form>'''
    },
    {
        "file": "order-detail.html", "title": "Order detail", "role": "Customer", "nav": CUSTOMER_NAV,
        "lead": "Track your current order and see what happens next.",
        "heading": False, "styles": ["order-detail.css"],
        "body": '''
<a class="rp-back-link" href="order-history.html"><span aria-hidden="true">←</span> Orders</a>
<section class="od-track-hero" aria-labelledby="order-title">
  <div class="od-track-top"><p class="rp-kicker">Track order</p><span class="rp-status rp-status-warning">Ready</span></div>
  <h1 id="order-title">LDR-0042</h1>
  <p class="od-track-meta">Express service · Ready for pickup</p>
  <div class="od-chips">
    <span class="od-chip"><svg viewBox="0 0 20 20" aria-hidden="true"><circle cx="10" cy="10" r="7.2"/><path d="M10 6v4.3l2.8 1.6"/></svg>Est. 6 h</span>
    <span class="od-chip"><svg viewBox="0 0 20 20" aria-hidden="true"><path d="M3.5 16.5h13M5 16.5l1.7-10h6.6l1.7 10M8.3 9.4l1.7 1.7 2.5-3.2"/></svg>2.00 / kg</span>
  </div>
</section>
<section class="rp-card od-timeline-card">
  <div class="rp-section-head"><div><p class="rp-kicker">Status</p><h2>Order progress</h2></div><span class="rp-count">Step 4 of 5</span></div>
  <ol class="rp-timeline">
    <li class="is-done"><span class="rp-step-node" aria-hidden="true"></span><div class="rp-step-copy"><strong>Ordered</strong><small>Order placed</small></div><span class="rp-step-state">Complete</span></li>
    <li class="is-done"><span class="rp-step-node" aria-hidden="true"></span><div class="rp-step-copy"><strong>Received</strong><small>Drop-off recorded</small></div><span class="rp-step-state">Complete</span></li>
    <li class="is-done"><span class="rp-step-node" aria-hidden="true"></span><div class="rp-step-copy"><strong>Processing</strong><small>Laundry processed</small></div><span class="rp-step-state">Complete</span></li>
    <li class="is-current"><span class="rp-step-node" aria-hidden="true"></span><div class="rp-step-copy"><strong>Ready</strong><small>Ready for pickup</small></div><span class="rp-step-state">Current</span></li>
    <li><span class="rp-step-node" aria-hidden="true"></span><div class="rp-step-copy"><strong>Picked up</strong><small>Not yet collected</small></div><span class="rp-step-state">Next</span></li>
  </ol>
</section>
<section class="rp-card">
  <div class="rp-section-head"><div><p class="rp-kicker">Price</p><h2>Unit rate</h2></div><span class="rp-status rp-status-warning">Not weighed</span></div>
  <div class="od-price-line">
    <span class="od-price-copy"><strong>Express service</strong><small>Price per kilogram</small></span>
    <span class="od-price-amount">2.00 <small>/ kg</small></span>
  </div>
  <div class="od-dashed" aria-hidden="true"></div>
  <p class="od-price-note">Your total is worked out when we weigh your laundry.</p>
</section>
<section class="od-pickup" aria-label="Pickup">
  <span class="od-pickup-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 10h16l-1.2 10H5.2L4 10ZM3 6h18v4H3zM9 6V4h6v2"/></svg></span>
  <span class="od-pickup-copy"><strong>Pickup at the shop</strong><small>Bring your order ID when you collect it.</small></span>
</section>
<div class="rp-notice"><strong>Final price after weighing</strong><p>We’ll confirm the total once your bag is weighed. The unit rate is shown below.</p></div>
<div class="rp-actions"><a class="rp-button rp-button-secondary" href="order-history.html">Order history</a><a class="rp-button rp-button-primary" href="notifications.html">Notifications <span aria-hidden="true">↗</span></a></div>'''
    },
    {
        "file": "order-history.html", "title": "Order history", "role": "Customer", "nav": CUSTOMER_NAV,
        "lead": "Your current and past laundry orders.",
        "body_class": "has-order-dock", "dock": True,
        "body": '''
<section class="rp-card"><div class="rp-section-head"><div><p class="rp-kicker">CUSTOMER A</p><h2>Your orders</h2></div><span class="rp-count">1 order</span></div>
<a class="rp-list-row" href="order-detail.html"><span class="rp-service-icon" aria-hidden="true">E</span><span class="rp-row-main"><strong>LDR-0042 · Express</strong><small>Ready for pickup · Unit rate 2.00 / kg</small></span><span class="rp-status rp-status-warning">Ready</span><span class="rp-chevron" aria-hidden="true">›</span></a>
</section><div class="rp-notice"><strong>Latest order</strong><p>Your most recent order is shown here.</p></div>'''
    },
    {
        "file": "loyalty.html", "title": "Loyalty card", "role": "Customer", "nav": CUSTOMER_NAV,
        "lead": "Every eligible pickup moves you closer to a reward.",
        "body": '''
<section class="rp-card rp-loyalty"><p class="rp-kicker">CUSTOMER A</p><div class="rp-section-head"><h2>Loyalty card</h2><strong class="rp-large-count">5 <span>/ 10</span></strong></div><div class="rp-stamp-grid" role="img" aria-label="5 of 10 stamps earned"><span class="earned">✓</span><span class="earned">✓</span><span class="earned">✓</span><span class="earned">✓</span><span class="earned">✓</span><span></span><span></span><span></span><span></span><span class="reward">★</span></div><p>Five more eligible paid pickups earn a reward: 50% off up to 5 kg.</p></section>
<section class="rp-card"><h2>How stamps work</h2><ul class="rp-list"><li>A stamp is earned after an order is picked up and paid.</li><li>An order must weigh at least 1 kg to earn a stamp.</li><li>Unused rewards do not expire.</li><li>The reward applies to per-kilogram services.</li></ul></section>
'''
    },
    {
        "file": "notifications.html", "title": "Notifications", "role": "Customer", "nav": CUSTOMER_NAV,
        "lead": "Updates about your laundry, in one place.",
        "body": '''
<section class="rp-card"><div class="rp-section-head"><div><p class="rp-kicker">CUSTOMER A</p><h2>Recent updates</h2></div><span class="rp-unread">1 unread</span></div>
<a class="rp-notification" href="order-detail.html"><span class="rp-notification-icon" aria-hidden="true">✓</span><span><strong>Your laundry is ready</strong><small>Order LDR-0042 · Ready for pickup</small></span><span class="rp-unread-dot" aria-hidden="true"></span></a>
</section>'''
    },
    {
        "file": "order-queue.html", "title": "Order queue", "role": "Clerk", "nav": CLERK_NAV, "interactive": True,
        "lead": "Find an order and see where it is.",
        "body": '''
<section class="rp-card"><label class="rp-label" for="queue-search">Search orders</label><div class="rp-search"><input id="queue-search" type="search" data-order-search placeholder="Try LDR-0042" aria-label="Search orders"><button class="rp-button rp-button-secondary" type="button" data-action="queue-search">Search</button></div><p class="rp-help">Search by order ID, customer or service.</p></section>
<section class="rp-card"><div class="rp-section-head"><div><p class="rp-kicker">CLERK</p><h2>Orders</h2></div><span class="rp-count">6 open</span></div><div class="rp-filter-row" role="group" aria-label="Filter queue" data-order-filters><button type="button" class="rp-filter is-selected" data-filter="all">All</button><button type="button" class="rp-filter" data-filter="ready">Ready</button><button type="button" class="rp-filter" data-filter="processing">Processing</button></div>
<a class="rp-list-row" data-order-row data-status="ready" href="staff-order-detail.html"><span class="rp-service-icon" aria-hidden="true">E</span><span class="rp-row-main"><strong>LDR-0042</strong><small>Customer A · Express wash</small></span><span class="rp-status rp-status-warning">Ready</span><span class="rp-chevron" aria-hidden="true">›</span></a>
<a class="rp-list-row" data-order-row data-status="processing" href="staff-order-detail.html"><span class="rp-service-icon" aria-hidden="true">W</span><span class="rp-row-main"><strong>LDR-0041</strong><small>Customer B · Wash &amp; fold</small></span><span class="rp-status rp-status-neutral">Processing</span><span class="rp-chevron" aria-hidden="true">›</span></a>
<a class="rp-list-row" data-order-row data-status="ready" href="staff-order-detail.html"><span class="rp-service-icon" aria-hidden="true">B</span><span class="rp-row-main"><strong>LDR-0040</strong><small>Walk-in · Bedding wash &amp; fold</small></span><span class="rp-status rp-status-warning">Ready</span><span class="rp-chevron" aria-hidden="true">›</span></a>
<a class="rp-list-row" data-order-row data-status="ready" href="staff-order-detail.html"><span class="rp-service-icon" aria-hidden="true">P</span><span class="rp-row-main"><strong>LDR-0039</strong><small>Customer A · Press only</small></span><span class="rp-status rp-status-warning">Ready</span><span class="rp-chevron" aria-hidden="true">›</span></a>
<a class="rp-list-row" data-order-row data-status="processing" href="staff-order-detail.html"><span class="rp-service-icon" aria-hidden="true">D</span><span class="rp-row-main"><strong>LDR-0038</strong><small>Customer B · Dry clean</small></span><span class="rp-status rp-status-neutral">Processing</span><span class="rp-chevron" aria-hidden="true">›</span></a>
<a class="rp-list-row" data-order-row data-status="ready" href="staff-order-detail.html"><span class="rp-service-icon" aria-hidden="true">E</span><span class="rp-row-main"><strong>LDR-0037</strong><small>Customer A · Express wash</small></span><span class="rp-status rp-status-warning">Ready</span><span class="rp-chevron" aria-hidden="true">›</span></a>
<p class="rp-empty" data-order-empty hidden>No orders match this search.</p></section>
<div class="rp-actions"><a class="rp-button rp-button-primary" href="weigh-and-confirm.html">Weigh an order</a><a class="rp-button rp-button-secondary" href="new-order-for-customer.html">Counter order</a></div>
'''
    },
    {
        "file": "weigh-and-confirm.html", "title": "Weigh and confirm", "role": "Clerk", "nav": CLERK_NAV, "interactive": True,
        "lead": "Check the weight, discount and total.",
        "body": '''
<section class="rp-card rp-order-head"><div><p class="rp-kicker">ORDER SUMMARY</p><h2>Express service</h2><p>WELCOME10 · 4.2 kg at 2.00 / kg</p></div><span class="rp-status rp-status-neutral">Express</span></section>
<section class="rp-card"><label class="rp-label" for="weight-input">Weight</label><div class="rp-input-suffix"><input id="weight-input" type="text" value="4.2" inputmode="decimal" pattern="[0-9]+([.,][0-9]+)?" aria-describedby="weight-help"><span>kg</span></div><p class="rp-help" id="weight-help">Weight starts at 4.2 kg. The rate is 2.00 / kg.</p><fieldset class="rp-fieldset"><legend>Discount choice</legend><label class="rp-radio"><input type="radio" name="discount" value="voucher" checked><span>WELCOME10 · 10% off (max 5.00; min spend 3.00)</span></label><label class="rp-radio"><input type="radio" name="discount" value="none"><span>No discount</span></label></fieldset>
<div class="rp-breakdown" aria-live="polite"><div><span>Subtotal</span><strong id="calc-subtotal">8.40</strong></div><div><span>Discount</span><strong id="calc-discount">−0.84</strong></div><div class="rp-total"><span>Total</span><strong id="calc-total">7.56</strong></div></div>
</section><section class="rp-card"><h2>Payment method</h2><div class="rp-choice-grid"><label class="rp-choice"><input type="radio" name="payment" value="cash" checked>Cash</label><label class="rp-choice"><input type="radio" name="payment" value="transfer">Transfer</label><label class="rp-choice"><input type="radio" name="payment" value="QR">QR</label><label class="rp-choice"><input type="radio" name="payment" value="e-wallet">E-wallet</label></div><button class="rp-button rp-button-primary rp-full" type="button" data-action="weigh-preview">Update total</button><p class="rp-feedback" data-feedback aria-live="polite"></p></section>

<a class="rp-text-link" href="staff-order-detail.html">Continue to staff order detail →</a>'''
    },
    {
        "file": "staff-order-detail.html", "title": "Staff order detail", "role": "Clerk", "nav": CLERK_NAV, "interactive": True,
        "lead": "Update payment and pickup for this order.",
        "body": '''
<section class="rp-card rp-order-head"><div><p class="rp-kicker">ORDER</p><h2>LDR-0042</h2><p>Customer A · Express · 2.00 / kg</p></div><span class="rp-status rp-status-warning" data-order-status>Ready</span></section>
<section class="rp-card"><h2>Payment</h2><div class="rp-detail-row"><span>Payment status</span><strong data-payment-status>Unpaid</strong></div><div class="rp-choice-grid"><button type="button" class="rp-button rp-button-secondary" data-payment="Cash">Record cash</button><button type="button" class="rp-button rp-button-secondary" data-payment="Transfer">Record transfer</button></div><p class="rp-feedback" data-feedback aria-live="polite"></p></section>
<section class="rp-card"><h2>Status history</h2><ol class="rp-compact-timeline"><li><strong>Ordered</strong><small>Today · 09:12 · Clerk K</small></li><li><strong>Received</strong><small>Today · 09:20 · Clerk K</small></li><li><strong>Processing → Ready</strong><small>Today · 10:05 · Clerk K</small></li></ol></section>
<section class="rp-card"><h2>Pickup</h2><p>If this order is unpaid, a warning appears before pickup.</p><button class="rp-button rp-button-primary rp-full" type="button" data-action="pickup">Mark picked up</button></section>
'''
    },
    {
        "file": "new-order-for-customer.html", "title": "Counter order", "role": "Clerk", "nav": CLERK_NAV, "interactive": True,
        "lead": "Start an order for a customer at the counter.",
        "body": '''
<section class="rp-card"><h2>Customer</h2><fieldset class="rp-fieldset"><legend>Choose a customer</legend><label class="rp-radio"><input type="radio" name="counter-customer" value="Customer A" checked><span>Customer A · returning customer</span></label><label class="rp-radio"><input type="radio" name="counter-customer" value="Walk-in"><span>Walk-in customer</span></label></fieldset><div class="rp-form-grid"><div><label class="rp-label" for="walkin-name">Walk-in name</label><input class="rp-input" id="walkin-name" placeholder="Enter name" disabled></div><div><label class="rp-label" for="walkin-phone">Phone (optional)</label><input class="rp-input" id="walkin-phone" type="tel" placeholder="Optional" disabled></div></div></section>
<section class="rp-card"><h2>Order details</h2><label class="rp-label" for="counter-service">Service</label><select id="counter-service" class="rp-input"><option>Wash &amp; fold · 2.00 / kg</option><option>Press only · 3.50 / item</option><option>Express wash · 4.00 / kg</option></select><label class="rp-label" for="counter-category">Category</label><select id="counter-category" class="rp-input"><option>Shirts</option><option>Pants</option><option>Dresses</option><option>Bedding</option></select><button class="rp-button rp-button-primary rp-full" type="button" data-action="counter-preview">Create order</button><p class="rp-feedback" data-feedback aria-live="polite"></p></section>
'''
    },
    {
        "file": "services-and-prices.html", "title": "Service catalog", "role": "Owner", "nav": OWNER_NAV,
        "lead": "Manage categories and the services customers can choose.",
        "styles": ["catalog.css"], "scripts": ["catalog-store.js", "services-admin.js"],
        "body": '''
<section class="rp-card" aria-labelledby="category-admin-title">
  <div class="rp-section-head"><div><p class="rp-kicker">OWNER CATALOG</p><h2 id="category-admin-title">Categories</h2></div><span class="rp-count" id="category-admin-count">4 categories</span></div>
  <div class="admin-category-list" id="category-admin-list">
    <a class="admin-category-card" href="owner-category-services.html?category=shirts" data-category-card="shirts"><span class="catalog-thumb" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 7h16v13H4zM4 10h16M8 4v6m8-6v6"/><path d="M8 14h3m2 0h3"/></svg><img src="../assets/images/hero-shirt.jpg" alt="" loading="lazy"></span><span class="admin-category-copy"><strong>Shirts</strong><small>Everyday shirts, blouses and light tops, finished neatly.</small></span><span class="rp-count">3 svc</span><span class="admin-category-arrow" aria-hidden="true">›</span></a>
    <a class="admin-category-card" href="owner-category-services.html?category=pants" data-category-card="pants"><span class="catalog-thumb" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 7h16v13H4zM4 10h16M8 4v6m8-6v6"/><path d="M8 14h3m2 0h3"/></svg><img src="../assets/images/category-pants.jpg" alt="" loading="lazy"></span><span class="admin-category-copy"><strong>Pants</strong><small>Trousers, jeans and casual bottoms, washed and folded.</small></span><span class="rp-count">3 svc</span><span class="admin-category-arrow" aria-hidden="true">›</span></a>
    <a class="admin-category-card" href="owner-category-services.html?category=dresses" data-category-card="dresses"><span class="catalog-thumb" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 7h16v13H4zM4 10h16M8 4v6m8-6v6"/><path d="M8 14h3m2 0h3"/></svg><img src="../assets/images/category-dresses.jpg" alt="" loading="lazy"></span><span class="admin-category-copy"><strong>Dresses</strong><small>Dresses, skirts and delicate pieces that need a gentler clean.</small></span><span class="rp-count">3 svc</span><span class="admin-category-arrow" aria-hidden="true">›</span></a>
    <a class="admin-category-card" href="owner-category-services.html?category=bedding" data-category-card="bedding"><span class="catalog-thumb" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 7h16v13H4zM4 10h16M8 4v6m8-6v6"/><path d="M8 14h3m2 0h3"/></svg><img src="../assets/images/category-bedding.jpg" alt="" loading="lazy"></span><span class="admin-category-copy"><strong>Bedding</strong><small>Sheets, duvet covers and household linen for a fresh reset.</small></span><span class="rp-count">3 svc</span><span class="admin-category-arrow" aria-hidden="true">›</span></a>
  </div>
  <a class="rp-button rp-button-primary rp-full catalog-add-button" href="add-category.html">Add category</a>
  <div class="catalog-source"><span>Catalog: <strong id="catalog-source-label">Default</strong></span><span>Visible to customers</span></div>
</section>
<div class="rp-notice"><strong>Customer menu</strong><p>Active categories and services appear on the customer category page.</p></div>'''
    },
    {
        "file": "add-category.html", "title": "Add category", "role": "Owner", "nav": OWNER_NAV,
        "lead": "Add a category to your customer catalog.", "styles": ["catalog.css"], "scripts": ["catalog-store.js", "category-form.js"],
        "body": '''
<a class="rp-back-link" href="services-and-prices.html"><span aria-hidden="true">←</span> Categories</a>
<section class="rp-card" aria-labelledby="add-category-title">
  <div class="rp-section-head"><div><p class="rp-kicker">OWNER CATALOG</p><h2 id="add-category-title">New category</h2></div></div>
  <form id="category-form" novalidate>
    <label class="rp-label" for="category-name">Category name</label>
    <input class="rp-input" id="category-name" name="category-name" maxlength="60" autocomplete="off" required placeholder="e.g. Uniforms">
    <label class="rp-label" for="category-description">Description</label>
    <textarea class="rp-input rp-textarea" id="category-description" name="category-description" maxlength="220" required placeholder="What belongs in this category?"></textarea>
    <label class="rp-label" for="category-image">Category image</label>
    <div class="image-field"><span class="image-preview" id="category-image-preview" aria-hidden="true"><span>No image</span></span><span class="image-controls"><input id="category-image" type="file" accept="image/*" aria-label="Choose a category image"><small>JPG or PNG. Optional.</small></span></div>
    <button class="rp-button rp-button-primary rp-full" type="submit">Add category</button>
    <p class="rp-feedback" data-category-feedback aria-live="polite"></p>
  </form>
</section>'''
    },
    {
        "file": "vouchers.html", "title": "Voucher management", "role": "Owner", "nav": OWNER_NAV,
        "lead": "Manage your offers and their rules.",
        "body": '''
<section class="rp-card"><div class="rp-section-head"><div><p class="rp-kicker">OWNER</p><h2>Active vouchers</h2></div><span class="rp-count">1 active</span></div>
<div class="rp-voucher"><div class="rp-voucher-top"><strong>WELCOME10</strong><span class="rp-status rp-status-neutral">Active</span></div><h3>10% off</h3><p>Maximum discount 5.00 · minimum spend 3.00</p><p>Eligible on wash &amp; fold orders. One offer per order.</p></div></section>
<section class="rp-card"><h2>Voucher checks</h2><ul class="rp-list"><li>Check whether the voucher is active, in date and applies to the service when ordering.</li><li>Check minimum spend at weighing, when subtotal is known.</li><li>Only one discount can apply to an order.</li></ul></section>
<div class="rp-notice"><strong>Voucher rules</strong><p>WELCOME10 applies to eligible wash &amp; fold orders and is checked at weighing.</p></div>'''
    },
    {
        "file": "shop-tools.html", "title": "Shop tools", "role": "Owner", "nav": OWNER_NAV, "interactive": True,
        "lead": "Maintain your service catalog and screen.",
        "scripts": ["catalog-store.js"],
        "body": '''
<section class="rp-card"><p class="rp-kicker">OWNER</p><h2>Shop maintenance</h2><p>Restore the customer catalog or reload this screen.</p>
<div class="rp-tool-row"><span><strong>Catalog status</strong><small data-catalog-summary>4 categories · 12 services · 0 recent changes</small></span><div class="rp-tool-state"><span class="rp-status rp-status-neutral" data-catalog-state>Default catalog</span></div></div>
<div class="rp-tool-row"><span><strong>Restore default catalog</strong><small>Replace the current catalog with the default categories and services.</small></span><button class="rp-button rp-button-secondary" type="button" data-action="reset-catalog">Restore</button></div>
<div class="rp-tool-row"><span><strong>Reload screen</strong><small>Reopens this screen.</small></span><a class="rp-button rp-button-secondary" href="shop-tools.html">Reload</a></div>
<p class="rp-feedback" data-feedback aria-live="polite"></p>
</section>
<div class="rp-notice"><strong>Before you restore</strong><p>Restoring defaults removes custom categories and services and clears recent catalog activity. This cannot be undone.</p></div>'''
    },
    {
        "file": "customer-vouchers.html", "title": "Your vouchers", "role": "Customer", "nav": CUSTOMER_NAV,
        "lead": "Your available offers.",
        "body": '''
<section class="rp-voucher rp-voucher-feature"><p class="rp-kicker">ACTIVE OFFER</p><h2>WELCOME10</h2><p class="rp-voucher-discount">10% off</p><p>Minimum spend 3.00 · discount capped at 5.00</p><span class="rp-code-pill">WELCOME10</span></section>
<div class="rp-notice"><strong>Applied at weighing</strong><p>One offer per order. Minimum spend 3.00; discount capped at 5.00.</p></div><a class="rp-button rp-button-primary" href="new-order.html">Browse services <span aria-hidden="true">↗</span></a>'''
    },
    {
        "file": "customer-profile.html", "title": "Profile", "role": "Customer", "nav": CUSTOMER_NAV,
        "lead": "Your details and loyalty progress.",
        "body": '''
<section class="rp-card rp-profile"><span class="rp-avatar" aria-hidden="true">A</span><div><p class="rp-kicker">CUSTOMER</p><h2>Customer A</h2><p>Alex</p></div></section>
<section class="rp-card"><h2>Account details</h2><div class="rp-detail-row"><span>Email</span><span>Not added</span></div><div class="rp-detail-row"><span>Phone</span><span>Optional · not added</span></div></section>
<a class="rp-card rp-link-card" href="loyalty.html"><span><strong>Loyalty card</strong><small>5 of 10 stamps earned</small></span><span class="rp-chevron" aria-hidden="true">›</span></a>
'''
    },
    {
        "file": "settings.html", "title": "Shop settings", "role": "Owner", "nav": OWNER_NAV, "interactive": True,
        "lead": "Loyalty and order timing rules.",
        "body": '''
<section class="rp-card"><p class="rp-kicker">OWNER</p><h2>Loyalty rules</h2><label class="rp-label" for="stamp-threshold">Completed orders per reward</label><input class="rp-input" id="stamp-threshold" type="number" value="10" min="1"><p class="rp-help">Changing this threshold would affect every customer's balance.</p><label class="rp-label" for="loyalty-percent">Reward discount</label><input class="rp-input" id="loyalty-percent" type="number" value="50" min="0" max="100"><label class="rp-label" for="weight-cap">Weight cap (kg)</label><input class="rp-input" id="weight-cap" type="number" value="5" min="0"></section>
<section class="rp-card"><h2>Order timing</h2><label class="rp-label" for="order-expiry">Ordered expiry window (hours)</label><input class="rp-input" id="order-expiry" type="number" value="48" min="1"><label class="rp-label" for="pickup-reminder">Ready pickup reminder (days)</label><input class="rp-input" id="pickup-reminder" type="number" value="3" min="1"><label class="rp-label" for="unclaimed-days">Unclaimed policy period (days)</label><input class="rp-input" id="unclaimed-days" type="number" value="30" min="1"><button class="rp-button rp-button-primary rp-full" type="button" data-action="save-settings">Save settings</button><p class="rp-feedback" data-feedback aria-live="polite"></p></section>
<div class="rp-notice"><strong>Shop policy</strong><p>These values apply to new orders, pickup reminders and unclaimed items.</p></div>'''
    },
    {
        "file": "clerk-home.html", "title": "Home", "role": "Clerk", "nav": CLERK_NAV,
        "lead": "Today's queue and shop snapshot.",
        "styles": ["dashboard.css"], "scripts": ["dashboard-data.js", "dashboard.js"], "dashboard": "clerk",
        "body": '''
<section class="dash-hero" aria-labelledby="clerk-hero-title">
  <div class="dash-hero-top"><div><p class="rp-kicker">CLERK · TODAY</p><h2 id="clerk-hero-title">Counter shift</h2></div></div>
  <p>Orders, pickups and payments in one place.</p>
  <div class="dash-hero-actions"><a class="rp-button rp-button-primary" href="order-queue.html">Open queue</a><a class="rp-button rp-button-secondary" href="new-order-for-customer.html">Counter order</a></div>
</section>
<section class="rp-card" aria-labelledby="clerk-kpi-title">
  <div class="rp-section-head"><div><p class="rp-kicker">TODAY</p><h2 id="clerk-kpi-title">Today at a glance</h2></div><span class="rp-count">Updated just now</span></div>
  <div class="dash-kpis" data-dashboard-metrics></div>
</section>
<section class="rp-card" aria-labelledby="clerk-work-title">
  <div class="rp-section-head"><div><p class="rp-kicker">OPERATIONS</p><h2 id="clerk-work-title">Queue load</h2></div><span class="rp-count">6 open</span></div>
  <div class="dash-bars" data-dashboard-queue></div>
</section>
<section class="rp-card" aria-labelledby="clerk-recent-title">
  <div class="rp-section-head"><div><p class="rp-kicker">RECENT</p><h2 id="clerk-recent-title">Recent orders</h2></div><a class="rp-text-link" href="order-queue.html">View all</a></div>
  <div class="dash-orders" data-dashboard-orders></div>
</section>
'''
    },
    {
        "file": "owner-home.html", "title": "Home", "role": "Owner", "nav": OWNER_NAV,
        "lead": "Sales, catalog and operational signals at a glance.",
        "styles": ["dashboard.css"], "scripts": ["dashboard-data.js", "dashboard.js"], "dashboard": "owner",
        "body": '''
<section class="dash-hero" aria-labelledby="owner-hero-title">
  <div class="dash-hero-top"><div><p class="rp-kicker">OWNER · TODAY</p><h2 id="owner-hero-title">Shop pulse</h2></div></div>
  <p>A compact view of sales, orders and follow-ups.</p>
  <div class="dash-hero-actions"><a class="rp-button rp-button-primary" href="owner-orders.html">Order oversight</a><a class="rp-button rp-button-secondary" href="activity-log.html">Activity log</a></div>
</section>
<section class="rp-card" aria-labelledby="owner-kpi-title">
  <div class="rp-section-head"><div><p class="rp-kicker">TODAY</p><h2 id="owner-kpi-title">Today at a glance</h2></div><span class="rp-count">Updated just now</span></div>
  <div class="dash-kpis" data-dashboard-metrics></div>
</section>
<section class="rp-card" aria-labelledby="owner-week-title">
  <div class="rp-section-head"><div><p class="rp-kicker">SALES</p><h2 id="owner-week-title">Last 7 days</h2></div><span class="rp-count">This week</span></div>
  <div class="dash-week" data-dashboard-week></div>
</section>
<section class="rp-card" aria-labelledby="owner-mix-title">
  <div class="rp-section-head"><div><p class="rp-kicker">SERVICE MIX</p><h2 id="owner-mix-title">Where orders go</h2></div><span class="rp-count">This week</span></div>
  <div class="dash-mix" data-dashboard-mix></div>
</section>
<section class="rp-card" aria-labelledby="owner-alert-title">
  <div class="rp-section-head"><div><p class="rp-kicker">FOLLOW-UP</p><h2 id="owner-alert-title">Needs a look</h2></div><span class="rp-count">3 alerts</span></div>
  <div class="dash-alert"><span class="dash-alert-icon" aria-hidden="true">!</span><span class="dash-alert-copy"><strong>3 unpaid orders</strong><small>Check payment before handover.</small></span></div>
  <div class="dash-alert"><span class="dash-alert-icon" aria-hidden="true">⏱</span><span class="dash-alert-copy"><strong>2 ready for over 2 days</strong><small>Send a pickup reminder.</small></span></div>
  <div class="dash-alert is-neutral"><span class="dash-alert-icon" aria-hidden="true">↻</span><span class="dash-alert-copy"><strong>Catalog is editable</strong><small>Add categories and services from the Services tab.</small></span></div>
</section>
<section class="rp-card" aria-labelledby="owner-recent-title">
  <div class="rp-section-head"><div><p class="rp-kicker">RECENT</p><h2 id="owner-recent-title">Recent orders</h2></div><a class="rp-text-link" href="owner-orders.html">Oversight</a></div>
  <div class="dash-orders" data-dashboard-orders></div>
</section>
'''
    },
    {
        "file": "category-services.html", "title": "Choose a service", "role": "Customer", "nav": CUSTOMER_NAV,
        "lead": "Choose a service from this category.",
        "heading": False, "styles": ["catalog.css"], "scripts": ["catalog-store.js", "category-services.js"],
        "body": '''
<a class="rp-back-link" href="new-order.html"><span aria-hidden="true">←</span> All categories</a>
<section class="catalog-hero" id="category-hero" aria-labelledby="category-name">
  <img class="catalog-hero-image" id="category-image" src="../assets/images/hero-shirt.jpg" alt="">
  <div class="catalog-hero-copy"><p class="rp-kicker">CATEGORY</p><h1 id="category-name">Shirts</h1><p id="category-description">Everyday shirts, blouses and light tops, finished neatly.</p><span class="catalog-pill" id="category-count">3 services</span></div>
</section>
<section class="rp-card" id="service-card" aria-labelledby="service-title">
  <div class="rp-section-head"><div><p class="rp-kicker">SERVICES</p><h2 id="service-title">Choose a service</h2></div><span class="rp-count" id="service-count">3</span></div>
  <div class="service-list" id="service-list" role="list"></div>
  <p class="rp-empty" id="service-empty" hidden>No services in this category yet. Ask the owner to add one.</p>
  <p class="catalog-selection" id="selection-summary" aria-live="polite" hidden></p>
</section>
<section class="rp-card catalog-missing" id="category-missing" hidden>
  <h2>Category not found</h2>
  <p>This category isn’t available. It may have been removed or renamed.</p>
  <a class="rp-button rp-button-secondary" href="new-order.html">Choose another category</a>
</section>
<div class="rp-notice"><strong>Pricing</strong><p>The final total is confirmed at weighing. Offers are applied at checkout.</p></div>'''
    },
    {
        "file": "owner-category-services.html", "title": "Manage services", "role": "Owner", "nav": OWNER_NAV,
        "lead": "Add or edit the services inside this category.",
        "heading": False, "styles": ["catalog.css"], "scripts": ["catalog-store.js", "services-list.js"],
        "body": '''
<a class="rp-back-link" href="services-and-prices.html"><span aria-hidden="true">←</span> Categories</a>
<section class="catalog-hero is-compact" id="owner-category-hero" aria-labelledby="owner-category-name">
  <img class="catalog-hero-image" id="owner-category-image" src="../assets/images/hero-shirt.jpg" alt="">
  <div class="catalog-hero-copy"><p class="rp-kicker">OWNER CATEGORY</p><h1 id="owner-category-name">Shirts</h1><p id="owner-category-description">Everyday shirts, blouses and light tops, finished neatly.</p><span class="catalog-pill" id="owner-category-count">3 services</span></div>
</section>
<section class="rp-card" id="service-list-card" aria-labelledby="service-list-title">
  <div class="rp-section-head"><div><p class="rp-kicker">SERVICES</p><h2 id="service-list-title">In this category</h2></div><span class="rp-count" id="service-list-count">3 available</span></div>
  <div class="admin-service-list" id="service-admin-list"></div>
  <p class="catalog-empty" id="service-admin-empty" hidden>No services in this category yet. Add the first one to get started.</p>
  <a class="rp-button rp-button-primary rp-full catalog-add-button" id="add-service-link" href="add-service.html">Add service</a>
</section>
<section class="rp-card catalog-missing" id="category-admin-missing" hidden>
  <h2>Category not found</h2>
  <p>This category isn’t available. It may have been removed or renamed.</p>
  <a class="rp-button rp-button-secondary" href="services-and-prices.html">Back to categories</a>
</section>
<div class="rp-notice"><strong>Customer menu</strong><p>Active services appear on the customer category page. Hidden services stay in your catalog but are not shown.</p></div>'''
    },
    {
        "file": "add-service.html", "title": "Add service", "role": "Owner", "nav": OWNER_NAV,
        "lead": "Set the price and details customers will see.", "heading": False,
        "styles": ["catalog.css"], "scripts": ["catalog-store.js", "services-editor.js"],
        "body": '''
<a class="rp-back-link" id="service-back-link" href="services-and-prices.html"><span aria-hidden="true">←</span> Services</a>
<section class="catalog-hero is-compact" id="owner-category-hero" aria-labelledby="owner-category-name"><img class="catalog-hero-image" id="owner-category-image" src="../assets/images/hero-shirt.jpg" alt=""><div class="catalog-hero-copy"><p class="rp-kicker">CATEGORY</p><h1 id="owner-category-name">Shirts</h1><p id="owner-category-description"></p></div></section>
<section class="rp-card" id="service-form-card" aria-labelledby="service-form-title">
  <div class="rp-section-head"><div><p class="rp-kicker">OWNER CATALOG</p><h2 id="service-form-title">Add a service</h2></div><span class="rp-status rp-status-neutral" id="service-form-mode">New</span></div>
  <form id="service-form" novalidate>
    <label class="rp-label" for="service-name">Service name</label><input class="rp-input" id="service-name" maxlength="60" autocomplete="off" required placeholder="e.g. Wash &amp; fold">
    <label class="rp-label" for="service-description">Description or benefit</label><textarea class="rp-input rp-textarea" id="service-description" maxlength="220" required placeholder="What does the customer get?"></textarea>
    <div class="form-row"><div><label class="rp-label" for="service-price">Price</label><input class="rp-input" id="service-price" type="number" min="0" step="0.01" inputmode="decimal" required placeholder="2.00"></div><div><label class="rp-label" for="service-unit">Unit</label><select class="rp-input" id="service-unit"><option value="kg">Per kg</option><option value="item">Per item</option><option value="load">Per load</option></select></div></div>
    <label class="rp-label" for="service-duration">Duration</label><input class="rp-input" id="service-duration" maxlength="40" required placeholder="e.g. 6 h">
    <label class="rp-label" for="service-image">Service image</label><div class="image-field"><span class="image-preview" id="service-image-preview" aria-hidden="true"><span>No image</span></span><span class="image-controls"><input id="service-image" type="file" accept="image/*" aria-label="Choose a service image"><small>Optional. Falls back to the category image.</small></span></div>
    <label class="rp-checkline"><input id="service-active" type="checkbox" checked> Available for new orders</label>
    <div class="form-actions"><button class="rp-button rp-button-primary" id="service-submit" type="submit">Add service</button><a class="rp-button rp-button-secondary" id="service-cancel" href="services-and-prices.html">Cancel</a></div><p class="rp-feedback" data-service-feedback aria-live="polite"></p>
  </form>
</section>
<section class="rp-card catalog-missing" id="category-admin-missing" hidden><h2>Category not found</h2><p>This category isn’t available. It may have been removed or renamed.</p><a class="rp-button rp-button-secondary" href="services-and-prices.html">Back to categories</a></section>'''
    },
    {
        "file": "owner-orders.html", "title": "Order oversight", "role": "Owner", "nav": OWNER_NAV, "interactive": True,
        "lead": "Read-only orders, with the latest context for follow-up.",
        "styles": ["dashboard.css"],
        "body": '''
<section class="rp-card"><label class="rp-label" for="owner-order-search">Search orders</label><div class="rp-search"><input id="owner-order-search" type="search" data-order-search placeholder="Try LDR-0042 or Customer A" aria-label="Search orders"><button class="rp-button rp-button-secondary" type="button" data-action="queue-search">Search</button></div><p class="rp-help">Search by order ID, customer or service.</p></section>
<section class="rp-card" aria-labelledby="oversight-title">
  <div class="rp-section-head"><div><p class="rp-kicker">READ ONLY</p><h2 id="oversight-title">Recent orders</h2></div><span class="rp-count">7 orders</span></div>
  <div class="rp-filter-row" role="group" aria-label="Filter orders" data-order-filters><button type="button" class="rp-filter is-selected" data-filter="all">All</button><button type="button" class="rp-filter" data-filter="ready">Ready</button><button type="button" class="rp-filter" data-filter="processing">Processing</button><button type="button" class="rp-filter" data-filter="picked_up">Picked up</button></div>
  <div class="owner-orders-list">
    <details class="owner-order" data-order-row data-status="ready">
      <summary><span class="owner-order-main"><strong>LDR-0042</strong><small>Customer A · Express wash</small></span><span class="rp-status rp-status-warning">Ready</span><span class="owner-order-chevron" aria-hidden="true">›</span></summary>
      <div class="owner-order-body"><div class="rp-detail-row"><span>Payment</span><strong>Unpaid</strong></div><div class="rp-detail-row"><span>Intake</span><span>09:12</span></div><div class="rp-detail-row"><span>Weight</span><span>4.2 kg</span></div><div class="rp-detail-row"><span>Total</span><strong>8.40</strong></div><p class="rp-help">View only. Status, payment and pickup are managed at the counter.</p></div>
    </details>
    <details class="owner-order" data-order-row data-status="processing">
      <summary><span class="owner-order-main"><strong>LDR-0041</strong><small>Customer B · Wash &amp; fold</small></span><span class="rp-status rp-status-neutral">Processing</span><span class="owner-order-chevron" aria-hidden="true">›</span></summary>
      <div class="owner-order-body"><div class="rp-detail-row"><span>Payment</span><strong>Paid · Transfer</strong></div><div class="rp-detail-row"><span>Intake</span><span>08:55</span></div><div class="rp-detail-row"><span>Weight</span><span>5.6 kg</span></div><div class="rp-detail-row"><span>Total</span><strong>11.20</strong></div><p class="rp-help">View only. Status, payment and pickup are managed at the counter.</p></div>
    </details>
    <details class="owner-order" data-order-row data-status="ready">
      <summary><span class="owner-order-main"><strong>LDR-0040</strong><small>Walk-in · Bedding wash &amp; fold</small></span><span class="rp-status rp-status-warning">Ready</span><span class="owner-order-chevron" aria-hidden="true">›</span></summary>
      <div class="owner-order-body"><div class="rp-detail-row"><span>Payment</span><strong>Paid · Cash</strong></div><div class="rp-detail-row"><span>Intake</span><span>08:30</span></div><div class="rp-detail-row"><span>Weight</span><span>3.0 kg</span></div><div class="rp-detail-row"><span>Total</span><strong>7.50</strong></div><p class="rp-help">View only. Status, payment and pickup are managed at the counter.</p></div>
    </details>
    <details class="owner-order" data-order-row data-status="ready">
      <summary><span class="owner-order-main"><strong>LDR-0039</strong><small>Customer A · Press only</small></span><span class="rp-status rp-status-warning">Ready</span><span class="owner-order-chevron" aria-hidden="true">›</span></summary>
      <div class="owner-order-body"><div class="rp-detail-row"><span>Payment</span><strong>Paid · QR</strong></div><div class="rp-detail-row"><span>Intake</span><span>08:02</span></div><div class="rp-detail-row"><span>Items</span><span>4 items</span></div><div class="rp-detail-row"><span>Total</span><strong>14.00</strong></div><p class="rp-help">View only. Status, payment and pickup are managed at the counter.</p></div>
    </details>
    <details class="owner-order" data-order-row data-status="processing">
      <summary><span class="owner-order-main"><strong>LDR-0038</strong><small>Customer B · Dry clean</small></span><span class="rp-status rp-status-neutral">Processing</span><span class="owner-order-chevron" aria-hidden="true">›</span></summary>
      <div class="owner-order-body"><div class="rp-detail-row"><span>Payment</span><strong>Unpaid</strong></div><div class="rp-detail-row"><span>Intake</span><span>07:48</span></div><div class="rp-detail-row"><span>Items</span><span>2 items</span></div><div class="rp-detail-row"><span>Total</span><strong>16.00</strong></div><p class="rp-help">View only. Status, payment and pickup are managed at the counter.</p></div>
    </details>
    <details class="owner-order" data-order-row data-status="ready">
      <summary><span class="owner-order-main"><strong>LDR-0037</strong><small>Customer A · Express wash</small></span><span class="rp-status rp-status-warning">Ready</span><span class="owner-order-chevron" aria-hidden="true">›</span></summary>
      <div class="owner-order-body"><div class="rp-detail-row"><span>Payment</span><strong>Unpaid</strong></div><div class="rp-detail-row"><span>Intake</span><span>07:20</span></div><div class="rp-detail-row"><span>Weight</span><span>3.8 kg</span></div><div class="rp-detail-row"><span>Total</span><strong>15.20</strong></div><p class="rp-help">View only. Status, payment and pickup are managed at the counter.</p></div>
    </details>
    <details class="owner-order" data-order-row data-status="picked_up">
      <summary><span class="owner-order-main"><strong>LDR-0036</strong><small>Walk-in · Wash &amp; fold</small></span><span class="rp-status rp-status-neutral">Picked up</span><span class="owner-order-chevron" aria-hidden="true">›</span></summary>
      <div class="owner-order-body"><div class="rp-detail-row"><span>Payment</span><strong>Paid · Cash</strong></div><div class="rp-detail-row"><span>Intake</span><span>06:55</span></div><div class="rp-detail-row"><span>Weight</span><span>6.1 kg</span></div><div class="rp-detail-row"><span>Total</span><strong>12.20</strong></div><p class="rp-help">View only. Status, payment and pickup are managed at the counter.</p></div>
    </details>
  </div>
  <p class="rp-empty" data-order-empty hidden>No orders match this search.</p>
</section>
<div class="rp-notice"><strong>View only</strong><p>Status, payment and pickup are managed by the counter team.</p></div>'''
    },
    {
        "file": "activity-log.html", "title": "Activity log", "role": "Owner", "nav": OWNER_NAV,
        "lead": "Who changed what, when, and the old → new value.",
        "styles": ["activity.css"], "scripts": ["catalog-store.js", "activity-log.js"],
        "body": '''
<section class="rp-card" aria-labelledby="activity-title">
  <div class="rp-section-head"><div><p class="rp-kicker">AUDIT TRACE</p><h2 id="activity-title">Activity</h2></div><span class="rp-count" id="session-count">0 recent changes</span></div>
  <div class="rp-filter-row" role="group" aria-label="Filter activity"><button type="button" class="rp-filter is-selected" data-activity-filter="all">All</button><button type="button" class="rp-filter" data-activity-filter="catalog">Catalog</button><button type="button" class="rp-filter" data-activity-filter="orders">Orders</button><button type="button" class="rp-filter" data-activity-filter="vouchers">Vouchers</button></div>
  <div class="audit-feed" data-activity-feed>
    <article class="audit-event" data-event-type="orders">
      <span class="audit-node" aria-hidden="true"></span>
      <div class="audit-main"><div class="audit-head"><span class="audit-actor">Clerk K</span><span class="audit-time">Today · 09:42</span><span class="audit-badge is-history">Order</span></div><h3>Order LDR-0041 status updated</h3><dl class="audit-changes"><div><dt>Status</dt><dd><span class="audit-old">Received</span><span class="audit-arrow" aria-hidden="true">→</span><span class="audit-new">Processing</span></dd></div></dl></div>
    </article>
    <article class="audit-event" data-event-type="orders">
      <span class="audit-node" aria-hidden="true"></span>
      <div class="audit-main"><div class="audit-head"><span class="audit-actor">Clerk K</span><span class="audit-time">Today · 09:15</span><span class="audit-badge is-history">Payment</span></div><h3>Order LDR-0041 payment recorded</h3><dl class="audit-changes"><div><dt>Payment</dt><dd><span class="audit-old">Unpaid</span><span class="audit-arrow" aria-hidden="true">→</span><span class="audit-new">Paid · Transfer</span></dd></div></dl></div>
    </article>
    <article class="audit-event" data-event-type="vouchers">
      <span class="audit-node" aria-hidden="true"></span>
      <div class="audit-main"><div class="audit-head"><span class="audit-actor">Owner</span><span class="audit-time">Today · 08:20</span><span class="audit-badge is-history">Voucher</span></div><h3>Voucher WELCOME10 minimum spend updated</h3><dl class="audit-changes"><div><dt>Minimum spend</dt><dd><span class="audit-old">5.00</span><span class="audit-arrow" aria-hidden="true">→</span><span class="audit-new">3.00</span></dd></div></dl></div>
    </article>
    <article class="audit-event" data-event-type="catalog">
      <span class="audit-node" aria-hidden="true"></span>
      <div class="audit-main"><div class="audit-head"><span class="audit-actor">Owner</span><span class="audit-time">Today · 08:05</span><span class="audit-badge is-history">Catalog</span></div><h3>Service “Wash &amp; fold” price updated</h3><dl class="audit-changes"><div><dt>Price</dt><dd><span class="audit-old">1.80 / kg</span><span class="audit-arrow" aria-hidden="true">→</span><span class="audit-new">2.00 / kg</span></dd></div></dl></div>
    </article>
    <article class="audit-event" data-event-type="catalog">
      <span class="audit-node" aria-hidden="true"></span>
      <div class="audit-main"><div class="audit-head"><span class="audit-actor">Owner</span><span class="audit-time">Today · 07:58</span><span class="audit-badge is-history">Catalog</span></div><h3>Category “Bedding” description updated</h3><dl class="audit-changes"><div><dt>Description</dt><dd><span class="audit-old">Sheets and covers.</span><span class="audit-arrow" aria-hidden="true">→</span><span class="audit-new">Sheets, duvet covers and household linen for a fresh reset.</span></dd></div></dl></div>
    </article>
    <article class="audit-event" data-event-type="orders">
      <span class="audit-node" aria-hidden="true"></span>
      <div class="audit-main"><div class="audit-head"><span class="audit-actor">Clerk K</span><span class="audit-time">Today · 07:40</span><span class="audit-badge is-history">Order</span></div><h3>Order LDR-0040 status updated</h3><dl class="audit-changes"><div><dt>Status</dt><dd><span class="audit-old">Processing</span><span class="audit-arrow" aria-hidden="true">→</span><span class="audit-new">Ready</span></dd></div></dl></div>
    </article>
  </div>
  <p class="rp-empty" data-activity-empty hidden>No activity matches this filter.</p>
  <p class="audit-session-empty" id="session-empty">No catalog changes yet. Add or edit a service to see the trace here.</p>
</section>
<div class="rp-notice"><strong>Catalog history</strong><p>Every catalog change is recorded with the owner account, time and old → new values.</p></div>'''
    },
    {
        "file": "owner-more.html", "title": "More", "role": "Owner", "nav": OWNER_NAV,
        "lead": "Orders, activity, settings and shop tools.",
        "body": '''
<section class="rp-card"><div class="rp-section-head"><div><p class="rp-kicker">OWNER</p><h2>Owner tools</h2></div></div>
<a class="rp-list-row" href="owner-orders.html"><span class="rp-row-main"><strong>Order oversight</strong><small>Read-only view of recent orders</small></span><span class="rp-chevron" aria-hidden="true">›</span></a>
<a class="rp-list-row" href="activity-log.html"><span class="rp-row-main"><strong>Activity log</strong><small>Order, payment and catalog changes</small></span><span class="rp-chevron" aria-hidden="true">›</span></a>
<a class="rp-list-row" href="settings.html"><span class="rp-row-main"><strong>Settings</strong><small>Loyalty and order timing</small></span><span class="rp-chevron" aria-hidden="true">›</span></a>
<a class="rp-list-row" href="shop-tools.html"><span class="rp-row-main"><strong>Shop tools</strong><small>Catalog status and restore defaults</small></span><span class="rp-chevron" aria-hidden="true">›</span></a>
</section>
'''
    },
]


def page_html(page):
    nav_html = page_nav(page["nav"], page["file"], page["role"])
    title = escape(page["title"])
    lead = escape(page["lead"])
    header = page_header(page["role"])
    body_class = f' rp-page {page["body_class"]}' if page.get("body_class") else " rp-page"
    role_attr = "guest" if page["role"] == "Everyone" else page["role"].lower()
    heading_html = "" if page.get("heading") is False else f'<header class="rp-page-heading"><h1>{title}</h1><p>{lead}</p></header>'
    styles = "".join(
        f'  <link rel="stylesheet" href="../assets/css/{escape(name)}">\n'
        for name in page.get("styles", [])
    )
    scripts = "".join(
        f'  <script src="../assets/js/{escape(name)}"></script>\n'
        for name in page.get("scripts", [])
    )
    shared_script = '  <script src="../assets/js/review-pages.js"></script>\n' if page.get("interactive") else ""
    dock_html = ORDER_DOCK if page.get("dock") else ""
    dashboard_attr = f' data-dashboard="{escape(page["dashboard"])}"' if page.get("dashboard") else ""
    return f'''<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
  <meta name="theme-color" content="#dfedf6">
  <meta name="description" content="{title} — Washday laundry shop.">
  <title>{title} · Washday</title>
  <link rel="icon" href="../assets/images/favicon.svg" type="image/svg+xml">
  <link rel="stylesheet" href="../assets/css/tokens.css">
  <link rel="stylesheet" href="../assets/css/base.css">
  <link rel="stylesheet" href="../assets/css/review-pages.css">
{styles}</head>
<body class="{body_class.strip()}" data-role="{escape(role_attr)}"{dashboard_attr}>
  <div class="ambient" aria-hidden="true"></div>
  {header}
  <main class="rp-main">
    {heading_html}
    {page["body"]}
  </main>
  {dock_html}
  {nav_html}
{shared_script}{scripts}</body>
</html>
'''


def page_nav(nav, active_file, role):
    if not nav:
        return ""
    selected_label = ACTIVE_NAV.get(active_file, active_file)
    links = []
    for label, target in nav:
        selected = label == selected_label
        current = ' aria-current="page"' if selected else ""
        links.append(
            f'<a class="nav-item{" active" if selected else ""}" href="{escape(target)}"{current}>'
            f'<svg viewBox="0 0 24 24" aria-hidden="true">{NAV_ICONS[label]}</svg><span>{escape(label)}</span></a>'
        )
    return f'<nav class="bottom-nav" aria-label="{escape(role)} navigation">{"".join(links)}</nav>'


def page_header(role):
    role = escape(role)
    bell = ""
    avatar_html = ""
    profile_href = ""
    profile_aria = ""
    profile_label = ""
    if role == "Customer":
        avatar_html = '<img class="avatar avatar-sm" src="../assets/images/customer-alex.jpg" alt="">'
        profile_href = "login.html"
        profile_aria = "Current profile: Customer A; switch account"
        profile_label = "Customer A"
        brand_href = "customer-home.html"
        bell = (
            '<a class="bell-button" href="notifications.html" aria-label="Notifications, one unread">'
            '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4"/></svg><span class="unread-dot" aria-hidden="true"></span></a>'
        )
    elif role == "Clerk":
        avatar_html = '<span class="avatar avatar-sm role-avatar" aria-hidden="true">K</span>'
        profile_href = "login.html"
        profile_aria = "Current profile: Clerk; switch account"
        profile_label = "Clerk"
        brand_href = "clerk-home.html"
    elif role == "Owner":
        avatar_html = '<span class="avatar avatar-sm role-avatar" aria-hidden="true">O</span>'
        profile_href = "login.html"
        profile_aria = "Current profile: Owner; switch account"
        profile_label = "Owner"
        brand_href = "owner-home.html"
    else:
        brand_href = "index.html"
    actions_html = ""
    if profile_label:
        actions_html = (
            f'<div class="header-actions">'
            f'<a class="profile-switch" href="{profile_href}" aria-label="{profile_aria}">{avatar_html}'
            f'<span class="profile-name">{profile_label}</span><svg viewBox="0 0 16 16" aria-hidden="true"><path d="m4 6 4 4 4-4"/></svg></a>'
            f'{bell}</div>'
        )

    return f'''<header class="topbar">
    <div class="account-row">
      <a class="brand-lockup" href="{brand_href}" aria-label="Washday home">
        <span class="brand-mark" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 3.2c2.9 3.7 5.6 7 5.6 10.2a5.6 5.6 0 1 1-11.2 0c0-3.2 2.7-6.5 5.6-10.2Z" fill="currentColor"/><path d="M9.4 13.3c.2 1.6 1.3 2.6 2.8 2.8" fill="none" stroke="#0e1115" stroke-width="1.5" stroke-linecap="round"/></svg></span>
        <span class="brand-wordmark">Washday<svg class="brand-spark" viewBox="0 0 12 12" aria-hidden="true"><path d="M6 .6 7 5l4.4 1L7 7 6 11.4 5 7 .6 6 5 5Z" fill="currentColor"/></svg></span>
      </a>
      {actions_html}
    </div>
  </header>'''


def main():
    pages_dir = ROOT / "pages"
    pages_dir.mkdir(parents=True, exist_ok=True)
    for page in PAGES:
        (pages_dir / page["file"]).write_text(page_html(page), encoding="utf-8")
    print(f"Generated {len(PAGES)} screens in {pages_dir}")


if __name__ == "__main__":
    main()
