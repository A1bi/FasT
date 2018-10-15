class AddSlugToTicketingEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :ticketing_events, :slug, :string
    add_index :ticketing_events, :slug
    add_index :ticketing_events, :identifier

    reversible do |dir|
      dir.up do
        mapping = {
          don_camillo: 'don-camillo-und-peppone',
          alte_dame: 'der-besuch-der-alten-dame',
          magdalena: 'magdalena-himmelstürmerin',
          sommernachtstraum: 'ein-sommernachtstraum',
          drachenjungfrau: 'die-drachenjungfrau',
          alice_wunderland: 'alice-im-wunderland',
          willibald: 'der-überaus-starke-willibald'
        }

        Ticketing::Event.find_each do |event|
          slug = mapping.fetch(event.identifier.to_sym, event.identifier)
          event.update(slug: slug)
        end
      end
    end
  end
end
