/*var slideshow = new function () {
	var cur = Math.round(Math.random() * slides.length-1);

	var next = function () {
		if (slides.length < 1) return;

		if (Math.random() * 6 > 5) {
			$("#slides .finished").hide();
			$("#slides .ani").fadeOut(1500);
			setTimeout(next, 10000);
			return;
		}
		setTimeout(next, 7500);

		if (++cur >= slides.length) cur = 0;

		$("#slides .ani").removeClass("ani");
		$("#slides .finished").first()
		.hide()
		.removeClass("finished")
		.addClass("ani")
		.css({
			"background-image": "url(/gfx/cache/slides/" + slides[cur] + ".jpg)"
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
			next();
		}
	});
};*/

function deobfuscate(text) {
	return text.replace(/z|q|w|u/g, "");
}