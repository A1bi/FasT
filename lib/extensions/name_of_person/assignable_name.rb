# frozen_string_literal: true

module NameOfPerson
  module AssignableName
    def name
      title = try(:title)
      return if first_name.blank?

      NameOfPerson::PersonNameWithTitle.new(first_name, last_name, title)
    end
  end
end
