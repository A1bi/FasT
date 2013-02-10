namespace :gallery do
	desc "Import gallery data including images from old site"
	task :import_old => :environment do
		require "mysql2"
		
		puts "Mysql password for user 'theater'"
		password = $stdin.gets.chomp
		
		client = Mysql2::Client.new(
			:host => "85.214.76.70",
			:username => "theater",
			:password => password,
			:database => "theater"
		)
		
		results = client.query("SELECT * FROM gallery ORDER BY pos")
		results.each(:symbolize_keys => true) do |gallery|
			
			puts "Importing '#{gallery[:title]}'"
			puts "Do you want to import this gallery? [y|n|a=skip all]"
			yes = $stdin.gets.chomp
			break if yes == "a"
			next unless yes == "y"
			
			new_gallery = Gallery.new({
				:title => gallery[:title], :disclaimer => gallery[:copyright], :position => gallery[:pos]
			})
			new_gallery.save
			
			images = client.query("SELECT * FROM gallery_pics WHERE gallery = '#{gallery[:id]}' ORDER BY pos")
			i = 0
			images.each(:symbolize_keys => true) do |image|
				puts "\t importing image #{i+1} of #{images.count}"
				raw_image = File.new("/var/kunden/webs/Jedermann/main/gfx/cache/gallery/#{gallery[:id]}/full/#{image[:id]}")
				new_gallery.photos.new({:text => image[:text], :position => image[:pos], :image => raw_image}).save
				
				i = i+1
			end
			
		end
		
		puts "Finished!"
	end
end