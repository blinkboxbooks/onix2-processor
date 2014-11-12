module Blinkbox::Onix2Processor
  class EpubType < Processor
    handles_xpath '/onixmessage/product/epubtype'
    
    def up(node, state)
      state['book']['format'] ||= {}
    end

    def process(node, state) 
      if %w{#text #cdata-section}.include?(node.name)
        previously_incompatible = state['book']['format']['marvinIncompatible'] || false
        is_incompatible = !%w(029 023 000 099).include?(node.value)
        state['book']['format']['marvinIncompatible'] = is_incompatible || previously_incompatible
        state['book']['format']['epubType'] = node.value
      end
    end
  end

  class ProductType < Processor
    handles_xpath '/onixmessage/product/productform'
    
    def up(node, state)
      state['book']['format'] ||= {}
    end

    def process(node, state) 
      if %w{#text #cdata-section}.include?(node.name) && node.value != "00"
        previously_incompatible = state['book']['format']['marvinIncompatible'] || false
        is_incompatible = (node.value != "DG")
        state['book']['format']['marvinIncompatible'] = is_incompatible || previously_incompatible
        state['book']['format']['productForm'] = node.value
      end
    end
  end
end