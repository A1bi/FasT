import { Controller } from 'stimulus';
import { Map, View, Overlay } from 'ol';
import { Vector, Tile } from 'ol/layer';
import VectorSource from 'ol/source/Vector';
import OSM from 'ol/source/OSM';
import { defaults } from 'ol/interaction';
import { fromLonLat } from 'ol/proj';
import Feature from 'ol/Feature';
import Point from 'ol/geom/Point';
import { Style, Icon } from 'ol/style';

export default class extends Controller {
  static targets = ['map', 'popup'];

  connect() {
    this.loadData();
  }

  async loadData() {
    const path = `/faq/map.json?identifier=${this.data.get('identifier')}`;
    const response = await fetch(path);
    const data = await response.json();

    this.createMap(data.center, data.zoom);
    this.registerIcons(data.icons);
    this.addMarkers(data.markers);
  }

  createMap(center, zoom) {
    this.icons = {};
    this.markerSource = new VectorSource();

    this.popup = new Overlay({
      element: this.popupTarget,
      autoPan: true,
      positioning: 'bottom-center',
      offset: [0, -50]
    });

    this.map = new Map({
      target: this.mapTarget,
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
      overlays: [this.popup]
    });

    this.registerEvents();
  }

  registerEvents() {
    this.map.on('click', event => {
      const feature = this.map.forEachFeatureAtPixel(event.pixel,
                                                     feature => feature);

      this.popupTarget.style.display = !!feature ? 'block' : 'inline';
      if (feature) {
        var coordinates = feature.getGeometry().getCoordinates();
        this.popup.setPosition(coordinates);
        this.popupTarget.innerHTML = feature.get('content');
      }
    });

    this.map.on('pointermove', event => {
      if (event.dragging) {
        this.popupTarget.style.display = 'none';
        return;
      }
      const pixel = this.map.getEventPixel(event.originalEvent);
      const hit = this.map.hasFeatureAtPixel(pixel);
      this.mapTarget.style.cursor = hit ? 'pointer' : 'auto';
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
      const feature = new Feature({
        geometry: new Point(fromLonLat(markerInfo.loc)),
        content: `<b>${markerInfo.title}</b><br>${markerInfo.desc}`
      });
      feature.setStyle(this.icons[markerInfo.icon]);
      this.markerSource.addFeature(feature);
    }
  }
}
