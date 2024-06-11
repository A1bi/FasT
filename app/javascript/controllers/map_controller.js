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
      this.setUpMap(mapInfo)
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

  registerEvents () {}

  limitToBounds () {
    const source = this.map.getSource('openmaptiles')
    this.map.setMaxBounds(source.bounds)
  }
}
