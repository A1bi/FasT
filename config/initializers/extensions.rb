path = Rails.root.join('lib/extensions/**/*.rb')

Rails.autoloaders.main.ignore(path)

Dir.glob(path).sort.each do |filename|
  require filename
end
