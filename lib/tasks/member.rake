namespace :member do
  desc "Import members from CSV file"
  task :import_csv, [:filepath] => [:environment] do |t, args|
    require "csv"

    i = 0
    CSV.foreach(args[:filepath], :headers => true, :col_sep => ";") do |row|
      attrs = row.to_hash
      member = Member.new attrs, :without_protection => true
      member.group = :member
      member.birthday = Date.strptime(attrs['birthday'], "%m/%d/%Y") if attrs['birthday'].present?
      member.reset_password
      i = i+1 if member.save(:validate => false)
    end

    puts "Imported #{i} members."
  end

  desc "Send activation mail to all unactivated members"
  task :send_activation_mails => :environment do
    i = 0
    Member.where("activation_code != ''").find_each do |member|
      i = i+1 if member.send_activation_mail
    end

    puts "Sent #{i} activation mails."
  end
end
