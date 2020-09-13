# frozen_string_literal: true

require 'nokogiri'

namespace :seating do
  def svg_file(path)
    abort 'SVG file not found.' unless File.exist?(path)
    File.open(path) { |f| Nokogiri::XML(f) }
  end

  def write_svg_file(svg, path)
    # create a backup
    ext = File.extname(path)
    dup_path = "#{File.dirname(path)}/#{File.basename(path, ext)}" \
               "_original#{ext}"
    FileUtils.copy_file(path, dup_path)

    File.open(path, 'w') { |f| f.write(svg.to_xml) }
  end

  def remove_all_attributes(svg, attr_name)
    svg.xpath("//*[@#{attr_name}]").remove_attr(attr_name)
  end

  desc 'adds numbers in order of elements to seats'
  task :add_numbers, [:path] do |_task, args| # rubocop:disable Rails/RakeEnvironment
    svg = svg_file(args[:path])

    num_seats = svg.css('.block').inject(0) do |i, block|
      i + block.css('> g:not(.shield)').inject(0) do |j, seat|
        next j unless (text = seat.css('text').first)

        seat.add_class('seat')
        seat['data-number'] = text.content = j + 1
      end
    end

    puts "Added numbers to #{num_seats} seats."

    write_svg_file(svg, args[:path])
  end

  desc 'adds rows to seats, starts with the last seat without a row until ' \
       'the specified last row'
  task :add_rows, %i[path block_index seats_per_row last_row] do |_task, args| # rubocop:disable Rails/RakeEnvironment
    svg = svg_file(args[:path])

    block = svg.css('.block')[args[:block_index].to_i]
    puts "Adding rows to #{block.css('title').first.content}"

    seats_per_row = args[:seats_per_row].to_i
    last_row = args[:last_row].to_i
    first_seat_index = nil
    previous_row = 0

    block.css('g').each_with_index do |seat, i|
      next if seat['data-row'].present?

      # is this the first seat without a row already set ?
      if first_seat_index.nil?
        first_seat_index = i
        # use its row as base row for the following rows
        if seat.previous_element.present?
          previous_row = seat.previous_element['data-row'].to_i
        end
      end

      row = previous_row + (i - first_seat_index) / seats_per_row + 1
      break if last_row > -1 && row > last_row

      seat['data-row'] = row
      seat.css('text').first.content = row
    end

    write_svg_file(svg, args[:path])
  end

  desc 'remove all row information'
  task :strip_rows, [:path] do |_task, args| # rubocop:disable Rails/RakeEnvironment
    svg = svg_file(args[:path])

    remove_all_attributes(svg, 'data-row')

    write_svg_file(svg, args[:path])
  end

  desc 'remove all IDs of persisted records'
  task :strip_ids, [:path] do |_task, args| # rubocop:disable Rails/RakeEnvironment
    svg = svg_file(args[:path])

    remove_all_attributes(svg, 'data-id')

    write_svg_file(svg, args[:path])
  end

  desc 'imports seating plan to create corresponding records'
  task :import, [:path] => :environment do |_task, args|
    path = args[:path]

    Ticketing::SeatingSvgImporter.new(path: path, name: 'Import').import
  end
end
