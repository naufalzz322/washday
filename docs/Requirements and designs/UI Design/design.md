# Design System: Laundry App

Mobile-first design spec for the customer, clerk and owner apps described in the PRD (v1.0) and `laundry_schema.sql`.

**Source of truth.** Buttons, typography and color come from the CleanPro references (images 3 and 4): a black primary button, tight grotesque type, frosted-glass cards on a pale sky-blue wash, with teal and amber accents. Everything else (components, layouts, status mapping) is derived from those references and fitted to the PRD. Where a value is an estimate read off a reference image, it is marked **(est.)**.

---

## 1. Principles

1. **Calm and airy.** Pale blue-grey backgrounds, frosted cards, generous space. Laundry should feel clean, and the screens should too.
2. **Black is the action.** One solid black button per screen is the primary action. Color elsewhere is reserved for status.
3. **Status is the story.** Orders move through seven statuses. Teal means done, amber means in progress, red means a problem. The vertical timeline from the reference is the signature element.
4. **Numbers are legible.** Prices, weights and order IDs use large, tabular figures. The clerk's weighing screen must be usable in under 30 seconds (PRD section 8).
5. **Never show a total before weighing.** Before drop-off, customers see only the unit price (FR-C5). The total appears only after the clerk confirms the weight.

### What was taken from the references

| Reference | Taken | Not used |
| --- | --- | --- |
| CleanPro (images 3, 4) | Black buttons with arrow-up-right, tight two-tone headlines, frosted-glass cards, vertical dotted timeline with teal/amber nodes, corner tags on cards, checkout-summary card with dotted divider, square frosted icon buttons, pale blue gradient | Map, courier card, delivery and "Pay by Card" (out of scope per PRD sections 2 and 6.7) |
| LaundryEase (images 1, 2, 5) | Layout ideas only: greeting header with bell, status banner on Home, 2-column service cards, promo cards showing voucher codes, floating bottom nav, onboarding hero with one CTA | Purple palette, yellow accents, rounded-purple nav, its type style |

---

## 2. Color

### 2.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `ink-950` | `#0E0F11` | Primary button fill, strongest text, selected states |
| `ink-800` | `#1C2733` | Headlines and body text on light surfaces (navy-tinted charcoal) |
| `slate-500` | `#5E7384` | Second tone in display headlines (large text only, 28px and up) |
| `text-secondary` | `#5F6873` | Captions, helper text, inactive icons. 4.5:1 or better on white and on `canvas` |
| `text-disabled` | `#8B94A0` | Disabled and decorative text only. Never for information |
| `canvas` | `#EEF3F7` | App background |
| `sky-top` | `#C3D6E6` **(est.)** | Top of the background wash |
| `sky-mid` | `#DCE8F0` **(est.)** | Middle of the wash |
| `peach-glow` | `#F6EAE2` **(est.)** | Optional warm glow in a corner on large screens (seen in the desktop reference) |
| `surface` | `#FFFFFF` | Solid cards, inputs, sheets |
| `glass` | `rgba(255,255,255,0.66)` | Frosted cards over the wash |
| `glass-strong` | `rgba(255,255,255,0.82)` | Nav bar, sticky footers, sheets |
| `glass-border` | `rgba(255,255,255,0.70)` | 1px border on glass |
| `hairline` | `rgba(14,15,17,0.08)` | Dividers, outlines on white |
| `dotted` | `#B8C4CE` | Dotted dividers and timeline connectors |

### 2.2 Accents

| Family | 100 (tint) | 500 (graphics, icons) | 600/700 (text and fills that carry text) |
| --- | --- | --- | --- |
| Teal | `#DCEEF3` | `#3E9AB0` **(est.)** | `600 #2B7F94`, `700 #1F6F84` |
| Amber | `#FCEFD4` | `#F0A020` **(est.)** | `700 #8A5200` |
| Red | `#FCE4E1` | `#EF5B4B` | `600 #C5332B`, `700 #B3261E` |
| Slate | `#E8EDF2` | `#8296A8` | `700 #4B5B6A` |

