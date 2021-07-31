# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [0, 0, 0],
    foreground: [255, 247, 178],
    label: [209, 10, 17]
  }
)
