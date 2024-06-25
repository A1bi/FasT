# frozen_string_literal: true

Config.setup do |config|
  config.const_name = 'Settings'

  config.schema do
    required(:smtp).schema do
      required(:address).filled
      required(:port).filled(:integer)
    end

    required(:url_options).schema do
      required(:host).filled
      required(:protocol) { filled? & included_in?(%w[http https]) }
    end

    required(:members).schema do
      required(:default_membership_fee).filled(:integer)
      required(:membership_renewal_after_months).filled(:integer)
      required(:membership_fee_debit_submission_email).filled(:string)
      required(:membership_application_admin_notification_email).filled(:string)
      required(:embedded_calendar_token).filled(:string)
    end

    required(:ticketing).schema do
      required(:ticket_barcode_base_url).filled
      required(:target_bank_account).schema do
        required(:name).filled
        required(:iban).filled
        required(:creditor_identifier).filled
        required(:institution).filled
      end
    end

    required(:passbook).schema do
      required(:destination_path).filled
      required(:wwdr_ca_path).filled
      required(:models).array(:hash) do
        required(:name).filled
        required(:template).filled
        required(:pass_type_id).filled
        required(:certificate_path).filled
      end
    end

    required(:apns).schema do
      required(:team_id).filled
      required(:topics)
    end

    required(:shared_email_accounts).schema do
      required(:redirect_url).filled
    end

    required(:tse).schema do
      required(:enabled).filled(:bool)
      required(:host).maybe(:string)
      required(:port).maybe(:integer)
    end

    required(:wasserwerk).schema do
      required(:fake_api).filled(:bool)
    end

    required(:ebics).schema do
      required(:enabled).filled(:bool)
    end

    required(:stripe).schema do
      required(:enabled).filled(:bool)
    end
  end
end
