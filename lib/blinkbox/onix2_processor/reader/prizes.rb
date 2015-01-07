module Blinkbox::Onix2Processor
  class Prizes < Processor
    handles_xpath '/onixmessage/product/prize'

    def up(node, state)
      state['book']['prizes'] ||= []
      @identifier = {}
    end

    def process(node, state)
      container = normalize_tags(node.position).last
      @identifier[container] = node.value if %w{#text #cdata-section}.include?(node.name)
    end

    def down(node, state)
      @identifier.delete_if { |k, v| v.nil? || v.strip.empty? }

      if @identifier['prizename'] && @identifier['prizeyear'] && @identifier['prizeyear'].match(/^\d+$/)
        prize = {
          "name" => @identifier['prizename'],
          "year" => @identifier['prizeyear'].to_i
        }
        
        case @identifier['prizecode']
        when /^0[1-7]$/
          prize["level"] = @identifier['prizecode']
        when nil, "" then nil
        else
          product_failure(state, "InvalidPrizeLevel", level: @identifier['prizecode'])
        end

        case @identifier['prizecountry']
        when /^[A-Z]{2}$/
          prize["country"] = @identifier['prizecountry']
        when nil, "" then nil
        else
          product_failure(state, "InvalidPrizeCountry", country: @identifier['prizecountry'])
        end

        prize['classification'] = [
          { "realm" => "prize_name", "id" => prize['name'] },
          { "realm" => "prize_year", "id" => prize['year'] }
        ]

        state['book']['prizes'].push(prize)
      else
        product_failure(state, "NoPrizeName") if !@identifier['prizename']
        if !@identifier['prizeyear']
          product_failure(state, "NoPrizeYear") 
        else
          product_failure(state, "InvalidPrizeYear") if !@identifier['prizeyear'].match(/^\d+$/)
        end
      end
    end
  end
end