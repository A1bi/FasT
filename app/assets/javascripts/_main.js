var slideshow = new function () {
  var cur = 0;

  var next = function () {
    if (slides.length < 1) return;

    setTimeout(next, 7500);

    if (++cur >= slides.length) cur = 0;
    var currentSlide = slides[cur];

    var url =
      "/system/photos/images/000/000/"
      + ("000" + currentSlide[0]).slice(currentSlide[0].toString().length)
      + "/slide/" + currentSlide[1] + "?" + currentSlide[2];

    $("#slides .ani").removeClass("ani");
    $("#slides .finished").first()
    .hide()
    .removeClass("finished")
    .addClass("ani")
    .css({
      "background-image": "url(" + url + ")"
    })
    .fadeIn(1500)
    .animate({
      top: -150
    }, {
      duration: 9000,
      easing: "linear",
      queue: false,
      complete: function () {
        $(this).addClass("finished").css({top: 0});
      }
    });

  }

  $(function () {
    if (!$("body").is(".noSlides") && slides.length > 1) {
      slides.sort(function (a, b) {
        return 0.5 - Math.random();
      });

      next();
    }
  });
};

function deobfuscate(text) {
  return text.replace(/z|q|w|u/g, "");
}

function togglePluralText(box, number) {
  var plural = number != 1;
  box.toggleClass("plural", plural).toggleClass("singular", !plural);
  box.find(".number span").text(number);
}

if (!window.console) window.console = { log: function () {} };

$(function () {
  $.reject({
    reject: {
      msie: 8,
      firefox: 5,
      chrome: 13
    },
    display: ["chrome", "firefox"],
    browserInfo: {
      safari: {
        text: "Apple Safari"
      }
    },
    imagePath: "/images/jReject/",
    header: "Auch Ihr Internetbrowser macht Theater",
    paragraph1: "Leider verwenden Sie einen <b>veralteten Internetbrowser</b>, der unsere Seiten nicht korrekt darstellen und Sie zudem <b>großen Sicherheitsrisiken</b> aussetzen kann.",
    paragraph2: "Installieren Sie sich einfach <b>schnell und kostenlos</b> die neueste Version von einem der folgenden Browser und schon ist das Problem behoben.",
    close: false,
    fadeInTime: 0,
    fadeOutTime: 0,
    beforeReject: function () {
      if ($.os.name == "mac") this.display.push("safari");
    },
    afterReject: function () {
      var inner = $("#jr_inner"), list = inner.find("ul");
      inner.css("max-width", "").css("min-width", "");
      list.css("margin-left", (inner.width() - list.width()) / 2);
    }
  });
});
