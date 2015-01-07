require "blinkbox/onix2_processor/version"
require "nokogiri"
require "htmlentities"
require "zlib"
require "socket"
require "date"
require "nokogiri/xml/reader/position"

module Blinkbox
  module Onix2Processor
    class Reader
      def initialize(io, source)
        @io = io
        @source = source
      end

      def each_book(&block)
        raise ArgumentError, "You must call each_book with a block" unless block_given?
        # Start up a Nokogiri reader - it'll walk the nodes, rather than treat it like a DOM 
        reader = Nokogiri::XML::Reader(@io)

        processor = Blinkbox::Onix2Processor::Processor.new

        state = {
          source: @source.merge(
            "system" => {
              "name" => SERVICE_NAME,
              "version" => VERSION
            }
          ),
          on_book_metadata_complete: block,
          failures: []
        }

        state = processor.dispatch(reader, state)

        state[:failures]
      end
    end
  end
end

require "blinkbox/onix2_processor/processor"