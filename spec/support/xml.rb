# frozen_string_literal: true

RSpec::Matchers.define :have_xml do |xpath, text|
  match do |actual|
    doc = Nokogiri::XML(actual)
    doc.remove_namespaces!
    nodes = doc.xpath(xpath)

    expect(nodes).not_to be_empty

    if text
      nodes.each do |node|
        if text.is_a?(Regexp)
          expect(node.content).to match(text)
        else
          expect(node.content).to eq(text)
        end
      end
    end

    true
  end
end
