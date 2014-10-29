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

        # TODO: Failure on exception (from Dates)
        date = Dates.process_date(node.value)
        (state['book']['dates'] ||= {})[type] ||= date
      end
    end

    def self.process_date(string)
      if string =~ /^(\d{4})(\d{2})?(\d{2})?$/
        return Date.new($1.to_i,($2 || 1).to_i,($3 || 1).to_i).iso8601
      else
        raise "Invalid date given: #{string}"
      end
    end
  end
end