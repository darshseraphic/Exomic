(() => {
  const body = document.body;
  const toggle = document.getElementById('themeToggle');
  const key = 'exomic-theme';

  const setTheme = (theme) => {
    const isDark = theme === 'dark';
    body.classList.toggle('dark', isDark);
    localStorage.setItem(key, theme);
    if (toggle) toggle.querySelector('span').textContent = isDark ? '☀' : '☾';

    document.querySelectorAll('img[data-light-src][data-dark-src]').forEach((img) => {
      const next = isDark ? img.dataset.darkSrc : img.dataset.lightSrc;
      if (next && img.getAttribute('src') !== next) img.setAttribute('src', next);
    });
  };

  const stored = localStorage.getItem(key);
  if (stored) setTheme(stored);
  toggle?.addEventListener('click', () => {
    setTheme(body.classList.contains('dark') ? 'light' : 'dark');
  });

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.08, rootMargin: '0px 0px -20px 0px' });

  document.querySelectorAll('.reveal').forEach((el) => observer.observe(el));

  const year = document.getElementById('year');
  if (year) year.textContent = new Date().getFullYear();
})();
