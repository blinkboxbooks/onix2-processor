require "blinkbox/onix2_processor/version"
require "blinkbox/common_messaging"
require "blinkbox/common_logging"
require "blinkbox/common_mapping"
require "blinkbox/tictoc"
require "blinkbox/onix2_processor/reader"

module Blinkbox
  module Onix2Processor
    SERVICE_NAME = "Marvin/onix2_processor"
    
    class Service
      attr_reader :logger
      include Blinkbox::CommonHelpers::TicToc

      def initialize(options)
        tic
        @logger = CommonLogging.from_config(options.tree(:logging))
        @logger.facility_version = VERSION
        raise "logging.gelf.facility is not #{SERVICE_NAME}." unless SERVICE_NAME == options[:'logging.gelf.facility']

        rabbit_opts = options.tree(:rabbitmq).to_hash
        prefetch = rabbit_opts.delete(:prefetch)
        CommonMessaging.configure!(rabbit_opts, @logger)

        schema_root = File.join(__dir__, "../../../schemas")
        schema_files = File.join(schema_root, "ingestion")
        CommonMessaging.init_from_schema_at(schema_files, schema_root).each do |klass|
          @logger.debug(
            short_message: "Loaded schema file for #{klass::CONTENT_TYPE}",
            event: :dependency_loaded
          )
        end

        bindings = [
          {
            "content-type" => "application/vnd.blinkbox.books.ingestion.file.pending.v2+json",
            "referenced-content-type" => "application/onix2+xml",
            "x-match" => "all"
          }
        ]

        @queue = CommonMessaging::Queue.new(
          "#{SERVICE_NAME.tr('/','.')}.pending_assets",
          exchange: "Marvin",
          bindings: bindings,
          prefetch: prefetch
        )

        @exchange = CommonMessaging::Exchange.new(
          "Marvin",
          facility: SERVICE_NAME,
          facility_version: VERSION
        )

        @mapper = CommonMapping.new(
          options[:'mapper.url'],
          service_name: SERVICE_NAME
        )
        @logger.info(
          short_message: "ONIX2 Processor v#{VERSION} initialized",
          event: :service_started,
          duration: toc
        )
      end

      def start
        accept_types = [ CommonMessaging::IngestionFilePendingV2 ]
        @queue.subscribe(accept: accept_types) do |metadata, obj|
          process_message(metadata, obj)
        end
      end

      def stop
        tic
        @logger.info(
          short_message: "ONIX2 Processor v#{VERSION} shut down",
          event: :service_stopped,
          duration: toc
        )
      end

      private

      def process_message(metadata, obj)
        tic :file
        @mapper.open(obj['source']['uri']) do |downloaded_file_io|
          begin
            source = obj['source'].merge(
              'system' => {
                'name' => SERVICE_NAME,
                'version' => VERSION
              }
            )

            reader = Reader.new(downloaded_file_io)

            tic :book
            issues = reader.each_book do |book|
              book_obj = CommonMessaging::IngestionBookMetadataV2.new(book)

              message_id = @exchange.publish(
                book_obj,
                message_id_chain: metadata[:headers]['message_id_chain']
              )

              @logger.info(
                short_message: "Book collected from ONIX file",
                event: :book_processed,
                isbn: isbn,
                message_id: message_id,
                duration: toc(:book),
                data: {
                  source: source.dup
                }
              )
              # Start the timer for the next one
              tic :book
            end
            # TODO: gather issues
            # TODO: toc :file
            :ack
          # TODO: Determine temporary errors
          rescue
            # TODO: expand this log message
            @logger.warn(
              stort_message: "Temporary error in processing, requeuing. (#{e.message})",
              backtrace: e.backtrace
            )
            :retry
          end
        end
      end
    end
  end
end