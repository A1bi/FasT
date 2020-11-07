# frozen_string_literal: true

module Paperclip
  class SeatingPlanStripper < Processor
    def make
      create_stripped_plan
      xml_file
    end

    private

    def create_stripped_plan
      # nokogiri does not seem to support removal of namespaces
      xml.sub!(/xmlns:bx=".+?"/, '')
      # remove titles
      xml.gsub!(%r{<title>.+?</title>}i, '')
      # remove whitespace
      xml.gsub!(/([>\n\r])\s+([<\n\r])/i, '\1\2')
    end

    def xml
      @xml ||= begin
        svg = Nokogiri::XML(@file)

        svg.xpath('//bx:*').remove
        svg.xpath('//*/@bx:*').remove
        svg.xpath('//title').remove

        svg.to_xml
      end
    end

    def xml_file
      basename = File.basename(@file.path)
      file = TempfileFactory.new.generate(basename)
      file.write xml
      file
    end
  end
end
