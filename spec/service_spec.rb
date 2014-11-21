require "blinkbox/common_config"
require "blinkbox/onix2_processor/service"

context Blinkbox::Onix2Processor::Service do
  describe "#intialize" do
    before :each do
      @options = Blinkbox::CommonConfig.new
    end

    it "must create pending assets queue if they are not present" do
      queue_klass = stub_const("Blinkbox::CommonMessaging::Queue", double(Blinkbox::CommonMessaging::Queue))
      allow(queue_klass).to receive(:new)
      exchange = stub_const("Blinkbox::CommonMessaging::Exchange", double(Blinkbox::CommonMessaging::Exchange))
      allow(exchange).to receive(:new)
      mapping_klass = stub_const("Blinkbox::CommonMapping", double(Blinkbox::CommonMapping))
      allow(mapping_klass).to receive(:new)

      described_class.new(@options)
      expect(queue_klass).to have_received(:new).with("Marvin.onix2_processor.pending_assets", exchange: "Marvin", bindings: anything, prefetch: kind_of(Integer))
      expect(mapping_klass).to have_received(:new)
    end

    it "must not start if logging options are missing" do
      opts = double(@options)
      allow(opts).to receive(:tree).with(:logging).and_return({})
      expect {
        described_class.new(opts)
      }.to raise_error(ArgumentError)
    end
  end

  describe "#start" do
    before :each do
      @service = described_class.allocate
      allow(@service).to receive(:process_message)
      @queue = instance_double(Blinkbox::CommonMessaging::Queue)
      allow(@queue).to receive(:subscribe) { |opts, &block| @subscribe_block = block }
      @service.instance_variable_set(:'@queue', @queue)

      @logger = instance_double(Blinkbox::CommonLogging)
      @service.instance_variable_set(:'@logger', @logger)
      allow(@logger).to receive(:error)
      @service.start
    end

    def fake_publish(metadata, obj)
      @queue.instance_variable_get(:'@subscribe_block').call(metadata, obj)
    end
  end

  describe "#process_message" do
    before :each do
      @service = described_class.allocate
      @logger = instance_double(Blinkbox::CommonLogging)
      @service.instance_variable_set(:'@logger', @logger)
      allow(@logger).to receive(:info)
      allow(@logger).to receive(:debug)
      @exchange = instance_double(Blinkbox::CommonMessaging::Exchange)
      @service.instance_variable_set(:'@exchange', @exchange)
      allow(@exchange).to receive(:publish)
      @service.instance_variable_set(:'@mapper', File)
      @service.instance_variable_set(:'@service_name', "Marvin/onix2_processor")
    end
  end
end
