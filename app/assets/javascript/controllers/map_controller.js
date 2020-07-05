import { Controller } from 'stimulus'
import { fetch } from '../components/utils'

export default class extends Controller {
  static targets = ['map', 'popup']

  async connect () {
    import(/* webpackChunkName: 'mapbox' */ 'mapbox-gl/dist/mapbox-gl.css') /* eslint-disable-line no-unused-expressions */
    this.mapboxgl = await import(/* webpackChunkName: 'mapbox' */ 'mapbox-gl')

    const mapInfo = await this.fetchMapInformation()

    await this.createMap()
    this.registerEvents()

    this.map.on('load', () => {
      this.limitToBounds()
      this.addMarkers(mapInfo.markers)
      this.fitToMarkersIfInView()
    })
  }

  async fetchMapInformation () {
    const path = `/faq/map.json?identifier=${this.data.get('identifier')}`
    return await fetch(path)
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
    this.map.on('click', 'places', event => {
      const coordinates = event.features[0].geometry.coordinates.slice()
      const props = event.features[0].properties

      const popup = new this.mapboxgl.Popup().setLngLat(coordinates)
      popup.setHTML(`<b>${props.title}</b><br>${props.description}`)
      popup.addTo(this.map)
    })

    this.fitToMarkersIfInView = this.fitToMarkersIfInView.bind(this)
    window.addEventListener('scroll', this.fitToMarkersIfInView)
  }

  addMarkers (markers) {
    this.markerBounds = new this.mapboxgl.LngLatBounds()

    markers.forEach(markerInfo => {
      let el
      if (markerInfo.icon) {
        el = document.createElement('div')
        el.className = markerInfo.icon
      }

      const marker = new this.mapboxgl.Marker({
        element: el,
        color: '#db0303'
      })
      marker.setLngLat(markerInfo.loc)
      marker.addTo(this.map)

      const popup = new this.mapboxgl.Popup({ offset: el ? 12 : 40 })
      popup.setHTML(`<h3>${markerInfo.title}</h3>${markerInfo.desc}`)
      marker.setPopup(popup)

      this.markerBounds.extend(markerInfo.loc)
    })
  }

  limitToBounds () {
    const source = this.map.getSource('openmaptiles')
    this.map.setMaxBounds(source.bounds)
  }

  fitToMarkersIfInView () {
    if (!this.markerBounds) return

    const scrollY = window.pageYOffset + window.innerHeight * 0.6
    if (scrollY < this.mapTarget.offsetTop) return

    this.map.fitBounds(this.markerBounds, { padding: 30, maxZoom: 15 })

    window.removeEventListener('scroll', this.fitToMarkersIfInView)
  }
}