### 2.3 Rules

- **Teal-500 is for icons, nodes and rings only.** White text on it is about 3.3:1, so any fill that carries text uses teal-600 (about 4.6:1).
- **Icons on amber-500 are `ink-950`**, not white (white on amber is about 2.2:1).
- Text on a tint uses the matching 700 shade (all pairs in the status table reach 4.5:1 or better).
- Background wash: `linear-gradient(180deg, sky-top 0%, sky-mid 55%, canvas 100%)`, applied to the top 320px of a screen, with `canvas` below. Do not use the wash behind dense lists.
- Colors never carry meaning alone. Every status chip has an icon and a label.
- Light mode only for the demo. Tokens are named by role so a dark theme can be added later.

---

## 3. Typography

**Family:** Inter Tight (Google Fonts, variable). It is the closest free match to the tight grotesque in the references. If you know the exact typeface from the CleanPro shot, swap it in here; nothing else changes. Fallback stack: `"Inter Tight", "Inter", system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`.

Use tabular figures for every price, weight and ID: `font-variant-numeric: tabular-nums`.

| Style | Size / line | Weight | Tracking | Use |
| --- | --- | --- | --- | --- |
| `display` | 40 / 42 | 600 | -0.035em | Onboarding and login hero only |
| `title-lg` | 28 / 32 | 600 | -0.025em | Screen titles, order ID on detail screens |
| `title-md` | 20 / 26 | 600 | -0.015em | Card titles, section headers |
| `body-lg` | 16 / 24 | 400 | 0 | Primary body text |
| `body-md` | 14 / 20 | 400 | 0.005em | Secondary text, list rows |
| `label` | 13 / 16 | 500 | 0.01em | Chips, field labels, tab labels |
| `caption` | 12 / 16 | 400 | 0.01em | Timestamps, timeline notes (minimum size) |
| `button` | 15 / 20 | 600 | -0.005em | All buttons |
| `price-xl` | 40 / 44 | 600 | -0.03em | Total on the price card |
| `price-md` | 16 / 24 | 500 | 0 | Breakdown rows |
| `input-xl` | 56 / 60 | 600 | -0.03em | Clerk weight input |

Rules:
- **Two-tone headline** (reference: dark, then muted slate, then dark) is allowed only on `display`, split at a natural phrase boundary, for example "Laundry handled, **from drop-off to pickup**" with the middle phrase in `slate-500`. Never accent a single word.
- Sentence case everywhere. No all-caps labels, no eyebrow labels above headings.
- Keep line length under about 36 characters on mobile for body text.
- Support dynamic type up to 200%. Layouts must wrap, not truncate, order IDs and totals.

---

## 4. Layout, shape, depth

### 4.1 Spacing and grid

- Base unit **4px**. Scale: 4, 8, 12, 16, 20, 24, 32, 40, 56.
- Design frame 390 x 844. Support 360 to 430 wide.
- Screen padding **20px**. Card padding **16px**. Gap between cards **12px**. Gap between sections **24px**.
- Touch targets are at least **48px** high. The clerk's Weigh and confirm screen uses **56px**.

### 4.2 Radius

| Token | px | Use |
| --- | --- | --- |
| `r-8` | 8 | Tags, thumbnails, small badges |
| `r-12` | 12 | **Buttons, inputs, icon buttons** (the reference buttons are softly rounded, not pills) |
| `r-16` | 16 | Nested cards, list rows |
| `r-20` | 20 | Main glass cards |
| `r-28` | 28 | Bottom sheets, top-level containers |
| `r-pill` | 999 | Chips, segmented controls, bottom nav |

### 4.3 Glass and shadow

- **Glass card:** `background: glass; backdrop-filter: blur(24px) saturate(1.3); border: 1px solid glass-border; box-shadow: 0 10px 30px rgba(28,39,51,0.08)`.
- **Floating (nav, toast, sheet):** `box-shadow: 0 16px 40px rgba(28,39,51,0.16)`.
- Nested rows inside a card use `hairline` outlines and no shadow.
- Use at most **two** blurred layers per screen. Fall back to `rgba(255,255,255,0.94)` when transparency is reduced or blur is unsupported, and on low-end devices.
- Text on glass sits over a pale surface. Never place text directly on a photo without a scrim.

