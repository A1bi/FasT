json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [0, 0, 0],
    foreground: [255, 255, 255],
    label: [191, 214, 106]
  },
  location: [50.2292, 7.1265],
  location_label: 'Altes Wasserwerk',
  location_address: '„Altes Wasserwerk“, Auf der Wacht 9, 56759 Kaisersesch'
)
