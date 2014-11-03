module Blinkbox::Onix2Processor
  class Product < Processor
    handles_xpath '/onixmessage/product'

    def up(node, state)
      state['book'] = {
        'contributors' => []
      }
      state[:product_failures] = []
    end

    def process(node, state); end

    def down(node, state)
      enforce_isbn_rules!(state)
      composite_book!(state)
      enforce_contributor_sequence_numbers!(state)
      single_contributor_augmentations!(state)

      state[:product_failures].each { |f| f[:isbn] = state['book']['isbn'] }
      state[:failures].push(*state[:product_failures])
      state[:on_book_metadata_complete].call(state['book'])
    end

    private

    def enforce_isbn_rules!(state)
      if state['book']['isbn'].nil? || !state['book']['isbn'].match(/^97(?:80|81|9\d)\d{9}$/)
        product_failure(state, "InvalidISBN", isbn: state['book']['isbn'])
        state['book'].delete('isbn')
      end
    end

    def composite_book!(state)
      state['book'].merge!(
        '$schema' => "ingestion.book.metadata.v2",
        'classification' => [
          {
            "realm" => "isbn",
            "id" => state['book']['isbn'] || "unknown"
          },
          {
            "realm" => "source_username",
            "id" => state[:source]["username"] || "unknown"
          }
        ],
        'source' => state[:source]
      )
    end

    def enforce_contributor_sequence_numbers!(state)
      if state['book']['contributors'].size != 0
        n = 1
        seqs = state['book']['contributors'].map do |c|
          c['seq'] ||= n
          n = [n, c['seq']].max + 1
          c['seq']
        end
        product_failure(state, "IncorrectContributorSequenceNumbers", sequence_numbers: seqs) if seqs != (1..seqs.size).to_a
      end
    end

    def single_contributor_augmentations!(state)
      if state['book']['contributors'].size == 1
        contributor = state['book']['contributors'].first

        biog = (state['book']['descriptions'] || []).select { |d|
          d['type'] == "13"
        }.first
        if !biog.nil? && contributor['biography'].nil?
          contributor['biography'] = biog['content']
          state['book']['descriptions'].delete(biog)
        end

        images = state['book']['media']['images'] || [] rescue []
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
    end
  end
end