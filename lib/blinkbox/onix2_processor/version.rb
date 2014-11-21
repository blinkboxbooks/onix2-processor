module Blinkbox
  module Onix2Processor
    SERVICE_NAME = "Marvin/onix2_processor"
    VERSION = begin
      File.read(File.join(__dir__,"../../../VERSION")).strip
    rescue Errno::ENOENT
      "0.0.0"
    end
  end
end
