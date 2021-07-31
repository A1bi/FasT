# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [227, 216, 204],
    foreground: [23, 87, 43],
    label: [0, 0, 0]
  }
)
