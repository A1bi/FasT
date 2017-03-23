//= require map
//= require spinjs

function Weather() {

  var weatherData = {}, wBox, spinner;

  var getData = function () {
    $.getJSON("/faq/weather.json", function (data) {
      weatherData = data.data;

      initWeather();
    });
  }

  var initWeather = function () {
    var image = $("<img />").attr("src", "/assets/info/weather/" + weatherData.icon + ".gif").on('load', function () {
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
    wBox = $("#wu");
    if (!wBox.length) {
      return;
    }

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
  $(".question").click(function () {
    $(this).toggleClass("disclosed").find("+ .answer").slideToggle();
  });

  var path = "/faq/map" + ($("#map").is(".fall") ? "_fall" : "") + ".json";

  // init map data
  $.getJSON(path, function (data) {
    var map = new Map("map", data.center, data.zoom);

    map.registerIcons(data.icons);

    data.markers.forEach(function (marker) {
      marker.content = '<b>' + marker.title + '</b><br>' + marker.desc;
    });
    map.addMarkers(data.markers);
  });

  // init weather
  var weather = new Weather();
  weather.init();
});
