$(function () {
  
  var speed = 10;
  var moveNext = function (init) {
		curBox.css("left", (init) ? 0 : boxWidth);
		var easing = "linear";
		
    var firstStop = boxWidth - logosBoxWidth;
		curBox.animate({left: firstStop}, (curBox.position().left - firstStop) * speed, easing, function () {
			moveNext();
      $(this).animate({left: -logosBoxWidth}, (firstStop + logosBoxWidth) * speed, easing);
		});
    
    curBox = curBox.siblings(".logos").first();
	};
  
  var positionLogos = function () {
    var logosBox = logosBoxes.first();
    var logos = logosBox.find("div");
    if (loadedLogos < logos.length) return;
    
    var left = 0;
    logos.each(function (index) {
      $(this).css({left: left});
      left += $(this).outerWidth();
    });
    
    logosBoxWidth = logosBox.outerWidth();
    logosBox.clone().appendTo(sponsorsBox).css({left: boxWidth});
    logosBoxes = sponsorsBox.find(".logos");
    
    moveNext(true);
  };
  
	var sponsorsBox = $("#spons"),
      logosBoxes = sponsorsBox.find(".logos"),
      curBox = logosBoxes.first(),
      loadedLogos = 0,
      logosBoxWidth = 0,
      boxWidth = sponsorsBox.outerWidth();
    
  $.each(sponsorsBox.data("sponsors"), function () {
    var logo = $("<img>").attr("src", "/assets/dates/spons/"+this[0]+".png").attr("alt", this[1]).load(function () {
      loadedLogos++;
      positionLogos();
    });
    var logoBox = $("<div>").append(logo);
		logosBoxes.append(logoBox);
  });
	
	logosBoxes.first().fadeIn(2500);
  
});
