import MapController from '../map_controller'

export default class extends MapController {
  registerEvents () {
    super.registerEvents()

    this.map.on('click', 'clusters', e => {
      const feature = this.map.queryRenderedFeatures(e.point, { layers: ['clusters'] })[0]
      this.zoomIntoCluster(feature)
    })

    this.map.on('click', 'unclustered_point', e => {
      const feature = e.features[0]
      const props = feature.properties

      const popup = new this.mapboxgl.Popup().setLngLat(feature.geometry.coordinates)
      popup.setHTML(`<h3>${props.city}</h3><p>${props.postcode}</p><p>${props.orders} Bestellungen</p>`)
      popup.addTo(this.map)
    })

    const layers = ['clusters', 'unclustered_point']
    const events = ['mouseenter', 'mouseleave']
    layers.forEach(layer => {
      events.forEach(event => {
        this.map.on(event, layer, () => {
          this.map.getCanvas().style.cursor = event === 'mouseenter' ? 'pointer' : ''
        })
      })
    })
  }

  setUpMap (mapInfo) {
    this.map.addSource('orders', {
      type: 'geojson',
      data: this.geoJsonData(mapInfo),
      cluster: true,
      clusterProperties: {
        orders_sum: ['+', ['get', 'orders']]
      }
    })

    this.addCircleLayer('clusters', true, 20, 3)
    this.addCircleLayer('unclustered_point', false, 10, 2)
    this.addSymbolLayer('cluster_count', true, 'orders_sum')
    this.addSymbolLayer('orders_count', false, 'orders')
  }

  geoJsonData (mapInfo) {
    const features = mapInfo.locations.map(location => {
      return {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: location.coordinates
        },
        properties: {
          orders: location.orders,
          postcode: location.postcode,
          city: location.cities[0]
        }
      }
    })

    return {
      type: 'FeatureCollection',
      features
    }
  }

  addCircleLayer (id, filterClusters, radius, strokeWidth) {
    this.map.addLayer({
      id,
      type: 'circle',
      source: 'orders',
      filter: this.filterForSource(filterClusters),
      paint: {
        'circle-color': '#ff5c5c',
        'circle-radius': radius,
        'circle-stroke-width': strokeWidth,
        'circle-stroke-color': '#fff'
      }
    })
  }

  addSymbolLayer (id, filterClusters, textProp) {
    this.map.addLayer({
      id,
      type: 'symbol',
      source: 'orders',
      filter: this.filterForSource(filterClusters),
      layout: {
        'text-field': ['get', textProp]
      },
      paint: {
        'text-color': '#fff'
      }
    })
  }

  fitToFeatures () {
    const layer = this.map.getLayer('clusters')
    if (!layer) return

    const features = this.map.queryRenderedFeatures({
      layers: ['clusters'],
      filter: this.filterForSource(true)
    })
    if (features.length < 1) return

    this.zoomIntoCluster(features[0])

    return true
  }

  zoomIntoCluster (feature) {
    this.map.getSource('orders').getClusterExpansionZoom(feature.properties.cluster_id, (err, zoom) => {
      if (err) return

      this.map.easeTo({
        center: feature.geometry.coordinates,
        zoom
      })
    })
  }

  filterForSource (filterClusters) {
    return filterClusters ? ['has', 'point_count'] : ['!', ['has', 'point_count']]
  }
}
