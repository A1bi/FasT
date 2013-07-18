//= require map
//= require spin

function Weather() {
	
	var weatherData = {}, wBox, spinner;
	
	var getData = function () {
		$.getJSON("/info/weather.json", function (data) {
			weatherData = data.data;
			
			initWeather();
		});
	}
	
	var initWeather = function () {
		var image = $("<img />").attr("src", "/assets/info/weather/"+weatherData.code+weatherData.daytime+".png").load(function () {
			$(".loader", wBox).fadeOut(function () {
        spinner.stop();
				$(".info", wBox).fadeIn();
			});
		}).appendTo($(".icon", wBox));
		
		$.each(weatherData, function (key, value) {
			$("."+key, wBox).html(value);
		});
	}
	
	this.init = function () {
    wBox = $(".weather");
    
    var opts = {
      lines: 17,
      length: 15,
      width: 6,
      radius: 19,
      trail: 60
    };
    spinner = new Spinner(opts).spin($(".loader", wBox).get(0));
    
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
