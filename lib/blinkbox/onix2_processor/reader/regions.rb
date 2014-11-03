module Blinkbox::Onix2Processor
  class SupplyRights < Processor
    handles_xpath '/onixmessage/product/supplydetail/supplytocountry'
    handles_xpath '/onixmessage/product/supplydetail/supplytoterritory'
    handles_xpath '/onixmessage/product/supplydetail/supplytocountryexcluded'

    def up(node, state)
      @identifier = {}
      state['book']['supplyRights'] ||= {}
    end

    def process(node, state)
      position = normalize_tags(node.position)
      exclude = (position.last == 'supplytocountryexcluded')
      node.inner_xml.split(' ').each do |region|
        next product_failure(state, "InvalidSupplyRightsRegion", region: region) if !region.match(/^[A-Z]{2}$/) && !%w{WORLD ROW}.include?(region)
        previous = state['book']['supplyRights'][region] || true
        state['book']['supplyRights'][region] = previous && !exclude
      end
    end
  end

  class SalesRights < Processor
    handles_xpath '/onixmessage/product/salesrights'

    def up(node, state)
      @identifier = {}
      state['book']['salesRights'] ||= {}
    end

    def process(node, state)
      position = normalize_tags(node.position)
      @identifier[position.last] = node.value if position.length > 3 && %w{#text #cdata-section}.include?(node.name)
    end

    def down(node, state)
      exclude = !%W{01 02}.include?(@identifier['salesrightstype'])
      ([@identifier['rightscountry'],@identifier['rightsterritory']].join(' ')).split(' ').each do |region|
        next product_failure(state, "InvalidSalesRightsRegion", region: region) if !region.match(/^[A-Z]{2}$/) && !%w{WORLD ROW}.include?(region)
        previous = state['book']['salesRights'][region] || true
        state['book']['salesRights'][region] = previous && !exclude
      end
    end
  end
end