path = Rails.root.join('lib', 'extensions', '**', '*.rb')

Dir.glob(path).each do |filename|
  require filename
end
