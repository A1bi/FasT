# frozen_string_literal: true

module HasGender
  extend ActiveSupport::Concern

  included do
    enum gender: %i[female male diverse]
  end
end
