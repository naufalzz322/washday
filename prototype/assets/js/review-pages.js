(() => {
  const money = (n) => (Math.round((n + Number.EPSILON) * 100) / 100).toFixed(2);
  const weight = document.querySelector('#weight-input');
  const discountRadios = [...document.querySelectorAll('input[name="discount"]')];
  const feedback = document.querySelector('[data-feedback]');

  function calculate() {
    if (!weight) return;
    const normalizedWeight = weight.value.trim().replace(',', '.');
    const kg = normalizedWeight === '' ? NaN : Number(normalizedWeight);
    if (!Number.isFinite(kg) || kg < 0) {
      if (feedback) feedback.textContent = 'Enter a valid weight in kg.';
      return;
    }
    const subtotal = kg * 2.00;
    const choice = discountRadios.find((radio) => radio.checked)?.value;
    const discount = choice === 'voucher' && subtotal >= 3 ? Math.min(subtotal * 0.10, 5.00) : 0;
    document.querySelector('#calc-subtotal').textContent = money(subtotal);
    document.querySelector('#calc-discount').textContent = `−${money(discount)}`;
    document.querySelector('#calc-total').textContent = money(Math.max(0, subtotal - discount));
    if (feedback) feedback.textContent = subtotal < 3 && choice === 'voucher' ? 'Minimum spend is 3.00; WELCOME10 has not been applied.' : '';
  }
  if (weight) {
    weight.addEventListener('input', calculate);
    discountRadios.forEach((radio) => radio.addEventListener('change', calculate));
  }
  document.querySelectorAll('[data-action="weigh-preview"]').forEach((button) => button.addEventListener('click', () => {
    calculate();
    if (feedback && feedback.textContent === '') feedback.textContent = 'Total updated.';
  }));

  const walkInInputs = ['#walkin-name', '#walkin-phone'].map((selector) => document.querySelector(selector)).filter(Boolean);
  document.querySelectorAll('input[name="counter-customer"]').forEach((radio) => radio.addEventListener('change', () => {
    const isWalkIn = document.querySelector('input[name="counter-customer"]:checked')?.value === 'Walk-in';
    walkInInputs.forEach((input) => { input.disabled = !isWalkIn; });
  }));

  const orderRows = [...document.querySelectorAll('[data-order-row]')];
  const orderEmpty = document.querySelector('[data-order-empty]');
  const orderSearch = document.querySelector('[data-order-search]');
  let activeFilter = 'all';

  function applyOrderVisibility() {
    const query = orderSearch?.value.trim().toLowerCase() ?? '';
    let visible = 0;
    orderRows.forEach((row) => {
      const matchesFilter = activeFilter === 'all' || row.dataset.status === activeFilter;
      const matchesQuery = !query || row.textContent.toLowerCase().includes(query);
      row.hidden = !(matchesFilter && matchesQuery);
      if (!row.hidden) visible += 1;
    });
    if (orderEmpty) orderEmpty.hidden = visible > 0;
  }

  document.querySelectorAll('[data-order-filters] [data-filter]').forEach((button) => button.addEventListener('click', () => {
    document.querySelectorAll('[data-order-filters] [data-filter]').forEach((item) => {
      item.classList.toggle('is-selected', item === button);
    });
    activeFilter = button.dataset.filter;
    applyOrderVisibility();
  }));

  document.querySelectorAll('[data-action="queue-search"]').forEach((button) => button.addEventListener('click', applyOrderVisibility));
  orderSearch?.addEventListener('input', applyOrderVisibility);
  orderSearch?.addEventListener('keydown', (event) => {
    if (event.key === 'Enter') {
      event.preventDefault();
      applyOrderVisibility();
    }
  });
  if (orderRows.length) applyOrderVisibility();

  document.querySelectorAll('[data-action="pickup"]').forEach((button) => button.addEventListener('click', () => {
    const status = document.querySelector('[data-payment-status]')?.textContent.trim();
    if (status === 'Unpaid') {
      if (feedback) feedback.textContent = 'This order is unpaid. Confirm payment before pickup.';
      return;
    }
    const orderStatus = document.querySelector('[data-order-status]');
    if (orderStatus) orderStatus.textContent = 'Picked up';
    if (feedback) feedback.textContent = 'Order marked as picked up.';
  }));
  document.querySelectorAll('[data-payment]').forEach((button) => button.addEventListener('click', () => {
    const target = document.querySelector('[data-payment-status]');
    if (target) target.textContent = `Paid · ${button.dataset.payment}`;
    if (feedback) feedback.textContent = 'Payment recorded.';
  }));
  document.querySelectorAll('[data-action="counter-preview"]').forEach((button) => button.addEventListener('click', () => {
    if (feedback) feedback.textContent = 'Order created.';
  }));
  document.querySelectorAll('[data-action="save-settings"]').forEach((button) => button.addEventListener('click', () => {
    if (feedback) feedback.textContent = 'Settings saved.';
  }));

  function updateCatalogSummary() {
    const api = window.WashdayCatalog;
    if (!api) return;
    const summary = document.querySelector('[data-catalog-summary]');
    const stateLabel = document.querySelector('[data-catalog-state]');
    if (!summary) return;
    const state = api.getCatalogState();
    summary.textContent = `${state.categories} categories · ${state.services} services · ${state.auditEvents} changes`;
    if (stateLabel) stateLabel.textContent = state.customised ? 'Updated recently' : 'Default catalog';
  }

  document.querySelectorAll('[data-action="reset-catalog"]').forEach((button) => button.addEventListener('click', () => {
    const api = window.WashdayCatalog;
    if (!api) {
      if (feedback) feedback.textContent = 'The catalog could not be loaded.';
      return;
    }
    api.resetAll();
    updateCatalogSummary();
    if (feedback) feedback.textContent = 'Catalog restored to the default categories and services. Recent changes were cleared.';
  }));

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', updateCatalogSummary);
  } else {
    updateCatalogSummary();
  }
})();
