# Washday mobile frontend

A Flutter frontend for a single-shop wash-and-fold service, built from the local `prototype/` design reference. It is a mobile-first UI preview for iOS and Android; the browser build exists only for quick visual review.

This is not a production app. It has no backend, live account system, durable orders, printed receipts, scanning or sync yet. Orders, catalog edits, sessions and preference switches live in app memory and reset on restart. The app UI uses natural product copy; the fixture and local-state boundaries are documented here and in `PROJECT_INTAKE.md`, not shown as in-app banners.

## Run

```powershell
cd mobile
flutter pub get
flutter run -d <device-id>
```

Targets: iOS and Android. For a local visual preview without a device:

```powershell
flutter run -d chrome
# or
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8085
```

The web preview is a convenience only. Flutter's web debug tooling may load engine artifacts such as CanvasKit from Flutter's CDN; the app itself references only bundled assets.

## Screens

Welcome → Sign in leads to three role areas. The preview has 30 screens across 35 routes: 13 customer routes, 6 clerk routes, 14 owner routes, plus Welcome and Sign in. Settings is shared by all three roles, and the staff order detail and weigh screens are shared by Clerk and Owner.

- **Customer:** Home, Orders, Order detail, Receipt, Vouchers, Profile, Loyalty, Notifications, Settings, New order, Category services, Checkout, Order placed.
- **Clerk:** Home, Queue, Staff order detail, Counter order, Weigh and confirm, Settings.
- **Owner:** Home, Service catalog, Category services, Add category, Add/edit service, Vouchers, More, Orders, Staff order detail, Weigh and confirm, Activity log, Shop settings, Settings.

Routes live in `lib/app/router.dart`. Sign in requires an explicit submit: the account picker only fills the seeded email and password, and empty fields, an unknown email or a wrong password show inline errors instead of routing. The signed-in role decides the shell and start route. Customer tabs are Home / Orders / Vouchers; Profile, Notifications and Loyalty live under Settings. Clerk tabs are Home / Queue / New order; Owner tabs are Home / Services / Vouchers / More. Owner More contains Orders, Activity log, Shop settings and Switch account; there is no Shop tools screen. The top-bar account chip shows the signed-in account’s name and photo and opens a flat menu with Settings and Log out for every role; Owner Settings also links to Shop settings. Customer Home and Orders carry the floating New order dock above the bottom navigation. Pull-to-refresh is available on the primary read screens after sign-in: customer Home, Orders, Vouchers, Notifications, Loyalty, Profile and category services; clerk Home and Queue; owner Home, catalog, vouchers, orders, activity and category services. Forms, order details, receipts and settings stay static. Customer Orders keeps All / Active / Declined / Collected chips in a one-line row that scrolls horizontally with disabled-aware ‹ › nudge buttons, and a compact Filters button beside them. the Filter orders sheet combines those statuses with Any date / Today / Last 7 days / Last 30 days / Custom range. Custom range opens a compact one-month calendar sheet with separate Start/End field buttons, Clear and Use dates. Its loading state uses a finite skeleton announced as “Loading orders”, while other screens use the standard spinner. The web build also accepts mouse drag so the interaction is reviewable without a touch device.

## Order lifecycle

An order moves Pending → Accepted → Received → Processing → Ready → Picked up. Declined and Cancelled are terminal states.

- **Customer:** New order → Category services → Checkout → Order placed creates a pending order in app memory with the next `LDR-` number. The customer can cancel while it is Pending; the cancelled order stays in history under All only.
- **Clerk and Owner:** both can accept, decline with a required reason, record drop-off, weigh and record payment, mark ready and mark picked up. Clerk uses `/clerk/queue/:id` and `/clerk/weigh?order=<id>`; Owner uses `/owner/orders/:id` and `/owner/orders/:id/weigh` and keeps the owner shell and back links.
- The weigh screen combines weight confirmation and payment; payment can also be recorded from the order detail once the laundry has been received.
- Orders chips are All / Active / Declined / Collected. Cancelled orders appear under All only, and a decline reason is shown on both the customer and staff order detail.
- The Activity log records the acting role (Clerk or Owner) with each order event, old → new status and payment changes.

## Design

