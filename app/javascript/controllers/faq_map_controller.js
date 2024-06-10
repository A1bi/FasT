import MapController from './map_controller'

export default class extends MapController {
  createMarker (markerInfo) {
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

    this.createPopupForMarker(marker, markerInfo)

    return marker
  }

  createPopupForMarker (marker, markerInfo) {
    const popup = new this.mapboxgl.Popup({ offset: markerInfo.icon ? 12 : 40 })
    popup.setHTML(`<h3>${markerInfo.title}</h3>${markerInfo.desc || ''}`)
    marker.setPopup(popup)
  }
}
