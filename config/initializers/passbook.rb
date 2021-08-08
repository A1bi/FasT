# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  Passbook.configure do |config|
    config.destination_path = Settings.passbook.destination_path
    config.wwdr_ca_path = Settings.passbook.wwdr_ca_path

    Settings.passbook.models.each do |model|
      config.register_model(model[:name], **model.to_h.except(:name))
    end
  end
end
