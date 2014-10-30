module Blinkbox::Onix2Processor
  class Product < Processor
    handles_xpath '/onixmessage/product'

    def up(node, state)
      state['book'] = {
        'contributors' => [],
        'descriptions' => []
      }
      state[:product_failures] = []
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
        contributor = book['contributors'].first

        biog = (book['descriptions'] || []).select { |d|
          d['type'] == "13"
        }.first
        if !biog.nil? && contributor['biography'].nil?
          contributor['biography'] = biog['content']
          book['descriptions'].delete(biog)
        end

        images = book['media']['images'] || [] rescue []
        contributor_profile = images.select { |i|
          i['classification'] == [{"realm"=>"type", "id"=>"contributors"}]
        }.first
        if !contributor_profile.nil?
          contributor['media'] ||= {}
          contributor['media']['images'] ||= []
          media = contributor_profile.dup
          # The type classification is "profile" when in a contributor, and "contributors" when in book.
          media['classification'].first['id'] = "profile"
          contributor['media']['images'].push(media)
        end
      end

      state[:product_failures].each { |f| f[:isbn] = book['isbn'] } if book['isbn']
      state[:failures].push(*state[:product_failures])
      state[:on_book_metadata_complete].call(book)

      state['book'] = {}
    end
  end
end