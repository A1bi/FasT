Config.setup do |config|
  # Name of the constant exposing loaded settings
  config.const_name = 'Settings'

  # Ability to remove elements of the array set in earlier loaded settings file. For example value: '--'.
  #
  # config.knockout_prefix = nil

  # Overwrite an existing value when merging a `nil` value.
  # When set to `false`, the existing value is retained after merge.
  #
  # config.merge_nil_values = true

  # Overwrite arrays found in previously loaded settings file. When set to `false`, arrays will be merged.
  #
  # config.overwrite_arrays = true

  # Load environment variables from the `ENV` object and override any settings defined in files.
  #
  # config.use_env = false

  # Define ENV variable prefix deciding which variables to load into config.
  #
  # config.env_prefix = 'Settings'

  # What string to use as level separator for settings loaded from ENV variables. Default value of '.' works well
  # with Heroku, but you might want to change it for example for '__' to easy override settings from command line, where
  # using dots in variable names might not be allowed (eg. Bash).
  #
  # config.env_separator = '.'

  # Ability to process variables names:
  #   * nil  - no change
  #   * :downcase - convert to lower case
  #
  # config.env_converter = :downcase

  # Parse numeric values as integers instead of strings.
  #
  # config.env_parse_values = true

  # Validate presence and type of specific config values. Check https://github.com/dry-rb/dry-validation for details.
  #
  config.schema do
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
  end

end
