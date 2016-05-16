function Gallery(g) {

	var gallery = g;
	var pics = [];
	var cur = -1;
	var downloadPath;
	
	this.addPics = function (p) {
		$.extend(pics, p);
	}
	
	var updatePic = function () {
		var curPic = pics[cur];
		
		$(".photo img").attr("src", curPic.path).load(function () {
			$(this).parent().css({width: $(this).width()});
			
			var nextPic = pics[getIndex(1)];
			var preload = new Image();
			preload.src = nextPic.path;
		});
		
		var numbers = $(".bar .number span");
		numbers.eq(0).html(cur+1);
		numbers.eq(1).html(pics.length);
		
		$(".bar .desc").html(curPic.text);
		
		var link = $('#download-link a');
		if (!downloadPath) {
			downloadPath = link.attr('href');
		}
		link.attr('href', downloadPath.replace('-id-', curPic.id));
	}
	
	var getIndex = function (direction) {
		var tmp = cur + direction;
		
		if (tmp < 0) {
			tmp = pics.length - 1;
		} else if (tmp >= pics.length) {
			tmp = 0;
		}
		
		return tmp;
	}
	
	var go = function (direction) {
		cur = getIndex(direction);
		
		updatePic();
	}
	
	var goNext = function () {
		go(1);
	}
	
	var goPrev = function () {
		go(-1);
	}
	
	var registerEvents = function () {
		$(".next").click(goNext);
		$(".prev").click(goPrev);
		
		$(document).keyup(function (event) {
			switch (event.which) {
				case 37:
					goPrev();
					break;
				case 39:
					goNext();
					break;
			}
		});
	}
	
	this.init = function () {
		$(function () {
			$(".photo").append($("<img>").attr("alt", ""));
			registerEvents();
		
			goNext();
		});
	}
}