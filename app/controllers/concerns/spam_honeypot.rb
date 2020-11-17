# frozen_string_literal: true

module SpamHoneypot
  extend ActiveSupport::Concern

  class_methods do
    def filters_spam_through_honeypot(options = {})
      before_action :filter_spam, options
    end
  end

  private

  def filter_spam
    # blank? will ignore newline control characters
    return if params[:comment]&.length&.zero?

    redirect_to root_path
  end
end
