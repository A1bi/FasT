# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [0, 0, 0],
    foreground: [255, 255, 255],
    label: [191, 214, 106]
  }
)
