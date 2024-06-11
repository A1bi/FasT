import MapController from './map_controller'

export default class extends MapController {
  setUpMap (mapInfo) {
    this.markers = []

    mapInfo.markers.forEach(markerInfo => {
      const marker = this.createMarker(markerInfo)
      marker.addTo(this.map)
      this.markers.push(marker)
    })

    this.map.scrollZoom.disable()
  }

  createMarker (markerInfo) {
    let element
    if (markerInfo.icon) {
      element = document.createElement('a')
      element.classList.add(markerInfo.icon)
    }

    const marker = new this.mapboxgl.Marker({ element })
    marker.setLngLat(markerInfo.loc)

    const popup = new this.mapboxgl.Popup()
    popup.setHTML(`<h3>${markerInfo.title}</h3>${markerInfo.desc || ''}`)
    marker.setPopup(popup)

    return marker
  }

  fitToFeatures () {
    if (!this.markers) return

    const center = this.markers[this.markers.length - 1].getLngLat()
    this.map.flyTo({ center, zoom: 14 })

    return true
  }
}
