# Washday prototype — app walkthrough

The prototype opens like a normal app. `pages/index.html` is the Welcome screen with a brand hero and a **Get started** action; it leads to `pages/login.html`, a sign-in screen with email/password fields and four role accounts, and from there into the customer, clerk or owner area. There is no separate screen index; every view is reached through the app’s own links and role navigation.

Customer Home is the canonical reference for the shared compact top app bar and floating icon-plus-label navigation; device status chrome is not simulated. It retains the single current READY order card, uses an order-first layout with a floating New order dock above the navigation, and keeps the WELCOME10 offer and loyalty progress. The app has 27 pages: the Welcome entry plus 26 app screens. All 16 PRD screens, Customer Vouchers/Profile destinations, Clerk and Owner Home dashboards, the owner catalog pages, Owner Orders, Activity log, dedicated add-category and add-service forms, and an Owner More hub are reachable through the app’s own navigation. The catalog list pages show categories or services with separate add actions; category and service forms are on their own pages. Customer tabs are Home, Orders, Vouchers and Profile; Clerk tabs are Home, Queue and New order; Owner tabs are Home, Services, Vouchers and More (Orders, Activity log, Settings and Shop tools live under More). Daily Summary is retired and its content is covered by Owner Home. Below 380 px, all tabs stack the icon above the label so labels stay readable.

## Visual system

The calibration pass applies a “Washday glass” system: locally bundled Inter Tight, a pale icy-blue wash, frosted white surfaces, 24–28 px card radii, large order IDs, teal completed states, amber current states, and a black primary action. The shared shell is a single compact top app bar — brand, role profile and bell where relevant — with equal-width icon-plus-label tabs; the simulated device status strip is removed. A shared type/spacing scale gives display headings, 15 px body copy and 11–13 px label/meta rhythm. Home leads with the greeting and active order, followed by the offer and loyalty, with a black New order dock pinned above the bottom navigation on Home and Orders. The generated Clerk and Owner screens use a slightly denser shared card scale; the counter-order customer fields use an even two-column grid. Dashboards render deterministic fixtures as operational metrics, queue bars, weekly sales and service mix; the fixture source is documented below. The catalog uses category/service cards with local images, prices, units, durations and descriptions. Shop tools offers catalog status, a reload link and a catalog restore. The inline photo card, full-bleed hero and bottom fade are retired. Welcome, Sign in, Home, Order Detail, New Order and Category Services carry detailed styling; the remaining screens inherit the shared generated-page styles. All in-app copy is written as a real shop app; synthetic-data and local-state boundaries are documented here rather than shown as banners. The full set is a visual review prototype awaiting user feedback, not an approved or production build.

## Open this review

Open `pages/index.html` to start at Welcome, then **Get started** to reach sign-in. Choose a role account to enter that area, or use the form to open Customer A. The password field has a local Show/Hide control. From there, use the bottom navigation, header controls and in-page links to move between the views. This is a local visual prototype, not a complete or connected application.

To try the owner catalog: open **Owner → Services**, add a category with a name, description and optional image, then open it and add services with a price, unit, duration, description and optional image. Changes are stored in this browser tab and appear on **New order** and the customer category page. **More → Activity log** shows earlier history events plus recent catalog changes with old → new values. **More → Shop tools → Restore** returns the default four categories and twelve services and clears recent catalog activity.

## Files

- `pages/index.html` — Welcome entry: brand hero, order card and Get started.
- `pages/login.html` — sign-in form plus a compact role-account dropdown; choosing an account fills its sign-in fields and selects that role’s destination. The prototype does not authenticate.
- `pages/customer-home.html` — detailed Home with greeting, active order, offer, loyalty and floating New order dock.
- `pages/new-order.html`, `pages/category-services.html` — category-first order flow and the category-specific service page; no order is created.
- `pages/order-detail.html`, `order-history.html`, `customer-vouchers.html`, `customer-profile.html`, `loyalty.html`, `notifications.html` — customer screens.
- `pages/clerk-home.html`, `order-queue.html`, `weigh-and-confirm.html`, `staff-order-detail.html`, `new-order-for-customer.html` — Clerk Home with shift overview, queue and order processing screens.
- `pages/owner-home.html`, `services-and-prices.html`, `add-category.html`, `owner-category-services.html`, `add-service.html`, `vouchers.html`, `owner-orders.html`, `activity-log.html`, `settings.html`, `shop-tools.html`, `owner-more.html` — Owner Home with operational dashboards, category/service list and add pages, read-only order oversight, audit log and shop tools.
- `assets/css/tokens.css`, `assets/css/base.css` — shared design tokens, local font face, compact branded app bar, floating navigation and a global `[hidden]` guard.
- `assets/css/welcome.css`, `login.css`, `customer-home.css`, `new-order.css`, `order-detail.css` — detailed page styles.
- `assets/css/review-pages.css` — shared generated-page styles.
- `assets/css/catalog.css` — category tiles, category hero, service choices and owner catalog forms.
- `assets/css/dashboard.css` — dashboard metrics, charts and read-only order oversight.
- `assets/css/activity.css` — audit feed, old → new change pills and event badges.
- `assets/js/catalog-store.js` — shared category/service store, validation, session storage, local image compression and session audit events.
- `assets/js/new-order.js`, `category-services.js` — category-first selection and category-specific service rendering.
- `assets/js/services-admin.js`, `services-list.js`, `category-form.js`, `services-editor.js` — owner category list, category add form, service list and service add/edit form.
- `assets/js/dashboard-data.js`, `dashboard.js` — deterministic analytics fixtures and renderer.
- `assets/js/activity-log.js` — session audit events, filters and old → new rendering.
- `assets/js/login.js` — account dropdown that fills the sign-in fields and destination, plus the local password Show/Hide control; no authentication or persistence.
- `assets/js/review-pages.js` — interactive on-screen controls; loaded only by screens that use them.
- `tools/generate-review-pages.py` — repeatable generator for 24 generated screens. Welcome, Customer Home and New Order are hand-built.
- `assets/fonts/InterTight-Variable.woff2` — Inter Tight variable font, The Inter Project Authors; SIL Open Font License 1.1; upstream https://github.com/rsms/inter-tight; license copy at `assets/fonts/OFL.txt`.
- `assets/images/` — illustrative local photography listed under Asset provenance below, plus a locally created brand favicon.
- `../tests/` — Node built-in tests.

