(() => {
  const body = document.body;
  const toggle = document.getElementById('themeToggle');
  const key = 'exomic-theme';
  const globeCanvas = document.getElementById('exomicGlobe');
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  let globe = null;

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
  if (stored === 'dark' || stored === 'light') setTheme(stored);
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

  if (globeCanvas) {
    // COBE v2.0.1 ships its built ESM entry as dist/index.esm.js.
    // Use that package build directly instead of a CDN transform endpoint so
    // the bundled world-map texture stays part of the same module.
    import('https://cdn.jsdelivr.net/npm/cobe@2.0.1/dist/index.esm.js')
      .then(({ default: createGlobe }) => {
        const dpr = Math.min(window.devicePixelRatio || 1, 2);
        let phi = 0;
        let rafId = 0;

        const getSize = () => {
          const rect = globeCanvas.getBoundingClientRect();
          return Math.max(320, Math.round(rect.width || 500));
        };

        const getTheme = () => {
          const isDark = body.classList.contains('dark');
          return {
            dark: isDark ? 1 : 0,
            baseColor: isDark ? [0.3, 0.3, 0.3] : [1, 1, 1],
            markerColor: isDark ? [1, 1, 1] : [0, 0, 0],
            glowColor: [1, 1, 1],
          };
        };

        const size = getSize();
        globeCanvas.width = Math.round(size * dpr);
        globeCanvas.height = Math.round(size * dpr);

        // Exact core COBE v2 example values, before Exomic-specific styling.
        globe = createGlobe(globeCanvas, {
          devicePixelRatio: dpr,
          width: size,
          height: size,
          phi: 0,
          theta: 0.2,
          ...getTheme(),
          diffuse: 1.2,
          scale: 1,
          mapSamples: 16000,
          mapBrightness: 6,
          mapBaseBrightness: 0,
          offset: [0, 0],
          opacity: 1,
          markers: [],
          arcs: [],
          context: { alpha: true, antialias: true },
        });

        const render = () => {
          if (!globe) return;
          globe.update({ phi });
          if (!reducedMotion.matches) phi += 0.003;
          rafId = requestAnimationFrame(render);
        };

        const applyThemeToGlobe = () => {
          if (!globe) return;
          globe.update(getTheme());
        };

        // Keep theme changes synchronized with the existing site toggle.
        toggle?.addEventListener('click', applyThemeToGlobe);

        const resizeObserver = new ResizeObserver(() => {
          if (!globe) return;
          const nextSize = getSize();
          globe.update({ width: nextSize, height: nextSize });
        });
        resizeObserver.observe(globeCanvas.parentElement || globeCanvas);

        globeCanvas.dataset.cobe = 'ready';
        render();

        window.addEventListener('beforeunload', () => {
          cancelAnimationFrame(rafId);
          resizeObserver.disconnect();
          toggle?.removeEventListener('click', applyThemeToGlobe);
          globe?.destroy();
        }, { once: true });
      })
      .catch((error) => {
        console.warn('COBE globe failed to load.', error);
        globeCanvas.dataset.cobe = 'error';
        globeCanvas.style.display = 'none';
      });
  }

})();
