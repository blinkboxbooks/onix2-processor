# Dir.glob(File.join(__dir__, "reader/*_spec.rb")) { |reader_spec| require reader_spec } 

context Blinkbox::Onix2Processor::Reader do
  include_examples "titles"
  include_examples "contributors"
  include_examples "series"
end