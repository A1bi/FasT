# frozen_string_literal: true

namespace :one_off do
  task run: :environment do
    Ticketing::Seating.find_each do |seating|
      attachment = ActiveStorage::Attachment.find_by(
        record_type: seating.class.name, record_id: seating.id
      )
      next if attachment.blank?

      seating.update(
        plan: StringIO.new(attachment.blob.download),
        plan_file_name: 'seating.svg'
      )
    end
  end
end
