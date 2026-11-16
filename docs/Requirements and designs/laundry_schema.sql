-- =====================================================================
-- Laundry app: demo/portfolio schema (PostgreSQL, written for Supabase)
--
-- Locked rules
--   * Pricing: per kg or per item. Customers only see the unit price
--     until the clerk weighs the laundry.
--   * Payment: at drop-off, right after weighing (clerk records method).
--   * One discount per order: voucher OR loyalty reward, never both.
--   * Loyalty: every 10 completed orders -> next order 50% off, max 5 kg,
--     no expiry. An order earns a stamp only if weight >= 1 kg.
--   * Walk-in customers (no app): the clerk creates the order at the counter
--     for an existing customer or a new walk-in profile (name + phone).
--   * One reward can be used on only one order: confirm_order() locks the
--     customer first, so two simultaneous confirmations can't share a reward.
--   Change the numbers in app_settings, not in code.
-- =====================================================================

create type user_role      as enum ('customer', 'clerk', 'owner');
create type pricing_unit   as enum ('per_kg', 'per_item');
create type order_status   as enum ('ordered', 'received', 'processing', 'ready',
                                    'picked_up', 'cancelled', 'expired');
create type payment_status as enum ('unpaid', 'paid');
create type payment_method as enum ('cash', 'transfer', 'qr', 'ewallet');
create type discount_type  as enum ('none', 'voucher', 'loyalty');
create type voucher_kind   as enum ('percent', 'fixed');
create type loyalty_event  as enum ('stamp', 'redeem');

-- ---------- Users ----------------------------------------------------
-- App users: id = auth.users.id (set by your signup trigger or client).
-- Walk-in customers: generated id, is_walk_in = true, added by a clerk. They
-- earn stamps and use vouchers but get no notifications. A walk-in who installs
-- the app later gets a separate account; merging the two is a later-phase item.
create table profiles (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  phone      text,
  role       user_role not null default 'customer',
  push_token text,                       -- for push notifications
  is_walk_in boolean not null default false,
  created_by uuid references profiles,   -- clerk who added a walk-in
  created_at timestamptz not null default now()
);
create index on profiles (phone);

create or replace function app_role() returns user_role
language sql stable security definer set search_path = public as $$
  select role from profiles where id = auth.uid()
$$;

-- ---------- Settings, services, vouchers -----------------------------
create table app_settings (
  id                       int primary key default 1 check (id = 1),  -- single row
  loyalty_orders_required  int     not null default 10,
  loyalty_discount_percent int     not null default 50,
  loyalty_max_kg           numeric not null default 5,
  loyalty_min_kg           numeric not null default 1,
  order_expiry_hours       int     not null default 48,  -- 'ordered' but never dropped off
  pickup_reminder_days     int     not null default 3,   -- 'ready' but not collected
  unclaimed_policy_days    int     not null default 30   -- shown to customers as the policy
);

create table services (
  id        uuid primary key default gen_random_uuid(),
  name      text not null unique,
  unit      pricing_unit not null,
  price     numeric(12,2) not null check (price >= 0),
  est_hours int not null,
  active    boolean not null default true
);

create table vouchers (
  id                 uuid primary key default gen_random_uuid(),
  code               text not null unique check (code = upper(code)),
  kind               voucher_kind not null,
  value              numeric(12,2) not null check (value > 0),  -- % or fixed amount
  max_discount       numeric(12,2),                             -- cap for percent vouchers
  min_spend          numeric(12,2) not null default 0,
  valid_from         timestamptz not null default now(),
  valid_to           timestamptz not null,
  usage_limit        int,                                       -- null = unlimited
  per_customer_limit int default 1,
  service_ids        uuid[],                                    -- null = all services
  active             boolean not null default true
);

-- ---------- Orders ---------------------------------------------------
create sequence order_seq;

