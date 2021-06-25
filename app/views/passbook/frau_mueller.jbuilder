# frozen_string_literal: true

json.partial!(
  'passbook/template',
  ticket: ticket,
  location: [50.23089, 7.141626],
  location_label: 'Historischer Ortskern',
  location_address: 'Burgstraße, 56759 Kaisersesch'
)
