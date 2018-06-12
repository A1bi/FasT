class AddUnderlayToTicketingSeatings < ActiveRecord::Migration[5.2]
  def change
    add_column :ticketing_seatings, :underlay_filename, :string

    Ticketing::Seating.where(number_of_seats: 0).update_all(underlay_filename: 'seating_underlay.png')
  end
end
