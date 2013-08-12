class ChangePassbookPasses < ActiveRecord::Migration
  def change
    add_column :passbook_passes, :assignable_id, :integer
    add_column :passbook_passes, :assignable_type, :string
    rename_column :passbook_passes, :path, :filename
  end

  def migrate(direction)
    super
    if direction == :up
      ActiveRecord::Base.record_timestamps = false
      Passbook::Records::Pass.all.each do |pass|
        pass.filename = File.basename(pass.filename)
        pass.assignable = Ticketing::Ticket.where(number: pass.serial_number).first
        pass.save
      end
      ActiveRecord::Base.record_timestamps = true
    end
  end
end
