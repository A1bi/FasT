$(function () {
	$(".double > .row .actor").click(function () {
		$(".double .alt:visible").slideUp();
		
		var show = $(this).parent().next();
		if (!show.is(":visible")) {
			show.slideDown();
		}
	});
});