---

## 5. Iconography and imagery

- Line icons, **1.5px stroke, rounded caps**, 20 or 24px (Lucide or Phosphor Regular). Filled icons only inside tags and timeline nodes.
- Service marks (used as corner tags and on service cards):

| Service | Icon | Tag color |
| --- | --- | --- |
| Express | bolt | amber-500 with `ink-950` icon |
| Normal | droplet | teal-600 with white icon |
| Bedding (per item) | stacked layers | slate-700 with white icon |

- **Photos:** the schema stores no order photos, so list and history cards use a tinted service tile (tint 100 with the service icon at 32px) instead of the folded-clothes thumbnails in the reference. Use soft-lit photography only on onboarding and empty states.
- Avatars are circles, 36 to 40px.

---

## 6. Components

### 6.1 Buttons

| Variant | Fill | Text | Border | Use |
| --- | --- | --- | --- | --- |
| **Primary** | `ink-950` | white | none | The one main action per screen |
| Secondary | `glass-strong` | `ink-950` | 1px `hairline` | Alternative actions |
| Text | transparent | `text-secondary` | none | "View all", low-emphasis links |
| Destructive | `surface` | `red-700` | 1px `red-100` | Cancel order, reset demo data |
| Destructive solid | `red-600` | white | none | Confirm step inside a dialog |

Specs (primary):
- Height **52px** (default), 44px medium, 36px small. Radius `r-12`. Horizontal padding 20px. Full width on mobile.
- Style `button`. White label on `ink-950`.
- **Trailing arrow-up-right icon** (18px, 8px gap) as in "Reserve Service" in the reference. Use it only on buttons that move forward to a new context: "Place order", "New order". Use no icon or a check icon on in-place actions such as "Confirm and record payment" or "Mark as ready".
- States: pressed `#26292E` with scale 0.98 (100ms); focus ring `0 0 0 2px canvas, 0 0 0 4px teal-500`; disabled fill `#CBD3DA` with `text-disabled`; loading replaces the icon with an 18px spinner and keeps the width.
- Sticky primary buttons sit on a `glass-strong` footer above the bottom nav, with safe-area padding.

**Icon button:** 44px frosted square, `r-12`, `glass-strong`, `glass-border`, 20px icon (back, bell, scan, search). The bell shows a 10px `red-500` dot at the top right when there are unread notifications.

### 6.2 Chips and tags

- **Info chip** (reference: "10 min", "5.4 km"): pill, 36px high, `surface`, 16px icon plus `label`. Use for "est. 6 h", "4.2 kg", "Walk-in".
- **Status chip:** pill, 28px high, 12px horizontal padding, 14px icon, `label`. Colors in section 8.
- **Corner tag:** 36px square in the top-right corner of a card, rounded only on the card's own corner and on the bottom-left, with a 16px service icon.

### 6.3 Inputs

- Height 52px, `surface`, `r-12`, 1px `hairline`, 16px text. Label above in `label`. Helper or error text below in `caption`.
- Focus: 2px `ink-950` border. Error: 2px `red-600` border plus an icon and message. Success: teal-600 check icon with message.
- **Search field** (clerk queue): frosted pill, 48px, search icon on the left, scan icon button on the right.
- **Voucher field:** input with a trailing "Apply" secondary button. After applying: "WELCOME10 is valid for Express. The discount is worked out when your laundry is weighed." The customer never sees a discount amount before weighing.
- **Weight input** (clerk): 56px numerals centered, unit "kg" or "items" beside it in `title-md`, minus and plus 56px steppers (0.1 kg steps, long-press to repeat), numeric keypad opens automatically.

### 6.4 Cards

