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
      title = @identifier['titleofseries']
      if !title.nil? && !title.empty?
        state['book']['series'] = {}
        state['book']['series']['title'] = title
        number = @identifier['numberwithinseries'].to_i
        state['book']['series']['number'] = number unless number == 0
      else
        state[:product_failures].push(
          error_code: "SeriesTitleMissing",
          data: {
            identifiers: @identifier
          }
        )
      end
    end
  end
end