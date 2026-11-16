(() => {
  const feed = document.querySelector('[data-activity-feed]');
  if (!feed) return;

  const api = window.WashdayCatalog;
  const filters = [...document.querySelectorAll('[data-activity-filter]')];
  const empty = document.querySelector('[data-activity-empty]');
  const sessionEmpty = document.querySelector('#session-empty');
  const sessionCount = document.querySelector('#session-count');

  const titles = {
    'category.created': 'Category added',
    'category.updated': 'Category updated',
    'service.created': 'Service added',
    'service.updated': 'Service updated'
  };

  function timeLabel(iso) {
    const date = new Date(iso);
    if (Number.isNaN(date.getTime())) return 'Today';
    return `Today · ${date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;
  }

  function sessionEvent(event) {
    const article = document.createElement('article');
    article.className = 'audit-event';
    article.dataset.eventType = 'catalog';

    const node = document.createElement('span');
    node.className = 'audit-node';
    node.setAttribute('aria-hidden', 'true');
    article.append(node);

    const main = document.createElement('div');
    main.className = 'audit-main';

    const head = document.createElement('div');
    head.className = 'audit-head';
    const actor = document.createElement('span');
    actor.className = 'audit-actor';
    actor.textContent = event.actor;
    const time = document.createElement('span');
    time.className = 'audit-time';
    time.textContent = timeLabel(event.at);
    const badge = document.createElement('span');
    badge.className = 'audit-badge is-recent';
    badge.textContent = 'Catalog';
    head.append(actor, time, badge);

    const heading = document.createElement('h3');
    heading.textContent = `${titles[event.action] ?? 'Catalog updated'} · ${event.entityName}`;

    const changes = document.createElement('dl');
    changes.className = 'audit-changes';
    event.changes.forEach((item) => {
      const row = document.createElement('div');
      const label = document.createElement('dt');
      label.textContent = item.label;
      const value = document.createElement('dd');
      const oldValue = document.createElement('span');
      oldValue.className = 'audit-old';
      oldValue.textContent = item.from;
      const arrow = document.createElement('span');
      arrow.className = 'audit-arrow';
      arrow.setAttribute('aria-hidden', 'true');
      arrow.textContent = '→';
      const newValue = document.createElement('span');
      newValue.className = 'audit-new';
      newValue.textContent = item.to;
      value.append(oldValue, arrow, newValue);
      row.append(label, value);
      changes.append(row);
    });

    main.append(head, heading, changes);
    article.append(main);
    return article;
  }

  function applyFilter() {
    const selected = filters.find((filter) => filter.classList.contains('is-selected'))?.dataset.activityFilter ?? 'all';
    const events = [...feed.querySelectorAll('.audit-event')];
    let visible = 0;
    events.forEach((event) => {
      const show = selected === 'all' || event.dataset.eventType === selected;
      event.hidden = !show;
      if (show) visible += 1;
    });
    if (empty) empty.hidden = visible > 0;
  }

  filters.forEach((filter) => filter.addEventListener('click', () => {
    filters.forEach((item) => item.classList.toggle('is-selected', item === filter));
    applyFilter();
  }));

  if (api) {
    const events = api.getSessionAuditEvents();
    if (sessionCount) {
      sessionCount.textContent = events.length === 1 ? '1 recent change' : `${events.length} recent changes`;
    }
    if (sessionEmpty) sessionEmpty.hidden = events.length > 0;
    if (events.length) {
      const fragment = document.createDocumentFragment();
      events.forEach((event) => fragment.append(sessionEvent(event)));
      feed.prepend(fragment);
    }
  }

  applyFilter();
})();
