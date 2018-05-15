$(window).on('load', function () {
  var ad = $(".partner-lotto").addClass('adjusted');
  var wrap = ad.find(".wrap");
  var text = wrap.find(".disclaimer");

  $("<div>").addClass("line")
  .css({width: text.position().left}).appendTo(wrap)
  .clone().css({right: 0}).appendTo(wrap);

  ad.css("min-height", wrap.outerHeight(true));
});
