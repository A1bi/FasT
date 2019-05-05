json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [47, 61, 131],
    foreground: [255, 255, 255],
    label: [177, 203, 34]
  },
  location: [50.23089, 7.141626],
  location_label: 'Historischer Ortskern',
  location_address: 'Burgstraße, 56759 Kaisersesch'
)
