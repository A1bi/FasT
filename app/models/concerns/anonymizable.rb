# frozen_string_literal: true

module Anonymizable
  extend ActiveSupport::Concern

  class_methods do
    def is_anonymizable(columns:) # rubocop:disable Naming/PredicateName
      @anonymizable_columns = columns
    end

    def anonymizable_columns
      @anonymizable_columns || []
    end

    def unanonymized
      where(anonymized_at: nil)
    end
  end

  def anonymize!
    return if anonymized?

    self.class.anonymizable_columns.each do |column|
      self[column] = nil
    end
    self.anonymized_at = Time.current
    save
  end

  def anonymized?
    anonymized_at.present?
  end
end
