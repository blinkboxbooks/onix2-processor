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
      state['book']['isbn'] = @identifier['idvalue'] if %w{15 03}.include? @identifier['productidtype']
    end
  end

  class Ean13 < Processor
    handles_xpath '/onixmessage/product/ean13'

    def process(node, state)
      state['book']['isbn'] = node.value if %w{#text #cdata-section}.include?(node.name)
    end
  end

  class RelatedProduct < Processor
    handles_xpath '/onixmessage/product/relatedproduct'

    def up(node, state)
      @identifier = {}
    end

    def process(node, state)
      container = normalize_tags(node.position).last
      @identifier[container] = node.value if %w{#text #cdata-section}.include?(node.name)
    end

    def down(node, state)
      if %w{15 03}.include? @identifier['productidtype']
        isbn = @identifier['idvalue']

        return product_failure(state, "InvalidRelatedISBN", isbn: isbn) if (isbn.nil? || !isbn.match(/^97(?:80|81|9\d)\d{9}$/))
        return product_failure(state, "InvalidRelationCode", code: @identifier['relationcode']) if (@identifier['relationcode'].nil? || !@identifier['relationcode'].match(/^\d{2}$/))
        
        (state['book']['related'] ||= []).push(
          "classification" => [{
            "realm" => "isbn",
            "id" => isbn
          }],
          "relation" => @identifier['relationcode'],
          "isbn" => isbn
        )
      end
    end
  end
end