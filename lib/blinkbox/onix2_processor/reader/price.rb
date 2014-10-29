module Blinkbox::Onix2Processor
  class Price < Processor
    handles_xpath '/onixmessage/product/supplydetail/price'

    def up(node, state)
      @identifier = {}
    end

    def process(node, state)
      container = normalize_tags(node.position).last
      if %w{#text #cdata-section}.include?(node.name)
        if @identifier[container]
          @identifier[container] = [@identifier[container], node.value].flatten
        else
          @identifier[container] = node.value
        end
      end
    end

    def down(node, state)
      if %w{01 02 41 42}.include?(@identifier['pricetypecode'])
        taxes = []
        
        check_taxes = ['1']

        check_taxes.each do |n|
          tax = nil

          case @identifier["taxratecode#{n}"]
          when 'Z'
            tax = {'rate' => 'Z'}
          when 'H', 'R', 'S', 'P'
            check_taxes.push('2') unless n == "2"
            tax = {'rate' => @identifier["taxratecode#{n}"]}

            tax['percent'] = @identifier["taxratepercent#{n}"].to_f / 100.0 if @identifier["taxratepercent#{n}"]
            tax['amount'] = @identifier["taxamount#{n}"].to_f if @identifier["taxamount#{n}"]
            tax['taxableAmount'] = @identifier["taxableamount#{n}"].to_f if @identifier["taxableamount#{n}"]
          else
            # TODO: Raise warning, invalid tax code
          end

          taxes.push(tax) unless tax.nil?
        end

        regions = {}
        [@identifier['countrycode'], @identifier['territory']].compact.flatten.each do |region|
          regions[region] = true
        end
        [@identifier['countryexcluded'], @identifier['territoryexcluded']].compact.flatten.each do |region|
          regions[region] = false
        end

        # TODO: Validate currency value

        price = {
          'includesTax'       => (@identifier['pricetypecode'].to_i % 10) == 2,
          'isAgency'          => (@identifier['pricetypecode'].to_i / 10).to_i == 4,
          'amount'            => @identifier['priceamount'].to_f,
          'currency'          => @identifier['currencycode'].upcase,
          'applicableRegions' => regions,
          'tax'               => taxes
        }

        case @identifier['discountcodetype']
        when '02', nil
          code_grouping = DISCOUNT_CODES[@identifier['discountcodetypename'].downcase] if @identifier['discountcodetypename']
          code_grouping ||= DISCOUNT_CODES[:fallback]
          price['discountRate'] = code_grouping[@identifier['discountcode'].downcase] if @identifier['discountcode']
        else
          # TODO: Unknown discount code
        end

        if !price['discountRate'] && @identifier['discountpercent'] && @identifier['discountpercent'] =~ /^\d+(?:\.\d+)?$/
          price['discountRate'] = @identifier['discountpercent'].to_f / 100.0
        end

        price['validFrom'] = Dates.process_date(@identifier['priceeffectivefrom']) if @identifier['priceeffectivefrom']
        price['validUntil'] = Dates.process_date(@identifier['priceeffectiveuntil']) if @identifier['priceeffectiveuntil']

        (state['book']['prices'] ||= []).push(price)
      end
    end

    DISCOUNT_CODES = {
      :fallback => {
        'sdt' => 0.3,
        'eb'  => 0.4,
        'feb' => 0.4
      },
      'csplus' => {
        '01' => 0.5,
        '02' => 0.4,
        '03' => 0.3,
        '04' => 0.525
      },
      'non-trade' => {
        'bnt' => 0.25
      },
      'trade' => {
        'btr' => 0.4
      }
    }
  end
end