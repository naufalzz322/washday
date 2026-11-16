((root, factory) => {
  const api = factory();
  if (typeof module === 'object' && module.exports) module.exports = api;
  if (root) root.WashdayDashboardData = api;
})(typeof globalThis === 'undefined' ? this : globalThis, () => {
  const recentOrders = Object.freeze([
    Object.freeze({ id: 'LDR-0042', customer: 'Customer A', service: 'Express', status: 'Ready', tone: 'warning' }),
    Object.freeze({ id: 'LDR-0041', customer: 'Customer B', service: 'Wash & fold', status: 'Processing', tone: 'neutral' }),
    Object.freeze({ id: 'LDR-0040', customer: 'Walk-in', service: 'Bedding', status: 'Ready', tone: 'warning' })
  ]);

  const data = Object.freeze({
    clerk: Object.freeze({
      metrics: Object.freeze([
        Object.freeze({ label: 'Orders today', value: '12', note: '6 still open' }),
        Object.freeze({ label: 'Ready for pickup', value: '4', note: '2 since yesterday' }),
        Object.freeze({ label: 'In progress', value: '2', note: 'Wash and press' }),
        Object.freeze({ label: 'Sales today', value: '184.50', note: 'Cash and transfer' })
      ]),
      queue: Object.freeze([
        Object.freeze({ label: 'Ready', count: 4, max: 6, tone: 'amber' }),
        Object.freeze({ label: 'Processing', count: 2, max: 6, tone: 'teal' }),
        Object.freeze({ label: 'Unpaid', count: 3, max: 6, tone: 'red' })
      ]),
      recentOrders,
      orderHref: 'order-queue.html'
    }),
    owner: Object.freeze({
      metrics: Object.freeze([
        Object.freeze({ label: 'Sales today', value: '412.80', note: 'Cash and transfer' }),
        Object.freeze({ label: 'Orders today', value: '22', note: '6 still open' }),
        Object.freeze({ label: 'Average order', value: '18.76', note: 'Per paid order' }),
        Object.freeze({ label: 'Ready > 2 days', value: '2', note: 'Pickup follow-up' })
      ]),
      week: Object.freeze([
        Object.freeze({ day: 'Mon', value: 284 }),
        Object.freeze({ day: 'Tue', value: 336 }),
        Object.freeze({ day: 'Wed', value: 310 }),
        Object.freeze({ day: 'Thu', value: 402 }),
        Object.freeze({ day: 'Fri', value: 388 }),
        Object.freeze({ day: 'Sat', value: 442 }),
        Object.freeze({ day: 'Sun', value: 413 })
      ]),
      weekMax: 450,
      mix: Object.freeze([
        Object.freeze({ label: 'Wash & fold', value: 38, tone: 'teal' }),
        Object.freeze({ label: 'Bedding', value: 24, tone: 'teal' }),
        Object.freeze({ label: 'Press', value: 22, tone: 'amber' }),
        Object.freeze({ label: 'Dry clean', value: 16, tone: 'amber' })
      ]),
      recentOrders,
      orderHref: 'owner-orders.html'
    })
  });

  return data;
});
