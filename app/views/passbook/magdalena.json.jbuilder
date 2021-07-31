# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [92, 119, 147],
    foreground: [0, 0, 0],
    label: [255, 255, 255]
  }
)
