namespace :members do
  desc 'update member information from CSV file'
  task :update_from_csv, [:path] => [:environment] do |_, args|
    require 'csv'

    ActiveRecord::Base.transaction do
      CSV.foreach(args[:path], col_sep: ';', headers: true)
         .with_index(1) do |row, i|
        attrs = row.to_hash.symbolize_keys

        members = Members::Member.where(attrs.slice(:first_name, :last_name))
        if members.count > 1
          puts "Multiple members found for row #{i}"
          next
        end

        member = members.first
        if member.blank?
          puts "No member found for row #{i}"
          next
        end

        member.assign_attributes(attrs.slice(:street, :plz, :city, :phone))

        %i[birthday joined_at].each do |attr_name|
          next if attrs[attr_name].blank?

          member[attr_name] = Date.strptime(attrs[attr_name], '%m/%d/%y')
        end

        puts "Member #{member.name.sorted} updated." if member.save
      end
    end
  end
end
