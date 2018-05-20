function deobfuscate(text) {
  return text.replace(/z|q|w|u/g, "");
}

function togglePluralText(box, number) {
  var plural = number != 1;
  box.toggleClass("plural", plural).toggleClass("singular", !plural);
  box.find(".number span").text(number);
}

function dissmissCookieConsent() {
  document.cookie = 'cookie_consent_dismissed=1; expires=Sat, 22 May 2021 22:00:00 CEST +02:00';
  var box = $(this).parent();
  box.css('margin-top', -box.outerHeight());
}

if (!window.console) window.console = { log: function () {} };

Raven
  .config('https://14c471d166ef460ea32f681e65427ae0@sentry.a0s.de/2')
  .install()
  .context(function () {
    $(function () {
      $('#cookie-consent button').click(dissmissCookieConsent);
    });
  });