The app keeps the Welcome-established Washday identity — Inter Tight, a cool off-white canvas and petrol teal — in a flat Swiss-utility system. Cards and panels are opaque white with hairline borders; headings are deep-ink editorial type with tight tracking; teal marks status and actions; shadows are limited to the deep dashboard hero, image overlays and receipt paper. Top bars are opaque canvas with a bottom hairline, and the account picker, sheets and dialogs are flat surfaces. Shared tokens and type live in `lib/app/theme.dart`, components in `lib/shared/ui.dart`, and dashboard primitives in `lib/features/dashboard/dashboard_widgets.dart`.

## Structure

```text
lib/
  app/       app entry, theme, roles, router
  data/      models, seed, order/session/catalog controllers, clock
  features/  auth, welcome, customer, clerk, owner, settings, dashboard
  shared/    shell, top bar, bottom nav, order dock, page and UI primitives
assets/      local images and Inter Tight font
test/        widget, lifecycle and catalog tests
```

The owner catalog is a Riverpod `Notifier` (`lib/data/catalog_controller.dart`). Add, edit and hide actions update the current app session and record activity events with old → new values. The controller keeps reset and clear helpers for tests; the app no longer surfaces a Shop tools screen. The same catalog feeds the customer New order/category pages and the Clerk counter-order form; hidden services are excluded from customer and clerk menus.

## Current data and state

- The seed in `lib/data/seed.dart` holds 16 orders anchored to the launch day on the UTC+7 shop clock: Customer A has 10 orders covering active, declined, collected and cancelled states, Customer B has 5, and there is one walk-in order. Initial requests are `LDR-0051` and `LDR-0052`; the next placed order is `LDR-0053`. Re-anchoring happens at launch, not on a live midnight timer.
- Accounts, loyalty, vouchers, notifications and starting activity events come from the same seed. Sign-in checks fixed seeded email/password pairs and routes by role; the account picker only fills the fields. Log out clears the session.
- Orders and activity live in an in-memory `OrdersController` with place, accept, decline, cancel, drop-off, weigh/payment, ready and pickup actions. They reset on app restart and never contact a server.
- Dashboard KPI, chart and service-mix figures are deterministic synthetic shop-facing fixtures, not live takings or analytics. Dashboard recent orders and the customer views read the session orders.
- Customer New order → Category services → Checkout → Order placed creates a pending in-memory order. The customer can cancel while it is Pending; cancelled orders appear only under All.
- Customer Orders has immediate All / Active / Declined / Collected chips and a compact Filters button beside them. The Filter orders sheet combines status with Any date / Today / Last 7 days / Last 30 days / Custom range, using draft selections until Apply filters. Custom range opens a compact one-month calendar sheet instead of the full-screen range picker: month arrows cover January of the current shop year through the current month, and Start and End are separate field buttons. Tap Start or End to make it the active field, then tap a day; one calendar tap changes only the active field. End is unavailable until Start is set, End cannot precede Start, a same-day range is allowed, Clear resets both, and Use dates returns the range to the filter sheet once both fields are set. Dates after today are disabled. Active status or date filters show a dot on the Filters button and an active date as a removable tag; the count pill reads “3 orders” or the visible “n of 3”, and Clear filters resets both. Pull-to-refresh replays a 700 ms skeleton over the same orders; other primary screens use the standard 700 ms spinner. Filtering and refresh never fetch or change an order.
- Receipts are in-app views for collected orders, built from the order’s recorded payment data. There is no print, download or share action.
- The customer Vouchers page copies the WELCOME10 code to the local clipboard and shows an in-place “Copied” state for two seconds. It does not redeem the voucher or create an order.
- Catalog edits, Settings preference switches and the signed-in session are in memory for the app session. They disappear when the app restarts.
- No upload, print, scan, notification delivery, real payment or external side effect occurs.

## Checks

```powershell
cd mobile
dart format lib test
flutter analyze
flutter test
```

The tests load the bundled Inter Tight font so narrow-phone layout checks use real text metrics. They cover catalog add/edit/visibility/reset, the anchored Welcome action and removed sample order, Welcome → Sign in → Customer/Owner navigation, a 360 px customer-home layout check, the sign-in screen without a back link and its empty-field, unknown-email and wrong-password validation, the account menu → Settings → Help → log out flow, account and help-sheet outside-tap dismissal, the Orders filter sheet with Today, presets, the compact month calendar with separate Start/End fields, active-field-only date changes, month navigation and Clear/Use dates, combined counts and clearing, initial skeleton loading and pull-to-refresh completion, pull-to-refresh presence on the 15 primary role routes, the itemized in-app receipt, customer voucher copy feedback and clipboard content, a customer place-and-cancel flow, the Clerk accept → drop-off → weigh/pay → ready → pickup flow, Clerk decline with a required reason, Owner lifecycle parity, and a layout sweep of all 35 routes at 360 px. The test clock is fixed to 14 Oct 2026, 10:24 so date presets, the January–October calendar bounds and the seed’s day offsets stay deterministic.

