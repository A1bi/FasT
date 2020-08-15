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
    end

    required(:passbook).schema do
      required(:path).filled
      required(:wwdr_ca_path).filled
      required(:certificate_paths).filled
      required(:pass_type_ids).filled
    end

    required(:apns).schema do
      required(:team_id).filled
      required(:topics)
    end

    required(:ticket_barcode_base_url).filled

    required(:shared_email_accounts).schema do
      required(:redirect_url).filled
    end
  end
end
