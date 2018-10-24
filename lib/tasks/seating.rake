require 'nokogiri'

namespace :seating do
  def svg_file(path)
    abort 'SVG file not found.' unless File.exist?(path)
    File.open(path) { |f| Nokogiri::XML(f) }
  end

  def write_svg_file(svg, path)
    # create a backup
    ext = File.extname(path)
    dup_path = File.dirname(path) + '/' + File.basename(path, ext) + '_original' + ext
    FileUtils.copy_file(path, dup_path)

    # add namespace
    if svg.namespaces['fast'].blank?
      svg.root.add_namespace('fast', 'https://www.theater-kaisersesch.de')
    end

    File.open(path, 'w') { |f| f.write(svg.to_xml) }
  end

  desc 'adds numbers in order of elements to seats'
  task :add_numbers, [:path] do |_task, args|
    svg = svg_file(args[:path])

    num_seats = 0

    svg.css('.block').each do |block|
      block.css('> g').each_with_index do |seat, i|
        num_seats += 1
        number = i + 1
        seat['fast:seat'] = nil
        seat['fast:number'] = number

        seat.css('text').first.content = number
      end
    end

    puts "Added numbers to #{num_seats} seats."

    write_svg_file(svg, args[:path])
  end

  desc 'adds rows to seats, starts with the last seat without a row until the specified last row'
  task :add_rows, [:path, :block_index, :seats_per_row, :last_row] do |_task, args|
    svg = svg_file(args[:path])

    block = svg.css('.block')[args[:block_index].to_i]
    puts "Adding rows to #{block.css('title').first.content}"

    seats_per_row = args[:seats_per_row].to_i
    last_row = args[:last_row].to_i
    first_seat_index = nil
    previous_row = 0

    block.css('g').each_with_index do |seat, i|
      next if seat['fast:row'].present?

      # is this the first seat without a row already set ?
      if first_seat_index.nil?
        first_seat_index = i
        # use its row as base row for the following rows
        previous_row = seat.previous_element['fast:row'].to_i if seat.previous_element.present?
      end

      row = previous_row + (i - first_seat_index) / seats_per_row + 1
      break if last_row > -1 && row > last_row

      seat['fast:row'] = row
      seat.css('text').first.content = row
    end

    write_svg_file(svg, args[:path])
  end
end
