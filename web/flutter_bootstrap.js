{{flutter_js}}
{{flutter_build_config}}

window.addEventListener('unhandledrejection', e => {
  console.error('UNHANDLED REJECTION:', e.reason, e.promise);
});

window.onerror = (msg, src, line, col, err) => {
  console.error('GLOBAL ERROR:', msg, 'at', src, line, col, err);
};

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  config: {
    wasmAllowList: {
      blink: true,
      gecko: true,
      webkit: false,
      unknown: false,
    },
  },
});