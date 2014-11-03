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
    reader = Blinkbox::Onix2Processor::Reader.new(xml, {
      "deliveredAt" => Time.now.utc.iso8601,
      "role" => "publisher_ftp",
      "username" => "whomsoever"
    })
    book = nil
    @failures = reader.each_book do |output|
      book = output
    end
    book
  end

  def expect_schema_compliance(doc)
    expect(doc['$schema']).to_not be_nil
    expect {
      klass = Blinkbox::CommonMessaging.class_from_content_type("application/vnd.blinkbox.books.#{doc['$schema']}+json")
      klass.new(doc)
    }.to_not raise_error
  end

  def failures(matcher = nil)
    return @failures if matcher.nil?
    (@failures || []).select do |f|
      f[:error_code].match(matcher)
    end
  end
end

class ReaderExamples
  @@examples = []
  def self.add(name); @@examples.push(name); name; end
  def self.list; @@examples; end
end

RSpec.configure do |config|
  config.before :all do
    schema_root = File.join(__dir__, "../schemas")
    # TODO: Load up the correct schema here
    schema_dir = File.join(schema_root, "ingestion")
    Blinkbox::CommonMessaging.init_from_schema_at(schema_dir, schema_root)
    @log = StringIO.new
    Blinkbox::Onix2Processor::Processor.logger = Logger.new(@log)
  end

  config.after :each do
    @log.rewind
    log = @log.read
    raise log unless log.empty?
  end

  config.include(Helpers)
end
