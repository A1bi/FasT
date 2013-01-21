$(function () {
	var ad = $(".ad");
	var text = $(".disclaimer", ad);
	
	$("<div>").addClass("line")
	.css({width: text.position().left}).appendTo(ad)
	.clone().css({right: 0}).appendTo(ad);
});