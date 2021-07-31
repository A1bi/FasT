# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [47, 61, 131],
    foreground: [255, 255, 255],
    label: [177, 203, 34]
  }
)
