(function () {
  $("body").append($("<div>").html("\
    <div>\
        Sie verwenden einen <b>stark veralteten</b> und <b>unsicheren</b> Internetbrowser (Internet Explorer).\
        <br />Dieser kann unsere Website leider nicht korrekt darstellen.\
      <p>\
        Dieses Problem können Sie beheben, indem Sie unsere Seiten in einem der unten genannten aktuellen Browser aufrufen.\
        <br />Sollten Sie keines dieser Beispiele installiert haben, können Sie dies problemlos nachholen.\
        <br />Download und Installation sind schnell, einfach und <b>kostenlos</b>.\
      </p>\
      <ul>\
        <li><a href=\"https://www.mozilla.org/de/firefox/new/\">Mozilla Firefox</a></li>\
        <li><a href=\"https://www.google.com/intl/de/chrome/browser/\">Google Chrome</a></li>\
        <li><a href=\"http://www.apple.com/de/safari/\">Apple Safari</a></li>\
      </ul>\
    </div>\
  ").prop("id", "unsupportedBrowser"));
})();