function deobfuscate(text) {
  return text.replace(/z|q|w|u/g, "");
}

function togglePluralText(box, number) {
  var plural = number != 1;
  box.toggleClass("plural", plural).toggleClass("singular", !plural);
  box.find(".number span").text(number);
}

if (!window.console) window.console = { log: function () {} };

Raven
  .config('https://14c471d166ef460ea32f681e65427ae0@sentry.a0s.de/2')
  .install();
