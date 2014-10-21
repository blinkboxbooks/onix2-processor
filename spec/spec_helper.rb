$LOAD_PATH.unshift 'lib'
require "blinkbox/common_messaging"
require "blinkbox/tictoc"
require "blinkbox/onix2_processor"
require "stringio"

module Helpers
  def open_example_onix(number)
    open(File.join(__dir__, "reader/data/onix_example_#{number}.xml"))
  end

  def process_xml_with_service(xml)
    reader = Blinkbox::Onix2Processor::Reader.new(xml, {})
    book = nil
    reader.each_book do |output|
      book = output
    end
    book
  end
end

RSpec.configure do |config|
  config.before :all do
    schema_root = File.join(__dir__, "../schemas")
    # TODO: Load up the correct schema here
    schema_dir = File.join(schema_root, "ingestion")
    Blinkbox::CommonMessaging.init_from_schema_at(schema_dir, schema_root)
  end

  config.include(Helpers)
end
