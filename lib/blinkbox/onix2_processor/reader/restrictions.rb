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
      when '04', '01'
        add_sales_restriction(state) if (state[:sales_outlets] & ACCEPTABLE_ONIX_RETAILER_IDS).empty?
      when '09'
        # Do ingest these
      else
        add_sales_restriction(state)
      end

      state.delete(:sales_outlets)
    end

    private

    def add_sales_restriction(state)
      state['book']['availability']['salesRestrictions'] = {
        "available" => false,
        "code" => @identifier['salesrestrictiontype'],
        "extra" => state[:sales_outlets].join(",")
      }
    end

    ACCEPTABLE_ONIX_RETAILER_IDS = [
      'TES', # Tesco
      'GOS'  # GoSpoken / blinkbox Books
    ]
  end
end