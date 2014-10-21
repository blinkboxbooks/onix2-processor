module Blinkbox::Onix2Processor
  class Product < Processor
    handles_xpath '/onixmessage/product'

    def up(node, state)
      state['book'] = {
        'contributors' => []
      }
    end

    def process(node, state); end

    def down(node, state)
      state[:on_book_metadata_complete].call(state['book'])

      state['book'] = {}
    end
  end
end