create table orders (
  id              uuid primary key default gen_random_uuid(),
  order_code      text not null unique
                  default 'LDR-' || lpad(nextval('order_seq')::text, 4, '0'),
  customer_id     uuid not null references profiles,
  service_id      uuid not null references services,
  status          order_status not null default 'ordered',
  voucher_code    text,                     -- entered by customer when ordering
  -- filled in when the clerk weighs (confirm_order)
  weight_kg       numeric(6,2),
  item_count      int,
  unit_price      numeric(12,2),            -- price snapshot at weighing
  subtotal        numeric(12,2),
  discount_type   discount_type not null default 'none',
  discount_amount numeric(12,2) not null default 0,
  total           numeric(12,2),
  voucher_id      uuid references vouchers,
  -- payment is tracked separately from order status
  payment_status  payment_status not null default 'unpaid',
  payment_method  payment_method,
  paid_at         timestamptz,
  received_by     uuid references profiles,
  created_at      timestamptz not null default now(),
  check (voucher_id is null or discount_type = 'voucher')   -- one discount per order
);
create index on orders (customer_id);
create index on orders (status);

-- Every status change is logged here; use it for ready/picked-up timestamps
create table order_status_history (
  id         bigint generated always as identity primary key,
  order_id   uuid not null references orders on delete cascade,
  status     order_status not null,
  changed_by uuid references profiles,
  changed_at timestamptz not null default now()
);

create table voucher_redemptions (
  id          bigint generated always as identity primary key,
  voucher_id  uuid not null references vouchers,
  customer_id uuid not null references profiles,
  order_id    uuid not null unique references orders on delete cascade,
  amount      numeric(12,2) not null,
  created_at  timestamptz not null default now()
);

-- Loyalty ledger: one 'stamp' per completed order, one 'redeem' per reward used.
-- Rewards available = stamps / N - redeems. No expiry.
create table loyalty_ledger (
  id          bigint generated always as identity primary key,
  customer_id uuid not null references profiles,
  event       loyalty_event not null,
  order_id    uuid not null references orders on delete cascade,
  created_at  timestamptz not null default now(),
  unique (order_id, event)
);

-- Stamp-card view for the customer app ("7/10" + reward badge)
create view loyalty_progress with (security_invoker = true) as
select l.customer_id,
       count(*) filter (where l.event = 'stamp')                         as stamps,
       count(*) filter (where l.event = 'stamp') % c.loyalty_orders_required as progress,
       count(*) filter (where l.event = 'stamp') / c.loyalty_orders_required
         - count(*) filter (where l.event = 'redeem')                    as rewards_available
from loyalty_ledger l, app_settings c
where c.id = 1
group by l.customer_id, c.loyalty_orders_required;

-- ---------- Triggers -------------------------------------------------
-- Logs status history, awards loyalty stamps, and releases discounts
-- when an order is cancelled or expires.
create or replace function on_order_status_change() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into order_status_history (order_id, status, changed_by)
  values (new.id, new.status, auth.uid());

  if new.status = 'picked_up' and new.payment_status = 'paid'
     and (new.weight_kg is null
          or new.weight_kg >= (select loyalty_min_kg from app_settings)) then
    insert into loyalty_ledger (customer_id, event, order_id)
    values (new.customer_id, 'stamp', new.id)
    on conflict do nothing;
  elsif new.status in ('cancelled', 'expired') then
    delete from loyalty_ledger     where order_id = new.id and event = 'redeem';
    delete from voucher_redemptions where order_id = new.id;
  end if;
  return new;
end $$;

create trigger trg_order_insert after insert on orders
  for each row execute function on_order_status_change();

create trigger trg_order_status after update of status on orders
  for each row when (old.status is distinct from new.status)
  execute function on_order_status_change();

-- ---------- Voucher check at order time (customer side) --------------
create or replace function validate_voucher(p_code text, p_service_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from vouchers
    where code = upper(p_code) and active
      and now() between valid_from and valid_to
      and (service_ids is null or p_service_id = any(service_ids)));
$$;

-- ---------- Walk-in customers (clerk adds them at the counter) -------
-- Returns the existing profile when the phone number is already known.
create or replace function add_walk_in_customer(p_name text, p_phone text default null)
returns profiles
language plpgsql security definer set search_path = public as $$
declare
  v_profile profiles;