- **Glass card:** `r-20`, padding 16, section 4.3 style. Default container.
- **Solid card:** `surface`, `r-16`, hairline, used for QR and for forms that need maximum contrast.
- **Order row** (lists): `surface`, `r-16`, 72px tall. Left service tile, middle order ID (`body-lg`, 600) with customer or service line (`caption`), right status chip and payment chip.
- **Service card** (customer): 2-column grid, `r-20`, service tile, name (`title-md`), "est. 6 h" (`caption`), and the unit price "2.00 / kg" (`price-md`). No total, ever.

### 6.5 Bottom navigation

Floating glass pill, 64px high, 20px from the sides and bottom, `r-pill`, `glass-strong`, floating shadow. The active item is an `ink-950` pill containing a white icon and label; inactive items show only a `text-secondary` icon.

| Role | Tabs |
| --- | --- |
| Customer | Home, Orders, Rewards, Alerts |
| Clerk | Queue, Scan, New order |
| Owner | Services, Vouchers, Summary, More (Settings, Demo tools) |

The **role switch** (demo only, FR-C1) is an info chip in the header showing the current role. Tapping it opens a sheet listing Customer A, Customer B, Clerk and Owner.

### 6.6 Status timeline (signature component)

Vertical list modeled on the Delivery Info card in the reference. Steps in order: **Ordered, Received, Processing, Ready, Picked up**.

| Part | Spec |
| --- | --- |
| Node | 20px circle |
| Done | `teal-500` fill, white check |
| Current | `amber-500` fill, `ink-950` icon |
| Upcoming | 1.5px dashed ring `dotted`, no fill |
| Connector | 1.5px dotted line in `dotted`, 12px from the node |
| Title | `body-md`, 600 (upcoming steps in `text-secondary`) |
| Note | `caption`, `text-secondary`, one line, for example "Your laundry is being washed" |
| Time | `caption`, right-aligned, "Today 8:45 PM", from `order_status_history.changed_at` |

- Cancelled and Expired replace the remaining steps with one terminal node in `red-500` and a note.
- On staff screens each row also shows who made the change (`changed_by`), for example "Moved by Clerk, 10:42" (PRD section 8, auditability).
- A compact version (dots only, no text) appears on the Home active-order card.

### 6.7 Price breakdown card (the receipt)

Modeled on the Checkout Summary card. Glass card, title "Price breakdown" with a receipt icon.

| Row | Content |
| --- | --- |
| Service | "Express, 4.2 kg x 2.00" left, "8.40" right |
| Discount | "WELCOME10" or "Loyalty reward" left, "-0.84" right in `teal-700` (true minus sign) |
| Divider | Dotted, 1.5px, `dotted` |
| Total | "Total" in `title-md`, amount in `price-xl` |
| Payment | Payment chip, method and time, for example "Paid, cash, 10:42" |

- **Before weighing:** one row only, "Price per kg" with "2.00", and the line "Your total is worked out when we weigh your laundry." No total row.
- One discount row at most (PRD section 6.4).
- Amounts: two decimals, no currency symbol until a currency is chosen (PRD section 17).

### 6.8 QR card

Solid white card, `r-20`, 176px QR code on 16px padding, the order ID below in `title-lg`, helper text "Show this to the clerk when you drop off." Collapses to a small "Show QR" secondary button once the status is past Ordered.

### 6.9 Loyalty stamp card

- Glass card with the progress numeral "7/10" in `price-xl` and the line "3 more orders until 50% off (up to 5 kg)".
- Grid of 10 slots (5 x 2), 44px circles. Earned: `ink-950` fill with a white droplet. Empty: dashed ring. The 10th slot shows a gift icon in `amber-500`.
- **Reward available:** an amber tag "Reward ready: 50% off up to 5 kg, never expires" and a pulse on the 10th slot once, on first view.
- Below the grid: stamp history list (order ID, date).
- A customer with no ledger rows shows 0/10, not an empty state (the `loyalty_progress` view returns no row for them).

### 6.10 Notification item

Row on a solid card, 72px. A 40px tinted tile with an event icon on the left, title (`body-md`, 600) and one-line body (`caption`) in the middle, time right, a 8px `red-500` dot for unread. Tapping opens the order.

