//= require map

function Weather() {
	
	var weatherData = {};
	
	var getData = function () {
		$.getJSON("/info/weather.json", function (data) {
			weatherData = data.data;
			
			initWeather();
		});
	}
	
	var initWeather = function () {
		var wBox = $(".weather");
		
		var image = $("<img />").attr("src", "/assets/info/weather/"+weatherData.code+weatherData.daytime+".png");
		$(".icon", wBox).append(image);
		var weatherBox = $(".weather");
		
		$.each(weatherData, function (key, value) {
			$("."+key, weatherBox).html(value);
		});
		
		image.load(function () {
			$(".loader", wBox).fadeOut(function () {
				$(".info", wBox).fadeIn();
			});
		});
	}
	
	this.init = function () {
		getData();
	}
	
}

$(function () {
	// init map data
	$.getJSON("/info/map.json", function (data) {
		var map = new Map("map", ["/assets/info/tiles/${z}/${x}/${y}.png"]);
		
		$.each(data.icons, function (key, value) {
			data.icons[key].file = '/assets/info/' + value.file;
		});
		map.registerIcons(data.icons);
		
		map.registerLocations(data.locations);
		
		$.each(data.markers, function (key, value) {
			data.markers[key].bubble = true;
		});
		map.addMarkers(data.markers);
		
		map.setCenter(data.centerLoc, data.zoom);
	});
	
	// init weather
	var weather = new Weather();
	weather.init();
});
