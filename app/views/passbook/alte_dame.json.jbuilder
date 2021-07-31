# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [237, 223, 2],
    foreground: [0, 0, 0],
    label: [230, 0, 126]
  }
)
