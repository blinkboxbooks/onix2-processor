module Blinkbox::Onix2Processor
  class Series < Processor
    handles_xpath '/onixmessage/product/series'

    def up(node, state)
      @identifier = {}
    end

    def process(node, state)
      container = normalize_tags(node.position).last

      @identifier[container] = node.value if %w{#text #cdata-section}.include?(node.name)
    end

    def down(node, state)
      state['book']['series'] = {}

      state['book']['series']['title'] = @identifier['titleofseries']
      number = @identifier['numberwithinseries']
      state['book']['series']['number'] = @identifier['numberwithinseries'].to_i unless number.nil? || number.empty?
    end
  end
end