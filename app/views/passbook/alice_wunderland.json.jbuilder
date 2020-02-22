# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [255, 255, 255],
    foreground: [240, 127, 60],
    label: [240, 127, 60]
  },
  location: [50.232490, 7.143670],
  location_label: 'Alte Schule',
  location_address: 'Koblenzer Straße 19, 56759 Kaisersesch'
)
