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
        RegionHelper.set_region(state, 'supplyRights', region, !exclude)
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
      [ @identifier['rightscountry'], @identifier['rightsterritory'] ].compact.map { |regionslist|
        regionslist.split(' ')
      }.flatten.each do |region|
        next product_failure(state, "InvalidSalesRightsRegion", region: region) if !region.match(/^[A-Z]{2}$/) && !%w{WORLD ROW}.include?(region)
        RegionHelper.set_region(state, 'salesRights', region, !exclude)
      end
    end
  end

  class NotForSale < Processor
    handles_xpath '/onixmessage/product/notforsale/rightscountry'
    handles_xpath '/onixmessage/product/notforsale/rightsterritory'

    def up(node, state)
      @identifier = {}
      state['book']['salesRights'] ||= {}
    end

    def process(node, state)
      if %w{#text #cdata-section}.include?(node.name)
        region = node.value.upcase
        return product_failure(state, "InvalidSalesRightsRegion", region: region) if !region.match(/^[A-Z]{2}$/) && !%w{WORLD ROW}.include?(region)
        RegionHelper.set_region(state, 'salesRights', region, false)
      end
    end
  end

  class RegionHelper
    def self.set_region(state, type, region, include_region)
      previous = state['book'][type][region].nil? ? true : state['book'][type][region]
      state['book'][type][region] = previous && include_region
      has_excluded_regions = !state['book'][type].select { |_, r| !r }.empty?
      state['book'][type]['ROW'] = state['book'][type].delete('WORLD') if state['book'][type]['WORLD'] && has_excluded_regions
    end
  end
end