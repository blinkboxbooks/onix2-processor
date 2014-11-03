module Blinkbox::Onix2Processor
  class Extent < Processor
    handles_xpath '/onixmessage/product/extent'

    def up(node, state)
      @identifier = {}
      state['book']['statistics'] ||= {}
    end

    def process(node, state)
      position = normalize_tags(node.position)
      container = position.last

      unless node.node_type == Nokogiri::XML::Reader::TYPE_END_ELEMENT
        content = (node.name == "#cdata-section" ? node.value : node.inner_xml).strip
        @identifier[container] = content unless content.nil? || content.empty?
      end
    end

    def down(node, state)
      case @identifier['extentunit']
      when "03"
        return product_failure(state, "InvalidExtent", extent: @identifier['extentvalue']) if @identifier['extentvalue'].nil? || !@identifier['extentvalue'].match(/^\d+$/)
        value = @identifier['extentvalue'].to_i
        case @identifier['extenttype']
        when "00", "08"
          # Best values
          state['book']['statistics']['pages'] = value
        when "10"
          # Less important values
          state['book']['statistics']['pages'] ||= value
        end
      end
    end
  end
end