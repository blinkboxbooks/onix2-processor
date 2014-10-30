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

      title = @identifier['titleofseries']
      state['book']['series']['title'] = title unless title.nil? || title.empty?
      number = @identifier['numberwithinseries'].to_i
      state['book']['series']['number'] = number unless number == 0
    end
  end
end