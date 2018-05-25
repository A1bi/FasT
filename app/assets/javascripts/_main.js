function deobfuscate(text) {
  return text.replace(/z|q|w|u/g, "");
}

function togglePluralText(box, number) {
  var plural = number != 1;
  box.toggleClass("plural", plural).toggleClass("singular", !plural);
  box.find(".number span").text(number);
}

function dissmissCookieConsent() {
  document.cookie = 'cookie_consent_dismissed=1; expires=Sat, 22 May 2021 22:00:00 CEST +02:00; path=/';
  var box = $(this).parent();
  box.css('margin-top', -box.outerHeight());
}

if (!window.console) window.console = { log: function () {} };

var environment = 'production';
if (location.href.indexOf('staging') > -1) {
  environment = 'staging';
} else if (location.href.indexOf('localhost') > -1) {
  environment = 'development';
}

Raven
  .config('https://1ba66cdff88948a8a0784eaeb89c5dc2@sentry.a0s.de/2', {
    environment: environment,
    shouldSendCallback: function () {
      return environment !== 'development';
    }
  })
  .install()
  .context(function () {
    $(function () {
      $('#cookie-consent button').click(dissmissCookieConsent);
    });
  });
