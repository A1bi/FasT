# frozen_string_literal: true

class FixPassbookSignedInfoMedium < ActiveRecord::Migration[6.0]
  def up
    Passbook::Models::Pass.where('created_at > ?', Time.zone.parse('2018-06-01')).find_each do |pass|
      pass.touch
      pass.push
    end
  end
end
