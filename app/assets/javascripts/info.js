//= require map
//= require spin.js/spin

function Weather() {

	var weatherData = {}, wBox, spinner;

	var getData = function () {
		$.getJSON("/info/weather.json", function (data) {
			weatherData = data.data;

			initWeather();
		});
	}

	var initWeather = function () {
		var image = $("<img />").attr("src", "/assets/info/weather/" + weatherData.icon + ".gif").load(function () {
			$(".loader", wBox).addClass("out");
      setTimeout(function () {
				spinner.stop();
			}, 500);
			$(".fadeIn", wBox).addClass("in");
		}).appendTo($(".icon", wBox));

		$.each(weatherData, function (key, value) {
			if (key === "icon") {
				return;
			}
			$("."+key, wBox).html(value);
		});
	}

	this.init = function () {
    wBox = $(".weather");

    var opts = {
      lines: 12,
      length: 10,
      width: 6,
      radius: 14,
      trail: 60
    };
    spinner = new Spinner(opts).spin($(".loader", wBox).get(0));

		getData();
	}

}

$(function () {
	// init map data
	$.getJSON("/info/map.json", function (data) {
		var map = new Map("map", ["https://a.tile.openstreetmap.org/${z}/${x}/${y}.png"]);

		$.each(data.icons, function (key, value) {
			data.icons[key].file = value.file;
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
