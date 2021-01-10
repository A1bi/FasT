# frozen_string_literal: true

module Anonymizable
  extend ActiveSupport::Concern

  class_methods do
    def is_anonymizable(columns:) # rubocop:disable Naming/PredicateName
      @@anonymizable_columns = columns # rubocop:disable Style/ClassVars
    end
  end

  def anonymize!
    return if anonymized?

    @@anonymizable_columns.each do |column|
      self[column] = nil
    end
    self.anonymized_at = Time.current
    save
  end

  def anonymized?
    anonymized_at.present?
  end
end
