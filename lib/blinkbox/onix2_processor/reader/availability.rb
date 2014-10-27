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
        state["book"]["availability"][CODE_MAP[type]] = {
          "available" => CODES[type][code],
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

    CODES = YAML.load(open(File.join(__dir__, "../../../../config/availability.yaml"))).freeze
  end
end