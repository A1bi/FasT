import MapController from './map_controller'

export default class extends MapController {
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
}
