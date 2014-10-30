require_relative "reader/base"

class Blinkbox::Onix2Processor::Processor
  @@registered_processors = {}
  @@valid_html = YAML.load(open(File.join(__dir__, "../../../config/valid_html.yaml")))

  # Instantiate a blackhole logger by default
  @@logger = Class.new { def method_missing(*args); end }

  def self.logger=(logger)
    @@logger = logger
  end

  # Allow classes inheriting from this one to declare which nodes they can process
  def self.handles_xpath(xpath, klass = self)
    position_as_array = xpath.split('/').reject(&:empty?)
    @@registered_processors[position_as_array] = klass
  end

  # Take a reader at a specific position and read the next nodes appropriately, handing off to subclasses when a suitable position is found
  def dispatch(node, state)
    @klasses = {}

    node.each do |node|
      ## Look for processors which can handle this node
      position = normalize_tags(node.position)
      processor = nil
      root_node = true

      while processor.nil? and position.length > 0
        processor = @@registered_processors[position]

        if processor.nil?
          position.pop
          # The processor is not defined to handle this node directly, so we won't run #up and #down.
          root_node = false
        end
      end

      unless processor.nil?
        @klasses[position] ||= processor.new

        begin
          # Is this node the declared node and opening?
          if root_node and node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
            @klasses[position].up(node, state)
          end

          @klasses[position].process(node, state)

          # Is this node the declared node and closing?
          if root_node and (node.node_type == Nokogiri::XML::Reader::TYPE_END_ELEMENT or node.self_closing?)
            @klasses[position].down(node, state)
          end
        rescue => e
          @@logger.error(
            short_message: "Processing of node failed",
            details: {
              error_class: e.class,
              error_message: e.message,
              position: position.join('/'),
              backtrace: e.backtrace.join("\n")
              node_xml: node.value
            }
          )
        end
      end
    end

    state
  end

  # Defaults
  def up(node, state); end
  # Defaults
  def process(node, state); end
  # Defaults
  def down(node, state); end
end

Dir.glob(File.join(__dir__, "reader/*.rb")) do |processor_component|
  require processor_component
end