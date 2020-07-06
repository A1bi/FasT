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
    return if params[:comment].blank?

    redirect_to root_path
  end
end
