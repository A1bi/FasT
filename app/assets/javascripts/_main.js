function togglePluralText(box, number) {
  var plural = number != 1;
  box.toggleClass("plural", plural).toggleClass("singular", !plural);
  box.find(".number span").text(number);
}

if (!window.console) window.console = { log: function () {} };

var environment = 'production';
var host = location.hostname;
if (host.indexOf('staging') > -1) {
  environment = 'staging';
// either contains .local TLD (mDNS resolved) or no TLD
} else if (host.indexOf('.local') > -1 || host.indexOf('.') < 0) {
  environment = 'development';
}

Raven
  .config('https://1ba66cdff88948a8a0784eaeb89c5dc2@sentry.a0s.de/2', {
    environment: environment,
    shouldSendCallback: function () {
      return environment !== 'development';
    }
  })
  .install();