| Event | Tile | Title | Body |
| --- | --- | --- | --- |
| Ready | teal-100, check | Your laundry is ready | LDR-0042 is ready for pickup. |
| Received | slate-100, scale | We've weighed your laundry | Total 7.56. See the breakdown. |
| Pickup reminder | amber-100, bell | Still waiting for you | LDR-0042 has been ready for 3 days. |
| Expired | red-100, clock | Order expired | LDR-0042 wasn't dropped off in time. |

The reminder day count and expiry text read from `app_settings`, not hard-coded.

### 6.11 Banners, toasts, dialogs

- **Banner:** `r-16`, tint 100 fill, 16px icon, `body-md` text in the 700 shade, 12px padding. Variants: info (slate), success (teal), warning (amber), error (red).
- **Toast:** `ink-950` fill, white text, `r-12`, appears 16px above the bottom nav, 3s. The toast repeats the verb of the button that triggered it ("Order placed", "Marked as ready").
- **Dialog / bottom sheet:** `surface`, `r-28` top corners, drag handle, primary and secondary buttons stacked.
- **Skeleton:** glass blocks with a slow 1.4s shimmer.

---

## 7. Screens

All 16 screens from PRD section 11. Priority labels match the PRD.

| Role | Screen | Priority | Layout summary |
| --- | --- | --- | --- |
| Everyone | Login | Must | Wash background, display headline (two-tone), email and password fields, primary "Sign in", demo accounts as four secondary chips |
| Customer | Home | Must | See wireframe below |
| Customer | New order | Must | Service radio cards, voucher field, sticky "Place order" |
| Customer | Order detail | Must | Header with order ID and status chip, QR card (while Ordered), timeline, price card, text-style destructive "Cancel order" while Ordered |
| Customer | Order history | Must | Order rows, grouped by month, tap for detail |
| Customer | Loyalty card | Must | Stamp card (6.9) plus history |
| Customer | Notifications | Must | Feed of items (6.10), unread first |
| Clerk | Order queue | Must | Search plus scan, segmented tabs "Drop-offs, In process, Ready" with counts, order rows |
| Clerk | Weigh and confirm | Must | See wireframe below |
| Clerk | Staff order detail | Must | Order summary, price card, payment record, next-step primary button, timeline with who and when |
| Clerk | New order for customer | Should | Customer search (name or phone), "Add walk-in" inline form (name, phone), service cards, sticky "Create order" |
| Owner | Services and prices | Must | Rows with name, unit, price, active switch. Edit in a sheet. Note: existing orders keep their saved price |
| Owner | Vouchers | Should | Rows with code, rule summary, chip (Active, Expired, Used up). Create and edit in a sheet |
| Owner | Demo tools | Should | Amber "Demo only" banner, "Advance time" stepper in days plus "Run jobs", destructive "Reset demo data" |
| Owner | Settings | Could | Number fields, with a warning banner that changing the loyalty threshold changes every customer's balance |
| Owner | Daily summary | Could | Three glass stat cards (orders, revenue, discounts) and a status breakdown |

### Customer Home

```
[avatar] Good morning              [Customer A v] [bell*]
         Alver
+---------------------------------------------------+
| LDR-0042                              [Ready]     |   glass card, active order
| Express, est. 6 h                                 |
| (o)--(o)--(o)--(o)- - -( )   compact timeline     |
+---------------------------------------------------+
+--------------------+  +---------------------------+
| 7/10  stamps       |  | Reward ready (if any)     |
+--------------------+  +---------------------------+
Services
+----------+ +----------+
| Express  | | Normal   |      2-col service cards, unit price only
| 2.00 /kg | | 1.00 /kg |
+----------+ +----------+
+----------+
| Bedding  |
| 5.00 /item|
+----------+
[ New order  ↗ ]                                      sticky primary
( Home )( Orders )( Rewards )( Alerts )               floating nav
```

If no order is active, the top card becomes a prompt: "Nothing in the wash. Start an order."

### Clerk: Weigh and confirm

