# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [255, 255, 255],
    foreground: [0, 0, 0],
    label: [227, 30, 35]
  },
  location: [50.2292, 7.1265],
  location_label: 'Altes Wasserwerk',
  location_address: '„Altes Wasserwerk“, Auf der Wacht 9, 56759 Kaisersesch'
)
