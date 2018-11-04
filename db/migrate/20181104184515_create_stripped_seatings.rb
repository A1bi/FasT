class CreateStrippedSeatings < ActiveRecord::Migration[5.2]
  def up
    Ticketing::Seating.all.each(&:save)
  end
end
