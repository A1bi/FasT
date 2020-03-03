$(function () {
  $(".question").click(function () {
    $(this).toggleClass("disclosed").find("+ .answer").slideToggle();
  });

  var path = "/faq/map.json?identifier=" + ($("#map").data("identifier") || "");

  if (!$('#map').length) return;

  // init map data
  $.getJSON(path, function (data) {
    if (!data) return;

    var map = new Map("map", data.center, data.zoom);

    map.registerIcons(data.icons);

    data.markers.forEach(function (marker) {
      marker.content = '<b>' + marker.title + '</b><br>' + marker.desc;
    });
    map.addMarkers(data.markers);
  });
});
