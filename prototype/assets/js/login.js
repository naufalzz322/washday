(() => {
  const input = document.querySelector('#login-password');
  const toggle = document.querySelector('.login-reveal');
  if (!input || !toggle) return;

  toggle.addEventListener('click', () => {
    const showing = input.type === 'text';
    input.type = showing ? 'password' : 'text';
    toggle.textContent = showing ? 'Show' : 'Hide';
    toggle.setAttribute('aria-label', showing ? 'Show password' : 'Hide password');
    toggle.setAttribute('aria-pressed', String(!showing));
    input.focus({ preventScroll: true });
  });

  const accountForm = document.querySelector('.login-account-form');
  const accountSelect = document.querySelector('#login-account');
  const email = document.querySelector('#login-email');
  const loginForm = document.querySelector('.login-form');
  const accounts = {
    'customer-a': { email: 'customer.a@washday.test', password: 'washday123' },
    'customer-b': { email: 'customer.b@washday.test', password: 'washday123' },
    clerk: { email: 'clerk@washday.test', password: 'washday123' },
    owner: { email: 'owner@washday.test', password: 'washday123' }
  };
  accountSelect?.addEventListener('change', () => {
    const account = accounts[accountSelect.value];
    if (!account) return;
    if (email) email.value = account.email;
    input.value = account.password;
    const destination = accountSelect.selectedOptions[0]?.dataset.destination;
    if (loginForm && destination) loginForm.action = destination;
  });
})();
