require 'nokogiri'

module Nokogiri
	module XML
		class Reader
			attr_reader :position
			
			alias :original_read :read
			def read
                @position ||= []
                @pop_pending ||= false

                if @pop_pending
                    @position.pop
                    @pop_pending = false
                end

                node = original_read

                unless node.nil?
                    case node.node_type
                    when Nokogiri::XML::Reader::TYPE_ELEMENT
                        @position.push(node.name)
                        @pop_pending = true if node.self_closing?
                    when Nokogiri::XML::Reader::TYPE_END_ELEMENT
                        @pop_pending = true
                    end
                end

                node
            end
		end
	end
end