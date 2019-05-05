json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [0, 0, 0],
    foreground: [255, 255, 255],
    label: [255, 247, 178]
  },
  location: [50.23089, 7.141626],
  location_label: 'Historischer Ortskern',
  location_address: 'Burgstraße, 56759 Kaisersesch'
)
