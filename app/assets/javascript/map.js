import { Map, View, Overlay } from 'ol';
import { Vector, Tile } from 'ol/layer';
import VectorSource from 'ol/source/Vector';
import OSM from 'ol/source/OSM';
import { defaults } from 'ol/interaction';
import { fromLonLat } from 'ol/proj';
import Feature from 'ol/Feature';
import Point from 'ol/geom/Point';
import { Style, Icon } from 'ol/style';
import $ from 'jquery';

export default class {
  constructor(id, center, zoom) {
    this.icons = {};
    this.markerSource = new VectorSource();

    const $map = $(`#${id}`);
    const $popup = $('<div>').addClass('popup').appendTo($map);
    const popup = new Overlay({
      element: $popup.get(0),
      autoPan: true,
      positioning: 'bottom-center',
      offset: [0, -50]
    });

    const map = new Map({
      target: $map.get(0),
      layers: [
        new Tile({
          source: new OSM()
        }),
        new Vector({
          source: this.markerSource
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

    map.on('click', event => {
      const feature = map.forEachFeatureAtPixel(event.pixel, feature => feature);

      $popup.toggle(!!feature);
      if (feature) {
        var coordinates = feature.getGeometry().getCoordinates();
        popup.setPosition(coordinates);
        $popup.html(feature.get('content'));
      }
    });

    map.on('pointermove', event => {
      if (event.dragging) {
        $popup.hide();
        return;
      }
      const pixel = map.getEventPixel(event.originalEvent);
      const hit = map.hasFeatureAtPixel(pixel);
      $map.css('cursor', hit ? 'pointer' : 'auto');
    });
  }

  registerIcons(icons) {
    for (let iconInfo of icons) {
      this.icons[iconInfo.name] = new Style({
        image: new Icon({
          anchor: iconInfo.offset,
          anchorXUnits: 'pixels',
          anchorYUnits: 'pixels',
          src: iconInfo.file
        })
      });
    }
  }

  addMarkers(markers) {
    for (let markerInfo of markers) {
      var feature = new Feature({
        geometry: new Point(fromLonLat(markerInfo.loc)),
        content: markerInfo.content
      });
      feature.setStyle(this.icons[markerInfo.icon]);
      this.markerSource.addFeature(feature);
    }
  }
}
