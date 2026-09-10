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

const startupTimeout = window.setTimeout(showFailure, 30000);
_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    try {
      const runner = await engineInitializer.initializeEngine();
      await runner.runApp();
      window.clearTimeout(startupTimeout);
      document.getElementById('startup').remove();
    } catch (_) {
      window.clearTimeout(startupTimeout);
      showFailure();
    }
  },
}).catch(showFailure);
