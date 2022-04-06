# frozen_string_literal: true

path = Rails.root.join('lib/extensions/**/*.rb')

Rails.autoloaders.main.ignore(path)

Dir.glob(path).each do |filename|
  require filename
end