begin
  if app_role() is null or app_role() = 'customer' then
    raise exception 'Staff only';
  end if;

  if p_phone is not null then
    select * into v_profile from profiles where phone = p_phone limit 1;
    if found then return v_profile; end if;
  end if;

  insert into profiles (name, phone, role, is_walk_in, created_by)
  values (p_name, p_phone, 'customer', true, auth.uid())
  returning * into v_profile;
  return v_profile;
end $$;

-- ---------- Clerk weighing screen in one call ------------------------
-- Validates the order, calculates the price, applies at most ONE discount,
-- and optionally records payment (pay at drop-off).
create or replace function confirm_order(
  p_order_code   text,
  p_weight_kg    numeric       default null,  -- per-kg services
  p_item_count   int           default null,  -- per-item services
  p_discount     discount_type default 'none',
  p_voucher_code text          default null,  -- falls back to the customer's code
  p_method       payment_method default null  -- null = not paid yet
) returns orders
language plpgsql security definer set search_path = public as $$
declare
  v_order    orders;
  v_service  services;
  v_cfg      app_settings;
  v_voucher  vouchers;
  v_subtotal numeric;
  v_disc     numeric := 0;
  v_rewards  int;
begin
  if app_role() is null or app_role() = 'customer' then
    raise exception 'Staff only';
  end if;

  select * into v_order from orders
   where order_code = upper(p_order_code) and status = 'ordered' for update;
  if not found then raise exception 'Order not found or already received'; end if;

  -- Serialise confirmations per customer: a reward (or a per-customer voucher
  -- limit) is checked and used up before the next confirmation for that
  -- customer can start, so two orders can't both use the same reward.
  perform pg_advisory_xact_lock(hashtextextended(v_order.customer_id::text, 0));

  select * into v_service from services where id = v_order.service_id;
  select * into v_cfg from app_settings;

  -- 1. subtotal
  if v_service.unit = 'per_kg' then
    if coalesce(p_weight_kg, 0) <= 0 then raise exception 'Weight required'; end if;
    v_subtotal := round(p_weight_kg * v_service.price, 2);
  else
    if coalesce(p_item_count, 0) <= 0 then raise exception 'Item count required'; end if;
    v_subtotal := round(p_item_count * v_service.price, 2);
  end if;

  -- 2. one discount: voucher OR loyalty reward
  if p_discount = 'voucher' then
    select * into v_voucher from vouchers
     where code = upper(coalesce(p_voucher_code, v_order.voucher_code))
       and active and now() between valid_from and valid_to
       and (service_ids is null or v_order.service_id = any(service_ids));
    if not found then raise exception 'Voucher invalid or expired'; end if;
    if v_subtotal < v_voucher.min_spend then
      raise exception 'Below voucher minimum spend';
    end if;
    if v_voucher.usage_limit is not null and
       (select count(*) from voucher_redemptions
         where voucher_id = v_voucher.id) >= v_voucher.usage_limit then
      raise exception 'Voucher usage limit reached';
    end if;
    if v_voucher.per_customer_limit is not null and
       (select count(*) from voucher_redemptions
         where voucher_id = v_voucher.id
           and customer_id = v_order.customer_id) >= v_voucher.per_customer_limit then
      raise exception 'Customer already used this voucher';
    end if;
    v_disc := case v_voucher.kind
                when 'percent' then v_subtotal * v_voucher.value / 100
                else v_voucher.value end;
    v_disc := least(v_disc, v_voucher.max_discount, v_subtotal);  -- least() skips NULL cap

  elsif p_discount = 'loyalty' then
    -- demo assumption: the kg cap means rewards apply to per-kg services only
    if v_service.unit <> 'per_kg' then
      raise exception 'Loyalty reward applies to per-kg services only';
    end if;
    select count(*) filter (where event = 'stamp') / v_cfg.loyalty_orders_required
         - count(*) filter (where event = 'redeem')
      into v_rewards
      from loyalty_ledger where customer_id = v_order.customer_id;
    if v_rewards < 1 then raise exception 'No loyalty reward available'; end if;
    v_disc := least(p_weight_kg, v_cfg.loyalty_max_kg)
              * v_service.price * v_cfg.loyalty_discount_percent / 100;
  end if;
  v_disc := round(v_disc, 2);

  -- 3. save breakdown + payment
  update orders set
    status          = 'received',
    weight_kg       = p_weight_kg,
    item_count      = p_item_count,
    unit_price      = v_service.price,
    subtotal        = v_subtotal,
    discount_type   = p_discount,
    discount_amount = v_disc,
    total           = v_subtotal - v_disc,
    voucher_id      = v_voucher.id,
    payment_status  = (case when p_method is null then 'unpaid' else 'paid' end)::payment_status,
    payment_method  = p_method,
    paid_at         = case when p_method is not null then now() end,
    received_by     = auth.uid()
  where id = v_order.id
  returning * into v_order;

  -- 4. record which discount was used
  if p_discount = 'voucher' then
    insert into voucher_redemptions (voucher_id, customer_id, order_id, amount)
    values (v_voucher.id, v_order.customer_id, v_order.id, v_disc);
  elsif p_discount = 'loyalty' then
    insert into loyalty_ledger (customer_id, event, order_id)
    values (v_order.customer_id, 'redeem', v_order.id);
  end if;

  return v_order;
