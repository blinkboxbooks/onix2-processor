require "blinkbox/common_config"
require "blinkbox/onix2_processor/service"

context Blinkbox::Onix2Processor::Service do
  describe "#intialize" do
    before :each do
      @options = Blinkbox::CommonConfig.new
    end

    it "must create pending assets & mapping updates queues if they are not present" do
      queue = stub_const("Blinkbox::CommonMessaging::Queue", double(Blinkbox::CommonMessaging::Queue))
      allow(queue).to receive(:new)
      described_class.new(@options)
      expect(queue).to have_received(:new).with("Marvin.onix2_processor.pending_assets", exchange: "Marvin", bindings: anything, prefetch: kind_of(Integer))
      expect(queue).to have_received(:new).with("Marvin.onix2_processor.mapping_updates", exchange: "Mapping", bindings: anything)
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
      allow(@service).to receive(:process_epub)
      @queue = instance_double(Blinkbox::CommonMessaging::Queue)
      def @queue.subscribe(&block)
        @subscribe_block = block
      end
      @service.instance_variable_set(:'@queue', @queue)

      @logger = instance_double(Blinkbox::CommonLogging)
      @service.instance_variable_set(:'@logger', @logger)
      allow(@logger).to receive(:error)
      @service.start
    end

    def fake_publish(metadata, obj)
      @queue.instance_variable_get(:'@subscribe_block').call(metadata, obj)
    end

    it "must send IngestionFilePendingV2 messages for processing" do
      metadata = { headers: {} }
      obj = Blinkbox::CommonMessaging::IngestionFilePendingV2.allocate
      expect(fake_publish(metadata, obj)).to eq(:ack)
      expect(@service).to have_received(:process_message).with(metadata, obj)
    end

    it "must log an error and reject other messages" do
      metadata = { headers: {} }
      obj = Blinkbox::CommonMessaging::IngestionBookMetadataV2.allocate
      expect(fake_publish(metadata, obj)).to eq(:reject)
      expect(@service).to_not have_received(:process_message).with(metadata, obj)
      expect(@logger).to have_received(:error)
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
