var slideshow = new function () {
	var cur;

	var next = function () {
		if (slides.length < 1) return;

		setTimeout(next, 7500);

		if (++cur >= slides.length) cur = 0;
		var currentSlide = slides[cur];
		
		var url =
			"/system/photos/images/000/000/"
			+ ("000" + currentSlide[0]).slice(currentSlide[0].toString.length)
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
		if (!$("body").is(".noSlides")) {
			cur = Math.round(Math.random() * slides.length-1);
			next();
		}
	});
};

function deobfuscate(text) {
	return text.replace(/z|q|w|u/g, "");
}