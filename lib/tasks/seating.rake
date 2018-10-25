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

    File.open(path, 'w') { |f| f.write(svg.to_xml) }
  end

  def confirm(message)
    puts message + ' [yn]'
    return true if STDIN.gets.strip == 'y'
    raise ActiveRecord::Rollback
  end

  desc 'adds numbers in order of elements to seats'
  task :add_numbers, [:path] do |_task, args|
    svg = svg_file(args[:path])

    num_seats = 0

    svg.css('.block').each do |block|
      block.css('> g').add_class('seat').each_with_index do |seat, i|
        num_seats += 1
        number = i + 1
        seat['data-number'] = number

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
      next if seat['data-row'].present?

      # is this the first seat without a row already set ?
      if first_seat_index.nil?
        first_seat_index = i
        # use its row as base row for the following rows
        previous_row = seat.previous_element['data-row'].to_i if seat.previous_element.present?
      end

      row = previous_row + (i - first_seat_index) / seats_per_row + 1
      break if last_row > -1 && row > last_row

      seat['data-row'] = row
      seat.css('text').first.content = row
    end

    write_svg_file(svg, args[:path])
  end

  desc 'imports seating plan to create corresponding records'
  task :import, [:path] => :environment do |_task, args|
    svg = svg_file(args[:path])

    ActiveRecord::Base.transaction do
      if svg.root['data-id'].blank?
        confirm('Seating does not exist yet. Do you want to create it?')
        seating = Ticketing::Seating.create
        svg.root['data-id'] = seating.id
        puts "Seating with id=#{seating.id} created."

      else
        id = svg.root['data-id']
        seating = Ticketing::Seating.find_by(id: id)
        abort "Seating with id=#{id} not found." unless seating
      end

      svg.css('.block').each do |element|
        id = element['data-id']
        title = element.css('title').first.content

        if id.present?
          block = Ticketing::Block.find_by(id: id)
          abort "Block '#{title}' with id=#{id} not found." unless block
          block.name = title
          block.save
          puts "Block '#{title}' changed: #{block.saved_changes}" if block.saved_changes?

        else
          confirm("Block '#{title}' does not exist yet. Do you want to create it?")
          block = seating.blocks.create(name: title)
          element['data-id'] = block.id
          puts "Block with id=#{block.id} created."
        end

        seats = []

        element.css('.seat').each do |seat_element|
          id = seat_element['data-id']
          number = seat_element['data-number']
          row = seat_element['data-row']

          if id.present?
            seat = Ticketing::Seat.find_by(id: id)
            abort "Seat '#{number}' in Block '#{block.name}' with id=#{id} not found." unless seat
            seat.block = block
            seat.row = row
            seat.number = number
            seat.save
            puts "Seat '#{number}' in Block '#{block.name}' changed: #{seat.saved_changes}" if seat.saved_changes?

          else
            # confirm("Seat '#{number}' in Block '#{block.name}' does not exist yet. Do you want to create it?")
            seat = block.seats.create(row: row, number: number)
            seat_element['data-id'] = seat.id
            puts "Seat '#{number}' in Block '#{block.name}' with id=#{seat.id} created."
          end

          seats << seat
        end

        next if block.new_record?
        block.seats.where.not(id: seats.map(&:id)).each do |seat|
          confirm("Seat '#{seat.number}' in Block '#{block.name}' with id=#{seat.id} is missing. Do you want to remove it?")
          seat.destroy
        end
      end

      seating.plan.attach(io: StringIO.new(svg.to_xml), filename: 'seating.svg')

      write_svg_file(svg, args[:path])
    end
  end
end
