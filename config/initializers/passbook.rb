Rails.application.config.to_prepare do
  Passbook.options = Settings.passbook
end
