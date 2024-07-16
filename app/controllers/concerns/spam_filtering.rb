# frozen_string_literal: true

module SpamFiltering
  extend ActiveSupport::Concern

  SPAM_PARAM_PATTERN = %r{https?://}

  class_methods do
    def filters_spam_through_honeypot(options = {})
      before_action :filter_honeypot_spam, options
    end

    def filters_spam_in_param(param_proc, options = {})
      before_action -> { filter_spam_in_param(param_proc, options.slice(:max_length)) }, options.except(:max_length)
    end
  end

  private

  def filter_honeypot_spam
    # blank? will ignore newline control characters
    return if params[:comment] && params[:comment].empty?

    redirect_to root_path
  end

  def filter_spam_in_param(param_proc, options)
    value = param_proc.call(params)
    return if value.nil?

    redirect_to root_path if value.match?(SPAM_PARAM_PATTERN) ||
                             (options[:max_length] && value.size > options[:max_length])
  end
end
