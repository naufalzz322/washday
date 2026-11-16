(() => {
  const data = window.WashdayDashboardData;
  const role = document.body.dataset.dashboard;
  if (!data || !role || !data[role]) return;
  const fixture = data[role];

  function renderMetrics(container) {
    if (!container) return;
    container.replaceChildren(...fixture.metrics.map((metric) => {
      const card = document.createElement('article');
      card.className = 'dash-kpi';
      const label = document.createElement('span');
      label.className = 'dash-kpi-label';
      label.textContent = metric.label;
      const value = document.createElement('strong');
      value.textContent = metric.value;
      const note = document.createElement('small');
      note.textContent = metric.note;
      card.append(label, value, note);
      return card;
    }));
  }

  function renderQueue(container) {
    if (!container || !fixture.queue) return;
    container.replaceChildren(...fixture.queue.map((item) => {
      const row = document.createElement('div');
      row.className = 'dash-bar-row';
      const label = document.createElement('span');
      label.className = 'dash-bar-label';
      const strong = document.createElement('strong');
      strong.textContent = item.label;
      const note = document.createElement('small');
      note.textContent = `${item.count} orders`;
      label.append(strong, note);
      const track = document.createElement('span');
      track.className = 'dash-bar-track';
      const fill = document.createElement('i');
      fill.className = `is-${item.tone}`;
      fill.style.width = `${Math.round((item.count / item.max) * 100)}%`;
      track.append(fill);
      const value = document.createElement('span');
      value.className = 'dash-bar-value';
      value.textContent = String(item.count);
      row.append(label, track, value);
      return row;
    }));
  }

  function renderWeek(container) {
    if (!container || !fixture.week) return;
    const summary = fixture.week.map((item) => `${item.day} ${item.value}`).join(', ');
    container.setAttribute('role', 'img');
    container.setAttribute('aria-label', `Sales by day: ${summary}.`);
    container.replaceChildren(...fixture.week.map((item) => {
      const column = document.createElement('div');
      column.className = 'dash-week-col';
      const value = document.createElement('span');
      value.className = 'dash-week-value';
      value.textContent = String(item.value);
      const track = document.createElement('span');
      track.className = 'dash-week-track';
      const fill = document.createElement('i');
      fill.style.height = `${Math.round((item.value / fixture.weekMax) * 100)}%`;
      track.append(fill);
      const day = document.createElement('span');
      day.className = 'dash-week-day';
      day.textContent = item.day;
      column.append(value, track, day);
      return column;
    }));
  }

  function renderMix(container) {
    if (!container || !fixture.mix) return;
    container.replaceChildren(...fixture.mix.map((item) => {
      const row = document.createElement('div');
      row.className = 'dash-mix-row';
      const head = document.createElement('span');
      head.className = 'dash-mix-head';
      const label = document.createElement('strong');
      label.textContent = item.label;
      const value = document.createElement('span');
      value.textContent = `${item.value}%`;
      head.append(label, value);
      const track = document.createElement('span');
      track.className = 'dash-mix-track';
      const fill = document.createElement('i');
      fill.className = `is-${item.tone}`;
      fill.style.width = `${item.value}%`;
      track.append(fill);
      row.append(head, track);
      return row;
    }));
  }

  function renderOrders(container) {
    if (!container || !fixture.recentOrders) return;
    container.replaceChildren(...fixture.recentOrders.map((order) => {
      const link = document.createElement('a');
      link.className = 'dash-order-row';
      link.href = fixture.orderHref;
      const main = document.createElement('span');
      main.className = 'dash-order-main';
      const id = document.createElement('strong');
      id.textContent = order.id;
      const customer = document.createElement('small');
      customer.textContent = `${order.customer} · ${order.service}`;
      main.append(id, customer);
      const status = document.createElement('span');
      status.className = `rp-status rp-status-${order.tone}`;
      status.textContent = order.status;
      const chevron = document.createElement('span');
      chevron.className = 'rp-chevron';
      chevron.setAttribute('aria-hidden', 'true');
      chevron.textContent = '›';
      link.append(main, status, chevron);
      return link;
    }));
  }

  renderMetrics(document.querySelector('[data-dashboard-metrics]'));
  renderQueue(document.querySelector('[data-dashboard-queue]'));
  renderWeek(document.querySelector('[data-dashboard-week]'));
  renderMix(document.querySelector('[data-dashboard-mix]'));
  renderOrders(document.querySelector('[data-dashboard-orders]'));
})();
