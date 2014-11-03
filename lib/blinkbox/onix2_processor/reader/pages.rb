module Blinkbox::Onix2Processor
  class Pages < Processor
    handles_xpath '/onixmessage/product/numberofpages'

    def up(node, state)
      state['book']['statistics'] ||= {}
    end

    def process(node, state)
      if %w{#text #cdata-section}.include?(node.name)
        return product_failure(state, "InvalidNumberOfPages", number: node.value) unless node.value.match(/^\d+$/)
        state['book']['statistics']['pages'] = node.value.to_i
      end
    end
  end
end