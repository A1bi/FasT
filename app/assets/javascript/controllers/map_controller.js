import { Controller } from 'stimulus'
import { fetch } from '../components/utils'
import mapboxgl from 'mapbox-gl'

import 'mapbox-gl/dist/mapbox-gl.css'

export default class extends Controller {
  static targets = ['map', 'popup'];

  connect () {
    this.loadData()
  }

  async loadData () {
    const path = `/faq/map.json?identifier=${this.data.get('identifier')}`
    const data = await fetch(path)

    this.createMap(data.center, data.zoom)
    this.registerEvents()

    this.map.on('load', () => {
      this.registerIcons(data.icons)
      this.addMarkers(data.markers)
    })
  }

  createMap (center, zoom) {
    this.map = new mapboxgl.Map({
      container: this.mapTarget,
      style: 'https://maps.a0s.de/styles/osm-bright/style.json',
      center: center,
      zoom: zoom
    })

    this.map.addControl(new mapboxgl.NavigationControl())
    this.map.scrollZoom.disable()
  }

  registerEvents () {
    this.map.on('click', 'places', event => {
      const coordinates = event.features[0].geometry.coordinates.slice()
      const props = event.features[0].properties

      const popup = new mapboxgl.Popup().setLngLat(coordinates)
      popup.setHTML(`<b>${props.title}</b><br>${props.description}`)
      popup.addTo(this.map)
    })
  }

  registerIcons (icons) {
    for (const iconInfo of icons) {
      this.map.loadImage(iconInfo.file, (error, image) => {
        if (error) return

        this.map.addImage(iconInfo.name, image)
      })
    }
  }

  addMarkers (markers) {
    const features = markers.map(marker => {
      return {
        type: 'Feature',
        properties: {
          title: marker.title,
          description: marker.desc,
          icon: marker.icon
        },
        geometry: {
          type: 'Point',
          coordinates: marker.loc
        }
      }
    })

    this.map.addSource('places', {
      type: 'geojson',
      data: {
        type: 'FeatureCollection',
        features: features
      }
    })

    this.map.addLayer({
      id: 'places',
      type: 'symbol',
      source: 'places',
      layout: {
        'icon-image': '{icon}',
        'icon-allow-overlap': true
      }
    })

    this.map.on('mouseenter', 'places', () => {
      this.map.getCanvas().style.cursor = 'pointer'
    })

    this.map.on('mouseleave', 'places', () => {
      this.map.getCanvas().style.cursor = ''
    })
  }
}
