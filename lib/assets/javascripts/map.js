//= require OpenLayers/ol.js

function Map(id, center, zoom) {
  var _this = this;
  var icons = {};
  var markerSource = new ol.source.Vector();

  this.registerIcons = function (icns) {
    icns.forEach(function (iconInfo) {
      icons[iconInfo.name] = new ol.style.Style({
        image: new ol.style.Icon({
          anchor: iconInfo.offset,
          anchorXUnits: 'pixels',
          anchorYUnits: 'pixels',
          src: iconInfo.file
        })
      });
    });
  }

  this.addMarkers = function (markers) {
    markers.forEach(function (markerInfo) {
      var feature = new ol.Feature({
        geometry: new ol.geom.Point(ol.proj.fromLonLat(markerInfo.loc)),
        content: markerInfo.content
      });
      feature.setStyle(icons[markerInfo.icon]);
      markerSource.addFeature(feature);
    });
  }

  var $map = $('#' + id);

  var $popup = $('<div>').addClass('popup').appendTo($map);
  var popup = new ol.Overlay({
    element: $popup.get(0),
    autoPan: true,
    positioning: 'bottom-center',
    offset: [0, -50]
  });

  var map = new ol.Map({
    target: $map.get(0),
    layers: [
      new ol.layer.Tile({
        source: new ol.source.OSM()
      }),
      new ol.layer.Vector({
        source: markerSource
      })
    ],
    interactions: ol.interaction.defaults({
      mouseWheelZoom: false
    }),
    view: new ol.View({
      center: ol.proj.fromLonLat(center),
      zoom: zoom
    }),
    overlays: [popup]
  });

  map.on('click', function (event) {
    var feature = map.forEachFeatureAtPixel(event.pixel, function (feature) {
      return feature;
    });

    $popup.toggle(!!feature);
    if (feature) {
      var coordinates = feature.getGeometry().getCoordinates();
      popup.setPosition(coordinates);
      $popup.html(feature.get('content'));
    }
  });

  map.on('pointermove', function (event) {
    if (event.dragging) {
      $popup.hide();
      return;
    }
    var pixel = map.getEventPixel(event.originalEvent);
    var hit = map.hasFeatureAtPixel(pixel);
    $map.css('cursor', hit ? 'pointer' : 'auto');
  });
}