end $$;

-- ---------- Row level security ---------------------------------------
-- Tables with RLS on and no policy are closed by default.
alter table profiles            enable row level security;
alter table app_settings        enable row level security;
alter table services            enable row level security;
alter table vouchers            enable row level security;
alter table orders              enable row level security;
alter table order_status_history enable row level security;
alter table voucher_redemptions enable row level security;
alter table loyalty_ledger      enable row level security;

create policy profiles_read  on profiles     for select
  using (id = auth.uid() or app_role() in ('clerk', 'owner'));
create policy settings_read  on app_settings for select using (true);
create policy settings_owner on app_settings for update using (app_role() = 'owner');
create policy services_read  on services     for select using (true);
create policy services_owner on services     for all    using (app_role() = 'owner');
create policy vouchers_owner on vouchers     for all    using (app_role() = 'owner');

create policy orders_read   on orders for select
  using (customer_id = auth.uid() or app_role() in ('clerk', 'owner'));
create policy orders_create on orders for insert
  with check (customer_id = auth.uid() and status = 'ordered' and payment_status = 'unpaid'
              and discount_type = 'none' and weight_kg is null);
create policy orders_staff_create on orders for insert    -- clerk creates an order for a walk-in
  with check (app_role() in ('clerk', 'owner') and status = 'ordered'
              and payment_status = 'unpaid' and discount_type = 'none'
              and weight_kg is null);
create policy orders_cancel on orders for update          -- customer can cancel before drop-off
  using (customer_id = auth.uid() and status = 'ordered')
  with check (customer_id = auth.uid() and status = 'cancelled');
create policy orders_staff  on orders for update
  using (app_role() in ('clerk', 'owner'));

create policy history_read on order_status_history for select
  using (app_role() in ('clerk', 'owner')
         or exists (select 1 from orders o
                    where o.id = order_id and o.customer_id = auth.uid()));
create policy ledger_read on loyalty_ledger for select
  using (customer_id = auth.uid() or app_role() in ('clerk', 'owner'));
create policy redemptions_staff on voucher_redemptions for select
  using (app_role() in ('clerk', 'owner'));

-- ---------- Seed data (placeholder prices) ---------------------------
insert into app_settings (id) values (1);

insert into services (name, unit, price, est_hours) values
  ('Express',            'per_kg',   2.00,  6),
  ('Normal',             'per_kg',   1.00, 48),
  ('Bedding (per item)', 'per_item', 5.00, 72);

insert into vouchers (code, kind, value, max_discount, min_spend, valid_to, per_customer_limit)
values ('WELCOME10', 'percent', 10, 5.00, 3.00, now() + interval '90 days', 1);

-- ---------- Scheduled jobs (pg_cron / Supabase cron) -----------------
-- Expire orders never dropped off:
--   update orders set status = 'expired'
--   where status = 'ordered'
--     and created_at < now() - make_interval(hours => (select order_expiry_hours from app_settings));
-- Pickup reminder: find orders in 'ready' longer than pickup_reminder_days
-- (use order_status_history.changed_at) and send a push notification.
