module Blinkbox::Onix2Processor
  class Subtitle < Processor
    handles_xpath '/onixmessage/product/subtitle'
    handles_xpath '/onixmessage/product/title/subtitle'

    def process(node, state)
      state['book']['subtitle'] = node.value if %w{#text #cdata-section}.include?(node.name)
    end
  end
end