module Blinkbox::Onix2Processor
  class ProductIdentifier < Processor
    handles_xpath '/onixmessage/product/productidentifier'

    def up(node, state)
      @identifier = {}
    end

    def process(node, state)
      container = normalize_tags(node.position).last

      @identifier[container] = node.value if %w{#text #cdata-section}.include?(node.name)
    end

    def down(node, state)
      case @identifier['productidtype']
      when '15', '03'
        state['book']['isbn'] = @identifier['idvalue']
      end
    end
  end

  class Ean13 < Processor
    handles_xpath '/onixmessage/product/ean13'

    def process(node, state)
      state['book']['isbn'] = node.value if %w{#text #cdata-section}.include?(node.name)
    end
  end
end