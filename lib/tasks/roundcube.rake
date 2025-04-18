# frozen_string_literal: true

namespace :roundcube do
  desc 'migrate contacts data'
  task migrate_contacts: :environment do
    require 'mysql2'

    puts 'Password for user \'roundcube\':'
    password = $stdin.gets.chomp

    puts 'Roundcube user_id:'
    user_id = $stdin.gets.chomp

    client = Mysql2::Client.new(
      host: 'fd00::1',
      username: 'roundcube',
      password:,
      database: 'roundcube'
    )

    Members::Member.find_each do |member|
      puts "Looking for matching contact for member with id #{member.id}."

      # find existing contact with matching email address
      query = <<~SQL.squish
        SELECT contact_id
          FROM contacts
         WHERE email = ?
           AND user_id = ?
           AND del = 0
      SQL

      statement = client.prepare(query)
      contacts = statement.execute(member.email, user_id, symbolize_keys: true)

      contacts.each do |contact|
        puts "Migrating existing contact with id #{contact[:contact_id]}"

        query = <<~SQL.squish
          SELECT contactgroup_id
            FROM contactgroupmembers
           WHERE contact_id = ?
        SQL

        statement = client.prepare(query)
        memberships = statement.execute(contact[:contact_id],
                                        symbolize_keys: true)

        memberships.each do |membership|
          # replace all references in groups with a fast_* id
          query = <<~SQL.squish
            UPDATE contactgroupmembers
               SET contact_id = ?
             WHERE contact_id = ?
               AND contactgroup_id = ?
          SQL

          statement = client.prepare(query)
          statement.execute("fast_#{member.id}", contact[:contact_id].to_s,
                            membership[:contactgroup_id])
        rescue Mysql2::Error
          # remove if this results in doubles
          puts 'Removing double'

          query = <<~SQL.squish
            DELETE FROM contactgroupmembers
                  WHERE contact_id = ?
                    AND contactgroup_id = ?
          SQL

          statement = client.prepare(query)
          statement.execute(contact[:contact_id].to_s,
                            membership[:contactgroup_id])
        end

        puts 'Removing existing contact.'

        # remove old contact
        query = <<~SQL.squish
          DELETE FROM contacts
                WHERE contact_id = ?
        SQL

        statement = client.prepare(query)
        statement.execute(contact[:contact_id])
      end
    end

    puts 'Finished!'
  end
end
