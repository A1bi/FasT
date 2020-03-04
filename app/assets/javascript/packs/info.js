import Map from '../map';

$(() => {
  $(".question").click(event => {
    $(event.currentTarget).toggleClass('disclosed').find('+ .answer')
                          .slideToggle();
  });

  const identifier = $('#map').data('identifier');
  const path = `/faq/map.json?identifier=${identifier}`;

  if (!$('#map').length) return;

  // init map data
  $.getJSON(path, data => {
    if (!data) return;

    const map = new Map('map', data.center, data.zoom);

    map.registerIcons(data.icons);

    data.markers.forEach(marker => {
      marker.content = `<b>${marker.title}</b><br>${marker.desc}`;
    });
    map.addMarkers(data.markers);
  });
});
