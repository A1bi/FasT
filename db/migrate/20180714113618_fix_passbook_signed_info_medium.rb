class FixPassbookSignedInfoMedium < ActiveRecord::Migration[5.2]
  def up
    Passbook::Models::Pass.where('created_at > ?', Time.parse('2018-06-01')).find_each do |pass|
      pass.touch
      pass.push
    end
  end
end
