module Blinkbox::Onix2Processor
  class Publisher < Processor
    handles_xpath '/onixmessage/product/publisher'

    def up(node, state)
      @identifier = {}
    end

    def process(node, state)
      container = normalize_tags(node.position).last
      @identifier[container] = node.value if %w{#text #cdata-section}.include?(node.name)
    end

    def down(node, state)
      # We're only looking for the publisher name
      if ['01', nil].include?(@identifier['publishingrole'])
        state['book']['publisher'] = @identifier['publishername']
      end
    end
  end

  class Imprint < Processor
    handles_xpath '/onixmessage/product/imprint'

    def up(node, state)
      @identifier = {}
    end

    def process(node, state)
      container = normalize_tags(node.position).last
      @identifier[container] = node.value if %w{#text #cdata-section}.include?(node.name)
    end

    def down(node, state)
      state['book']['imprint'] ||= @identifier['imprintname'] unless @identifier['imprintname'].nil?
    end
  end
end