```
[<]  LDR-0042                     [Walk-in]
     Customer A, Express (per kg)
+---------------------------------------------------+
|              4.2  kg            [ - ] [ + ]       |   56px numerals
+---------------------------------------------------+
Discount (choose one)
( ) None
(o) Voucher WELCOME10                       -0.84
( ) Loyalty reward   Not available: no reward yet
+---------------------------------------------------+
| 4.2 kg x 2.00                              8.40   |   live breakdown
| Voucher WELCOME10                         -0.84   |
| .................................................. |
| Total                                      7.56   |
+---------------------------------------------------+
Payment   [Cash] [Transfer] [QR] [E-wallet]   Pay later
[ Confirm and record payment ]                        sticky primary
```

- The three discount options are **one radio group**, so the one-discount rule is structurally enforced. A disabled option shows its reason in `caption` (for example "Per-kg services only", "No reward available").
- The breakdown recalculates on every keystroke. The server result (`confirm_order`) is authoritative; if it differs, show the server numbers.
- Choosing "Pay later" changes the primary button to "Confirm, unpaid" and shows an amber info banner.
- Item-count services swap the weight input for an item counter and hide the loyalty option.

### Clerk: Staff order detail

- The primary button is the **next legal step only** ("Mark as processing", then "Mark as ready", then "Hand over"). Other statuses are not offered.
- **Unpaid pickup:** tapping "Hand over" on an unpaid order opens a dialog: "This order is unpaid. Hand over anyway? No loyalty stamp will be added." Buttons: "Record payment" (primary) and "Hand over unpaid" (secondary).
- **Walk-in orders:** a "Walk-in" info chip, and after "Mark as ready" a banner: "Walk-in customers aren't notified. Tell them it's ready."

---

## 8. Status and payment mapping

Mirrors the `order_status` and `payment_status` enums in the schema.

| Status | Chip fill | Chip text | Icon | Notes |
| --- | --- | --- | --- | --- |
| `ordered` | transparent, 1px `slate-500` | `slate-700` | clock | |
| `received` | `teal-100` | `teal-700` | scale | Price is final |
| `processing` | `amber-100` | `amber-700` | washer | |
| `ready` | `teal-600` | white | check-circle | Strongest chip, because pickup is the call to action |
| `picked_up` | `slate-100` | `slate-700` | bag-check | Terminal |
| `cancelled` | `red-100` | `red-700` | x-circle | Terminal |
| `expired` | transparent, 1px dashed `red-600` | `red-700` | hourglass | Terminal |

| Payment | Chip | Icon |
| --- | --- | --- |
| `unpaid` | `amber-100` fill, `amber-700` text | wallet |
| `paid` | `teal-100` fill, `teal-700` text, shows method | check |

Payment chips appear beside the status chip on staff screens and in the price card. Customers see payment only inside the price card.

---

## 9. Motion

- Default `200ms cubic-bezier(0.2, 0, 0, 1)`. Sheets `280ms`. Press feedback `100ms`.
- Motion answers an action: a timeline node fills (240ms) when the status changes, the total counts into place when weighing is confirmed, the stamp lands (one 300ms bounce) on first view of a new stamp.
- No entrance animation on lists or sections. No looping animation except skeleton shimmer.
- Respect reduced motion: replace transitions with instant state changes and keep the shimmer static.

---

## 10. Content rules

- Sentence case. Plain verbs. Buttons say what happens: "Place order", "Confirm and record payment", "Mark as ready". The toast repeats the same verb.
- Order IDs appear exactly as stored (`LDR-0042`). Weights: "4.2 kg". Items: "3 items". Money: `8.40`, discounts with a true minus `-0.84`.
- Times: relative for today ("Today 8:45 PM"), then "8 Nov, 8:45 PM".
- Strings live in a localization file. The LaundryEase reference greets in Indonesian ("Selamat pagi"), so plan for English and Indonesian from the start.
- Errors state what happened and how to fix it. They do not apologize.

**Server errors from `confirm_order()` and their messages**

