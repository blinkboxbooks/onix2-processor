module Blinkbox::Onix2Processor
  class SalesOutlet < Processor
    handles_xpath '/onixmessage/product/salesrestriction/salesoutlet'

    def up(node, state)
      @identifier = {}
    end

    def process(node, state)
      container = normalize_tags(node.position).last
      @identifier[container] = node.value if %w{#text #cdata-section}.include?(node.name)
    end

    def down(node, state)
      state[:sales_outlets].push(@identifier['idvalue'])
    end
  end

  class SalesRestriction < Processor
    handles_xpath '/onixmessage/product/salesrestriction'

    def up(node, state)
      @identifier = {}
      state[:sales_outlets] = []
      state['book']['availability'] ||= {}
    end

    def process(node, state)
      container = normalize_tags(node.position).last
      @identifier[container] = node.value if %w{#text #cdata-section}.include?(node.name)
    end

    def down(node, state)
      case @identifier['salesrestrictiontype'] 
      when'04', '01'
        unless (state[:sales_outlets] & ACCEPTABLE_ONIX_RETAILER_IDS).length > 0
          state['book']['availability']['salesRestrictions'] = {
            "available" => false,
            "code" => @identifier['salesrestrictiontype'],
            "extra" => state[:sales_outlets].join(",")
          }
        end
      when '09'
        # Do ingest these
      else
        state['book']['availability']['salesRestrictions'] = {
          "available" => false,
          "code" => @identifier['salesrestrictiontype'],
          "extra" => state[:sales_outlets].join(",")
        }
      end

      state.delete(:sales_outlets)
    end

    ACCEPTABLE_ONIX_RETAILER_IDS = [
      'TES', # Tesco
      'GOS'  # GoSpoken / blinkbox Books
    ]
  end
end