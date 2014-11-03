module Blinkbox::Onix2Processor
  class Dates < Processor
    handles_xpath '/onixmessage/product/announcementdate'
    handles_xpath '/onixmessage/product/publicationdate'

    def process(node, state)
      if !node.value.nil?
        type = {
          'announcementdate' => 'announce',
          'publicationdate'  => 'publish'
        }[normalize_tags(node.position).last]

        begin
          date = Dates.process_date(node.value)
        rescue
          return product_failure(state, "InvalidDate", date: node.value)
        end
        (state['book']['dates'] ||= {})[type] ||= date
      end
    end

    def self.process_date(string)
      if string =~ /^(\d{4})-?(\d{2})?-?(\d{2})?$/
        return Date.new($1.to_i,($2 || 1).to_i,($3 || 1).to_i).iso8601
      else
        raise InvalidDate, "Invalid date string: #{string}"
      end
    end
  end

  class InvalidDate < RuntimeError; end
end