No remote resources are loaded at runtime.

## Asset provenance

All photography is illustrative; order records do not imply that customer garment photos are stored. Pexels images are used under the Pexels license (https://www.pexels.com/license/); attribution is recorded here even where the license does not require it.

| Local file | Source | Author |
| --- | --- | --- |
| `assets/images/hero-shirt.jpg` | Pexels photo 28576622 (https://www.pexels.com/photo/28576622/) | Jonathan Borba |
| `assets/images/login-hero.jpg` | Pexels photo 4959880, “Close-up of Woman Holding Basket with Fresh Laundry” (https://www.pexels.com/photo/close-up-of-woman-holding-basket-with-fresh-laundry-4959880/) | Kaboompics.com |
| `assets/images/category-pants.jpg` | Pexels photo 6069087 (https://www.pexels.com/photo/6069087/) | cottonbro studio |
| `assets/images/category-dresses.jpg` | Pexels photo 8997984 (https://www.pexels.com/photo/8997984/) | PNW Production |
| `assets/images/category-bedding.jpg` | Pexels photo 31902663 (https://www.pexels.com/photo/31902663/) | juan pinales |
| `assets/images/customer-alex.jpg` | Unsplash portrait (https://unsplash.com/photos/a-smiling-woman-poses-for-a-portrait-cdZcNIca4w0) | Brooke Balentine |

The Inter Tight font is licensed under the SIL Open Font License 1.1; the full license text is kept at `assets/fonts/OFL.txt`.

`assets/images/favicon.svg` is an original local brand mark created for this prototype; it contains no third-party artwork.

No new external images or fonts were added for the dashboards, catalog or activity log. Owner-added images are local files resized in the browser to JPEG data URLs; they never leave the tab.

## Data and behavior boundaries

The Home page retains one synthetic active-order card (LDR-0042, READY), followed by the WELCOME10 offer (10% off, minimum spend 3.00, discount cap 5.00) and loyalty progress (5/10). A black New order dock is pinned above the navigation on Home and Orders. New Order creates no order.

Clerk Home and Owner Home render deterministic fixtures from `dashboard-data.js`. Clerk sales are fixed at 184.50; Owner sales are 412.80 with a seven-day trend, service mix and follow-up alerts. The app presents these as operational figures, but they are synthetic and must not be treated as live takings in review notes. Owner Orders is a read-only seven-order view; it cannot change status, payment or pickup.

The catalog starts with four image-backed categories (Shirts, Pants, Dresses, Bedding) and twelve services. The owner can add categories with a name, description and optional local image, then add or edit services with a name, description/benefit, price, unit (kg, item or load), duration, optional image and availability. Categories and services are stored in `sessionStorage` for this browser tab only; re-opening the tab restores the default catalog. A service without its own image uses its category image, then a styled icon tile if neither image is set. Activity log combines earlier history events with recent catalog events. Shop tools restore clears catalog changes and recent audit events.

There is no real account, order creation, payment, notification delivery, scanner, setting persistence, voucher redemption, file upload, image upload, time simulation, backend or external shop system. The sign-in form and profile switching are navigation mockups: credentials are not checked and no account exists. Customer B opens the same static view. Weigh/payment/notification actions update the screen only. The complete 27-page set is a visual review prototype awaiting owner feedback, not a working end-to-end system. Category and service creation/edit pages are separate from the catalog lists; changes remain in the current tab's session storage.

## Run and test

Open `pages/index.html` directly in a browser. No server or network is required. All app pages work from local files; `sessionStorage` catalog changes are scoped to the tab that made them. Regenerate the generated screens with `python prototype/tools/generate-review-pages.py` from the project root. Run checks with `node --test tests/*.test.cjs` and syntax-check every local script with:

```sh
for f in prototype/assets/js/*.js; do node --check "$f" || exit 1; done
```

No Git repository is present in this project directory; no branch or commit is claimed.
