json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [255, 255, 255],
    foreground: [0, 0, 0],
    label: [0, 102, 51]
  },
  location: [50.230782, 7.141477],
  location_label: 'Altes Kino Kaisersesch',
  location_address: 'Altes Kino, Burgstraße, 56759 Kaisersesch'
)
