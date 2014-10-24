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
      state['book'].merge!(
        '$schema' => "ingestion.book.metadata.v2",
        'classification' => [
          {
            "realm" => "isbn",
            "id" => state['book']['isbn'] || ""
          },
          {
            "realm" => "source_username",
            "id" => state[:source]["username"]
          }
        ],
        'source' => state[:source]
      )
      state[:on_book_metadata_complete].call(state['book'])

      state['book'] = {}
    end
  end
end