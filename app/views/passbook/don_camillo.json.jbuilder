# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [255, 255, 255],
    foreground: [0, 144, 14],
    label: [242, 50, 51]
  },
  location: [50.23089, 7.141626],
  location_label: 'Historischer Ortskern',
  location_address: 'Burgstraße, 56759 Kaisersesch'
)
