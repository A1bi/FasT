# frozen_string_literal: true

namespace :seating do
  desc 'adds numbers in order of elements to seats'
  task :add_seat_numbers, [:path] => :environment do |_task, args|
    num_seats = Ticketing::SeatingSvg::Modifier.new(path: args[:path])
                                               .add_seat_numbers
    puts "Added numbers to #{num_seats} seats."
  end

  desc 'adds rows to seats, starts with the last seat without a row until ' \
       'the specified last row'
  task :add_row_numbers, %i[path block_index seats_per_row last_row] =>
       :environment do |_task, args|
    Ticketing::SeatingSvg::Modifier.new(path: args[:path]).add_row_numbers(
      block_index: args[:block_index].to_i,
      seats_per_row: args[:seats_per_row].to_i,
      last_row: args[:last_row].to_i
    )
  end

  desc 'remove all row information'
  task :strip_row_numbers, [:path] => :environment do |_task, args|
    Ticketing::SeatingSvg::Modifier.new(path: args[:path]).strip_row_numbers
  end

  desc 'remove all IDs of persisted records'
  task :strip_ids, [:path] => :environment do |_task, args|
    Ticketing::SeatingSvg::Modifier.new(path: args[:path]).strip_ids
  end

  desc 'imports seating plan to create corresponding records'
  task :import, [:path] => :environment do |_task, args|
    Ticketing::SeatingSvg::Importer.new(path: args[:path])
                                   .import(name: 'Import')
  end
end
