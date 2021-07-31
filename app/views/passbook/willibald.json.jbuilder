# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [255, 255, 255],
    foreground: [0, 0, 0],
    label: [0, 102, 51]
  }
)
