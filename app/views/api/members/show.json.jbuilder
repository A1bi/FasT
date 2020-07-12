# frozen_string_literal: true

json.array! [@member] do |member|
  json.call(member, :id, :email, :first_name, :last_name, :title,
            :phone, :street, :plz, :city, :birthday)
end
