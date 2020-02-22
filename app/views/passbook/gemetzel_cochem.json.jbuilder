# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [0, 0, 0],
    foreground: [255, 255, 255],
    label: [255, 241, 2]
  },
  location: [50.146038, 7.165255],
  location_label: 'Kulturzentrum Kapuzinerkloster',
  location_address: 'Klosterberg 5, 56812 Cochem'
)
