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

function togglePluralText(box, number, preservedClass) {
  var cssClass = (number != 1) ? "plural" : "singular";
  box.removeClass().addClass(preservedClass + " plural_text " + cssClass);
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
    display: ["chrome", "firefox", "safari"],
    imagePath: "/assets/images/jReject/",
    header: "Bitte aktualisieren Sie Ihren Internetbrowser",
    paragraph1: "Leider verwenden Sie einen <b>veralteten Internetbrowser</b>, der unsere Seiten nicht korrekt darstellen und Sie zudem <b>großen Sicherheitsrisiken</b> aussetzen kann.",
    paragraph2: "Installieren Sie sich einfach einen dieser <b>kostenlosen</b> Browser und in wenigen Minuten ist das Problem behoben.",
    closeLink: "Diese Warnung ignorieren und akzeptieren, dass manche Dinge nicht funktionieren werden",
    closeMessage: "",
    closeCookie: true,
    fadeInTime: 0,
    fadeOutTime: 0,
    beforeReject: function () {
      if ($.browser.name == "msie") {
        this.close = false;
      }
    },
    afterReject: function () {
      var inner = $("#jr_inner"), list = inner.find("ul");
      list.css("margin-left", (inner.width() - list.width()) / 2);
    }
  });
});