$(window).load(function () {
	var ad = $(".partner-lotto");
	var text = $(".disclaimer", ad);
	var prev = ad.prev();
	
	$("<div>").addClass("line")
	.css({width: text.position().left}).appendTo(ad)
	.clone().css({right: 0}).appendTo(ad);
	
	$("#content .content").css("min-height", ad.outerHeight(true) + prev.position().top + prev.outerHeight(true));
});