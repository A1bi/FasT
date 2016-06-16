//= require OpenLayers/OpenLayers.js

function Map(id, urls) {
	
	var fromProjection = new OpenLayers.Projection("EPSG:4326");
	var toProjection = new OpenLayers.Projection("EPSG:900913");
	var icons = [];
	var locations = [];
	var layers = {};
	var _this = this;
	this.map;
	
	this.registerIcons = function (icns) {
		$.each(icns, function (key, value) {
			var size = new OpenLayers.Size(value.size[0], value.size[1]);
			var offset = new OpenLayers.Pixel(value.offset[0], value.offset[1]);
			var icon = new OpenLayers.Icon(value.file, size, offset);
			
			icons[value.name] = icon;
		});
	}
	
	this.registerLocations = function (locs) {
		$.each(locs, function (key, loc) {
			var location = new OpenLayers.LonLat(loc[0], loc[1]).transform(fromProjection, toProjection);
			locations.push(location);
		});
	}
	
	this.addMarkers = function (markers) {
		$.each(markers, function (key, value) {
			var loc = locations[value.loc];
			
			var feature = new OpenLayers.Feature(layers.markers, loc, {
				icon: icons[value.icon].clone(),
				closeBox: false,
				popupClass: OpenLayers.Class(OpenLayers.Popup.Anchored)
			});
			
			var marker = feature.createMarker();
			layers.markers.addMarker(marker);
			
			if (value.bubble) {
				var popup = feature.createPopup(feature.closeBox);
				popup.autoSize = true;
				popup.contentHTML = "<b>" + value.title + "</b><br />" + value.desc;
				popup.panMapIfOutOfView = true;
				popup.keepInMap = false;
				popup.opacity = .9;
				popup.calculateRelativePosition = function () {
					return 'bl';
    			}
    			popup.anchor = {'size': new OpenLayers.Size(0,0), 'offset': new OpenLayers.Pixel(-12, 3)};
    			
				marker.events.register("mousedown", popup, function (event) {
					if (_this.map.popups[0] != this) {
						_this.map.addPopup(this, true);
						this.show();
					} else {
						this.toggle();
					}

					OpenLayers.Event.stop(event);
				});
			}
			
		});
	}
	
	this.setCenter = function (loc, zoom) {
		this.map.setCenter(locations[loc], zoom);
	}
	
	var addLayer = function (layer, name) {
		layers[name] = layer;
		_this.map.addLayer(layer);
	}
	
	
	this.map = new OpenLayers.Map(id, {
		controls: [
			new OpenLayers.Control.Navigation({
				zoomWheelEnabled: false
			}),
			new OpenLayers.Control.Attribution(),
			new OpenLayers.Control.PanZoomBar({ panIcons: false })
		],
		theme: null
	});

	addLayer(new OpenLayers.Layer.OSM(null, urls), "osm");
	addLayer(new OpenLayers.Layer.Markers("markers"), "markers");

}