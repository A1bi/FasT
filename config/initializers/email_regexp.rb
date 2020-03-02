# frozen_string_literal: true

# replacement for URI::MailTo::EMAIL_REGEXP which doesn't allow
# non-ascii domains (e.g. Umlaute)
FasT::EMAIL_REGEXP = /\A[^@\s]+@[^@\s]+\z/.freeze
FasT::EMAIL_REGEXP_JS = '^[^@\s]+@[^@\s]+$'
