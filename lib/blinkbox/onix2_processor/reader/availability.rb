module Blinkbox::Onix2Processor
  class Availability < Processor
    handles_xpath '/onixmessage/product/supplydetail/availabilitycode'
    handles_xpath '/onixmessage/product/supplydetail/productavailability'
    handles_xpath '/onixmessage/product/publishingstatus'
    handles_xpath '/onixmessage/product/notificationtype'

    def up(node, state)
      state['book']['availability'] ||= {}
    end

    def process(node, state)
      if !node.value.nil?
        type = normalize_tags(node.position).last
        code = (node.value || "").upcase
        map_name = CODE_MAP[type]
        return product_failure(state, "UnknownAvailabilityType", type: type) if map_name.nil?
        availability = CODES[type][code]
        return product_failure(state, "UnknownAvailabilityCode", code: code) if availability.nil?

        state["book"]["availability"][map_name] = {
          "available" => availability,
          "code" => code
        }
      end
    end

    CODE_MAP = {
      "availabilitycode" => "availabilityCode",
      "productavailability" => "productAvailability",
      "publishingstatus" => "publishingStatus",
      "notificationtype" => "notificationType"
    }

    CODES = yaml_config('availability')
  end
end