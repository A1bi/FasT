# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [255, 255, 255],
    foreground: [0, 144, 14],
    label: [242, 50, 51]
  }
)
