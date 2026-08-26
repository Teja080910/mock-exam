// Button-level loading feedback for admin actions.
// On form submit (or delete/action links), the triggered button/link shows an
// inline spinner and gets disabled, instead of relying only on the
// browser tab spinner during full-page posts.
(function () {
    const SPINNER = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>';

    function showLoading(el) {
        if (!el || el.dataset.loading === '1') return;
        el.dataset.loading = '1';
        el.disabled = true;
        el.dataset.originalHtml = el.innerHTML;
        el.innerHTML = SPINNER + ' Loading...';
        el.style.opacity = '0.7';
    }

    // Forms: disable + spinner on the submit button that was used
    document.addEventListener('submit', function (e) {
        const form = e.target;
        if (!(form instanceof HTMLFormElement)) return;
        // skip AJAX-only toggle forms (they contain no visible submit button)
        const btn = form.querySelector('button[type="submit"], button:not([type])');
        if (btn) showLoading(btn);
    }, true);

    // Action links (edit/delete): show spinner only once navigation is really
    // happening - i.e. inline confirm() handlers ran first and did NOT cancel.
    document.addEventListener('click', function (e) {
        if (e.defaultPrevented) return;               // confirm() cancelled etc.
        if (e.ctrlKey || e.metaKey || e.shiftKey || e.button !== 0) return;
        const link = e.target.closest('a[href]');
        if (!link) return;
        const href = link.getAttribute('href');
        if (!href || href === '#' || href.startsWith('#') || href.startsWith('javascript')) return;
        if (link.target === '_blank') return;

        // small delay so fast navigations / cancelled confirms don't flicker
        setTimeout(function () {
            if (!e.defaultPrevented) showLoading(link);
        }, 250);
    });
})();
