import { Controller } from '@hotwired/stimulus'
import { loadVendorStylesheet, fetch } from 'components/utils'

export default class extends Controller {
  static targets = ['map', 'popup']
  static values = {
    vendorStylesheetPath: String,
    infoPath: String
  }

  async connect () {
    await loadVendorStylesheet(this.vendorStylesheetPathValue)

    this.mapboxgl = (await import('mapbox-gl')).default

    const mapInfo = await fetch(this.infoPathValue)

    await this.createMap()
    this.registerEvents()

    this.map.on('load', () => {
      this.limitToBounds()
      this.addMarkers(mapInfo.markers)
      this.fitToMarkersIfInView()
    })
  }

  async createMap () {
    this.map = new this.mapboxgl.Map({
      container: this.mapTarget,
      style: 'https://maps.a0s.de/styles/osm-bright/style.json'
    })

    this.map.addControl(new this.mapboxgl.NavigationControl())
    this.map.scrollZoom.disable()
  }

  registerEvents () {
    this.fitToMarkersIfInView = this.fitToMarkersIfInView.bind(this)
    window.addEventListener('scroll', this.fitToMarkersIfInView)
  }

  limitToBounds () {
    const source = this.map.getSource('openmaptiles')
    this.map.setMaxBounds(source.bounds)
  }

  addMarkers (markers) {
    this.markers = []

    markers.forEach(markerInfo => {
      const marker = this.createMarker(markerInfo)
      marker.addTo(this.map)
      this.markers.push(marker)
    })
  }

  fitToMarkersIfInView () {
    if (!this.markers) return

    const scrollY = window.pageYOffset + window.innerHeight * 0.6
    if (scrollY < this.mapTarget.offsetTop) return

    const center = this.markers[this.markers.length - 1].getLngLat()
    this.map.flyTo({ center, zoom: 14 })

    window.removeEventListener('scroll', this.fitToMarkersIfInView)
  }
}
