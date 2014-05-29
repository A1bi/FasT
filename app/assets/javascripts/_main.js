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

$(function () {
  var el = $("<div>").prop("id", "ieDetect");
  $("body").append(el);

  el.html("<!--[if IE]><em></em><![endif]-->");
  if (el.find("em").length) {
  
    var v;
    for (v = 10; v >= 6; v--) {
      el.html("<!--[if gte IE " + v + "]><b></b><![endif]-->");
      if (el.find("b").length) break;
    }
    
    if (v < 9) {
      $("html").addClass("unsupportedBrowser");
      $.getScript("/assets/unsupported_browser.js");
    }
  }
  
  el.remove();
});