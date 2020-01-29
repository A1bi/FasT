module NameOfPerson
  module AssignableName
    def name
      title = try(:title)
      NameOfPerson::PersonNameWithTitle.new(first_name, last_name, title) if first_name
    end
  end
end
