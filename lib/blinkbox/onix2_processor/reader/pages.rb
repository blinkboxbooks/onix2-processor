module Blinkbox::Onix2Processor
  class Pages < Processor
    handles_xpath '/onixmessage/product/numberofpages'

    def up(node, state)
      state['book']['statistics'] ||= {}
    end

    def process(node, state)
      state['book']['statistics']['pages'] = node.value.to_i if %w{#text #cdata-section}.include?(node.name)
    end
  end
end