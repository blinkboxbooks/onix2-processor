module Blinkbox::Onix2Processor
  class EpubType < Processor
    handles_xpath '/onixmessage/product/epubtype'
    
    def up(node, state)
      state['book']['format'] ||= {}
    end

    def process(node, state) 
      if %w{#text #cdata-section}.include?(node.name)
        state['book']['format']['marvinIncompatible'] = !%w(029 023 000 099).include?(node.value)
        state['book']['format']['epubType'] = node.value
      end
    end
  end
end