Visual checks should be run at 360, 390 and 430 px widths, looking for horizontal overflow, fixed dock/navigation overlap and missing images. The 2026-11-15 order lifecycle pass at 390 px confirmed that an empty sign-in submit showed “Enter your email address.”, the account picker filled Customer A’s seeded credentials without navigating, and Sign in opened Customer Home. Customer A placed `LDR-0053` through Shirts → Wash & fold → Checkout → Order placed, then cancelled it from the order detail through the confirmation dialog; Orders showed “11 orders” with Active “6 of 11” and the cancelled order under All. Clerk accepted `LDR-0051`, recorded drop-off, entered 2.0 kg, paid 8.00 by Cash on the weigh screen, marked it ready and picked it up. Clerk declined `LDR-0052` only after entering a reason. Owner ran `LDR-0044` through 4.0 kg / 8.00 Cash, ready and picked up, and the Activity log showed Owner as the actor. Owner More listed Orders, Activity log, Shop settings and Switch account with no Shop tools row. Customer Home, the cancelled order detail and Checkout were checked at 360, 390 and 430 px, and a Clerk order detail at 360 px. A 2026-11-16 spot check confirmed the Clerk order detail and Owner Orders at 430 px. No horizontal overflow appeared. A 2026-11-17 pass replaced the wrapping status chips with a single scrollable row plus ‹ › nudge buttons that disable at each end; verified at 360, 390 and 430 px that the row scrolls, Collected and Filters stay reachable, and the arrows disappear into their disabled state at the extremes. Earlier, before the seed re-anchor, the compact Choose dates calendar was checked at 360, 390 and 430 px; its separate Start/End field cards, helper line, month header, calendar grid and Clear/Use dates controls stayed visible without horizontal overflow. At 390 px, Start was active by default and End was disabled; tapping 1 Sep set only Start, tapping End and then 14 Oct set only End and produced “44 days selected”; tapping Start again moved to September, and 30 Sep produced “15 days selected” while End stayed 14 Oct. Restoring 1 Sep and tapping Use dates returned “1 Sep – 14 Oct” to the filter sheet; applying it showed 3 of 3 with the removable tag. The calendar now follows the current shop day — January of the current year through the current month, with future dates disabled — while the tests fix the clock to 14 Oct 2026 so the January–October bounds stay deterministic. Earlier pre-re-anchor checks (2026-11-14) recorded Last 7 days 2 of 3, Today 1 of 3, Active plus a range 1 of 3, and Clear filters restoring 3 orders. Pull-to-refresh was browser-exercised on Customer Home and Orders, Clerk Home and Owner Home at 390 px; the Orders skeleton and the standard spinner were both captured. The filter, calendar and account sheets on Orders open above the floating dock. Earlier passes covered every role area at 390 px, the account/settings flow, voucher Copy/Copied feedback, catalog add/reset, staff payment and pickup, oversight expansion and activity filtering. These interactions remain local to the session.

## Pending integrations

- **Receipts:** in-app only for the preview. Collected orders show an itemized receipt from the order’s recorded payment; there is no printer integration. Durable receipt storage and sharing would need the backend.
- **QR/barcode scanning:** planned with `mobile_scanner`; not implemented.
- **Offline sync and backend:** planned with Supabase (Postgres, Auth, Storage, Realtime, Edge Functions) and PowerSync for offline queueing. Order mutations should go through Postgres RPCs or Edge Functions, not raw client table writes; do not mix direct writes with PowerSync.
- **Production data:** schema, row-level security, authentication, idempotent order creation, conflict handling and audit persistence are not started.

## Assets and provenance

- `assets/fonts/InterTight-Variable.ttf` — Inter Tight variable font, The Inter Project Authors; SIL Open Font License 1.1; license at `assets/fonts/OFL.txt`; upstream <https://github.com/rsms/inter-tight>.
- Laundry photography is copied from the local prototype under the Pexels and Unsplash licenses. Authors and source URLs are recorded in `prototype/README.md`; photography is illustrative and does not represent stored customer garment photos.
- No remote assets are referenced by the app at runtime.

## Repository note

The working directory has no Git repository, so changes are not tracked with Git.
