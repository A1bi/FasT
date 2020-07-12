# frozen_string_literal: true

json.cache_if! cache?, [:api, :members, :index, @members] do
  json.array! @members, :id, :email, :first_name, :last_name, :title
end
