import { Map, View, Overlay } from 'ol';
import { Vector, Tile } from 'ol/layer';
import VectorSource from 'ol/source/Vector';
import OSM from 'ol/source/OSM';
import { defaults } from 'ol/interaction';
import { fromLonLat } from 'ol/proj';
import Feature from 'ol/Feature';
import Point from 'ol/geom/Point';
import { Style, Icon } from 'ol/style';

window.Map = function (id, center, zoom) {
  var _this = this;
  var icons = {};
  var markerSource = new VectorSource();

  this.registerIcons = function (icns) {
    icns.forEach(function (iconInfo) {
      icons[iconInfo.name] = new Style({
        image: new Icon({
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
      var feature = new Feature({
        geometry: new Point(fromLonLat(markerInfo.loc)),
        content: markerInfo.content
      });
      feature.setStyle(icons[markerInfo.icon]);
      markerSource.addFeature(feature);
    });
  }

  var $map = $('#' + id);

  var $popup = $('<div>').addClass('popup').appendTo($map);
  var popup = new Overlay({
    element: $popup.get(0),
    autoPan: true,
    positioning: 'bottom-center',
    offset: [0, -50]
  });

  var map = new Map({
    target: $map.get(0),
    layers: [
      new Tile({
        source: new OSM()
      }),
      new Vector({
        source: markerSource
      })
    ],
    interactions: defaults({
      mouseWheelZoom: false
    }),
    view: new View({
      center: fromLonLat(center),
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