| Database message | Show the clerk |
| --- | --- |
| Weight required | Enter the weight to continue. |
| Item count required | Enter the number of items to continue. |
| Voucher invalid or expired | This voucher isn't valid today. |
| Below voucher minimum spend | The subtotal is below this voucher's minimum spend (3.00). |
| Voucher usage limit reached | This voucher has been fully used. |
| Customer already used this voucher | This customer has already used this voucher. |
| Loyalty reward applies to per-kg services only | Loyalty rewards work on per-kg services only. |
| No loyalty reward available | No reward available yet. Choose no discount or a voucher. |
| Order not found or already received | Order not found, or it has already been weighed. |
| Staff only | Only staff can do this. |

Show the message in an error banner above the sticky button and keep every entered value.

---

## 11. Accessibility

- Text contrast of at least 4.5:1 (3:1 for 28px and larger). The palette notes in section 2 already account for this.
- Visible focus ring on every interactive element (section 6.1).
- 48px minimum touch targets, 56px on the weigh screen.
- Every chip, node and badge pairs color with an icon and label.
- Screen readers: the timeline is an ordered list with "Step 2 of 5, Received, done"; the stamp card reads "7 of 10 stamps".
- QR codes always have the order ID as visible text for typing instead.

---

## 12. Tokens (copy into the theme)

Written as CSS custom properties for readability. Map them one-to-one to Flutter `ThemeData` or a React Native theme object.

```css
:root {
  /* color */
  --ink-950: #0E0F11;  --ink-800: #1C2733;  --slate-500: #5E7384;
  --text-secondary: #5F6873;  --text-disabled: #8B94A0;
  --canvas: #EEF3F7;  --sky-top: #C3D6E6;  --sky-mid: #DCE8F0;  --peach-glow: #F6EAE2;
  --surface: #FFFFFF;
  --glass: rgba(255,255,255,0.66);  --glass-strong: rgba(255,255,255,0.82);
  --glass-border: rgba(255,255,255,0.70);  --hairline: rgba(14,15,17,0.08);  --dotted: #B8C4CE;

  --teal-100: #DCEEF3;  --teal-500: #3E9AB0;  --teal-600: #2B7F94;  --teal-700: #1F6F84;
  --amber-100: #FCEFD4; --amber-500: #F0A020; --amber-700: #8A5200;
  --red-100: #FCE4E1;   --red-500: #EF5B4B;   --red-600: #C5332B;   --red-700: #B3261E;
  --slate-100: #E8EDF2; --slate-400: #8296A8; --slate-700: #4B5B6A;

  /* shape */
  --r-8: 8px; --r-12: 12px; --r-16: 16px; --r-20: 20px; --r-28: 28px; --r-pill: 999px;

  /* spacing */
  --s-1: 4px; --s-2: 8px; --s-3: 12px; --s-4: 16px; --s-5: 20px; --s-6: 24px; --s-8: 32px; --s-10: 40px; --s-14: 56px;

  /* depth */
  --blur-glass: blur(24px) saturate(1.3);
  --shadow-card: 0 10px 30px rgba(28,39,51,0.08);
  --shadow-float: 0 16px 40px rgba(28,39,51,0.16);

  /* motion */
  --ease: cubic-bezier(0.2, 0, 0, 1);
  --dur-fast: 100ms; --dur: 200ms; --dur-sheet: 280ms;

  /* type */
  --font: "Inter Tight", "Inter", system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
}
```

---

## 13. Do and don't

**Do**
- Keep one black primary button per screen.
- Reuse the timeline, the price card and the status chip everywhere an order appears.
- Show the unit price only before weighing.
- Let the radio group enforce one discount.
- Put the clerk's most-used action in thumb reach, at the bottom.

**Don't**
- Don't use purple, yellow or any LaundryEase colors.
- Don't add a map, courier, delivery or card-payment UI. They are out of scope.
- Don't use pill-shaped buttons. Pills are for chips and the nav.
- Don't use red for savings or teal for errors.
- Don't stack more than two blurred layers on one screen.
- Don't show a discount amount or total to the customer before the clerk confirms.
