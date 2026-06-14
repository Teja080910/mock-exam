// Minimal placeholder for template-customizer
// Some pages reference this file; provide a no-op to avoid 404/HTML responses
(function () {
  // If a real template customizer is present in your theme, replace this file
  // with the vendor-provided implementation. This stub prevents "Unexpected token '<'"
  // when the browser requests the file but the server returns HTML instead.
  if (typeof window !== 'undefined') {
    window.templateCustomizer = window.templateCustomizer || {};
  }
})();
