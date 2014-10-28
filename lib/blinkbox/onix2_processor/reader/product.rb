module Blinkbox::Onix2Processor
  class Product < Processor
    handles_xpath '/onixmessage/product'

    def up(node, state)
      state['book'] = {
        'contributors' => [],
        'descriptions' => []
      }
    end

    def process(node, state); end

    def down(node, state)
      book = state['book'].merge(
        '$schema' => "ingestion.book.metadata.v2",
        'classification' => [
          {
            "realm" => "isbn",
            "id" => state['book']['isbn'] || ""
          },
          {
            "realm" => "source_username",
            "id" => state[:source]["username"] || ""
          }
        ],
        'source' => state[:source]
      )

      # Pull biographical notes on books with sole contributors into the contributor
      if book['contributors'].size == 1
        biog = book['descriptions'].select { |d| d['type'] == "13" }.first
        if !biog.nil? && book['contributors'].first['biography'].nil?
          book['contributors'].first['biography'] = biog['content']
          book['descriptions'].delete(biog)
        end
      end

      state[:on_book_metadata_complete].call(book)

      state['book'] = {}
    end
  end
end