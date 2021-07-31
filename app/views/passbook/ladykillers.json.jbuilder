# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [243, 241, 236],
    foreground: [204, 0, 58],
    label: [0, 0, 0]
  }
)
