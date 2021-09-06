# frozen_string_literal: true

module SpamFiltering
  extend ActiveSupport::Concern

  SPAM_PARAM_PATTERN = %r{https?://}.freeze

  class_methods do
    def filters_spam_through_honeypot(options = {})
      before_action :filter_honeypot_spam, options
    end

    def filters_spam_in_param(param_proc, options = {})
      before_action -> { filter_spam_in_param(param_proc) }, options
    end
  end

  private

  def filter_honeypot_spam
    # blank? will ignore newline control characters
    return if params[:comment]&.length&.zero?

    redirect_to root_path
  end

  def filter_spam_in_param(param_proc)
    redirect_to root_path if param_proc.call(params)&.match?(SPAM_PARAM_PATTERN)
  end
end
