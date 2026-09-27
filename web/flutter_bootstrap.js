{{flutter_js}}
{{flutter_build_config}}

const status = document.getElementById('startup-status');
const retry = document.getElementById('retry');
const messages = {
  en: ['Try again', 'Preparing your linear algebra workspace…', 'The workspace could not load. Check your connection and try again.'],
  tr: ['Tekrar dene', 'Lineer cebir çalışma alanınız hazırlanıyor…', 'Çalışma alanı yüklenemedi. Bağlantınızı kontrol edip tekrar deneyin.'],
  es: ['Reintentar', 'Preparando tu espacio de álgebra lineal…', 'No se pudo cargar el espacio. Revisa la conexión e inténtalo de nuevo.'],
  ru: ['Повторить', 'Подготовка пространства линейной алгебры…', 'Не удалось загрузить приложение. Проверьте подключение и повторите попытку.'],
  zh: ['重试', '正在准备线性代数工作区……', '无法加载工作区。请检查网络连接后重试。'],
};
const language = navigator.language.toLowerCase().split('-')[0];
const text = messages[language] || messages.en;
document.documentElement.lang = messages[language] ? language : 'en';
retry.textContent = text[0];
retry.addEventListener('click', () => window.location.reload());
status.textContent = text[1];

function showFailure() {
  status.textContent = text[2];
  retry.hidden = false;
}

// Offline support; the strategy is described in offline_worker.js. Relative
// URLs resolve against <base href>, so this works under any deployment path.
const offlineWorker =
  'serviceWorker' in navigator
    ? navigator.serviceWorker
        .register('offline_worker.js', { scope: './', updateViaCache: 'none' })
        .catch(() => null)
    : Promise.resolve(null);

// Hands the worker every file the page loads, including those fetched before
// the worker took control, so the first online visit is enough offline.
function cacheLoadedFiles() {
  offlineWorker.then((registration) => {
    if (!registration || !('PerformanceObserver' in window)) return;
    const send = (cacheUrls) =>
      navigator.serviceWorker.ready.then((ready) => ready.active.postMessage({ cacheUrls }));
    send([window.location.href]);
    new PerformanceObserver((list) => send(list.getEntries().map((entry) => entry.name)))
      .observe({ type: 'resource', buffered: true });
  });
}

const startupTimeout = window.setTimeout(showFailure, 30000);
_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    try {
      const runner = await engineInitializer.initializeEngine();
      await runner.runApp();
      window.clearTimeout(startupTimeout);
      document.getElementById('startup').remove();
      cacheLoadedFiles();
    } catch (_) {
      window.clearTimeout(startupTimeout);
      showFailure();
    }
  },
}).catch(showFailure);
