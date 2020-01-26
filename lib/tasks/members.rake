namespace :members do
  desc 'import sepa mandates from CSV file'
  task :import_mandates_from_csv, [:path] => [:environment] do |_, args|
    require 'csv'

    ActiveRecord::Base.transaction do
      CSV.foreach(args[:path], col_sep: ';', headers: true)
         .with_index(1) do |row, i|
        attrs = row.to_hash.symbolize_keys

        debtor = attrs[:debtor_name]
        names = debtor.split(', ')
        members = Members::Member.where(last_name: names[0], first_name: names[1])
        if members.count > 1
          puts "⚠️ Multiple members found for #{debtor}"
          next
        end

        member = members.first
        if member.blank?
          puts "❌ No member found for #{debtor}"
          next
        end

        if member.sepa_mandate.present?
          puts "⚠️ SEPA mandate already exists for #{debtor}"
          next
        end

        mandate = Members::SepaMandate.find_by(attrs.slice(:iban))
        if mandate.present?
          puts "✅ Using existing SEPA mandate #{mandate.number} for #{debtor}"

        else
          puts "✅ Creating new SEPA mandate for #{debtor}"
          mandate = member.build_sepa_mandate(
            attrs.slice(:number, :issued_on, :debtor_name, :iban)
          )
        end

        unless member.update(sepa_mandate: mandate)
          puts "❌ SEPA mandate could not be set for #{debtor}"
        end
      end
    end
  end
end
