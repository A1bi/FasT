json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [0, 0, 0],
    foreground: [255, 255, 255],
    label: [33, 154, 213]
  },
  location: [50.23437, 7.13699],
  location_label: 'Sporthalle Kaisersesch',
  location_address: 'Sporthalle Kaisersesch, Schwalbenweg, 56759 Kaisersesch'
)
