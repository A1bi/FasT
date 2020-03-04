# frozen_string_literal: true

json.labels(@chart_dates.map.with_index do |date, index|
  format = (index % 7).zero? ? '%a %-d. %B' : '%a %-d.'
  l(date, format: format)
end)

json.datasets @chart_datasets do |order_type, data|
  json.label t(".labels.#{order_type.model_name.i18n_key}")
  json.data data.values
end
