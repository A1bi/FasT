# frozen_string_literal: true

module Ticketing
  module SeatingSvg
    class Base
      def initialize(path:)
        @path = path
      end

      private

      def svg
        @svg ||= begin
          raise 'SVG file not found' unless File.exist?(@path)

          File.open(@path) { |f| Nokogiri::XML(f) }
        end
      end

      def block_elements
        svg.css('.block')
      end

      def save_svg
        # create a backup
        ext = File.extname(@path)
        backup_path = "#{File.dirname(@path)}/#{File.basename(@path, ext)}" \
                   "_original#{ext}"
        FileUtils.copy_file(@path, backup_path)

        File.open(@path, 'w') { |f| f.write(svg.to_xml) }
      end
    end
  end
end
