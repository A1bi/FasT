# frozen_string_literal: true

Rails.application.config.to_prepare do
  Passbook.options = Settings.passbook
end
