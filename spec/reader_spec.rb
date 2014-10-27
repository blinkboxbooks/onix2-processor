Dir.glob(File.join(__dir__, "reader/*_spec.rb")) { |reader_spec| require reader_spec } if ReaderExamples.list.empty?

context Blinkbox::Onix2Processor::Reader do
  ReaderExamples.list.each do |area|
    include_examples area
  end
end