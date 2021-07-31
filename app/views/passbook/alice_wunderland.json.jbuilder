# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  colors: {
    background: [255, 255, 255],
    foreground: [240, 127, 60],
    label: [240, 127, 60]
  }
)
