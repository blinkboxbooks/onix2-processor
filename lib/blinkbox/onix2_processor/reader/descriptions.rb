module Blinkbox::Onix2Processor
  class OtherText <Processor
    handles_xpath '/onixmessage/product/othertext'

    def up(node, state)
      @identifier = {}
      state['descriptions'] ||= []
    end

    def process(node, state)
      position = normalize_tags(node.position)
      container = position.last

      unless node.node_type == Nokogiri::XML::Reader::TYPE_END_ELEMENT
        content = (node.name == "#cdata-section" ? node.value : node.inner_xml).strip
        @identifier[container] = content unless content.nil? || content.empty?
      end
    end

    def down(node, state)
      type = TYPES[@identifier['texttypecode']]

      if !type.nil?
        text = {
          'classification' => [
            {
              'realm' => "onix-codelist-33",
              'id' => @identifier['texttypecode']
            }
          ],
          'type' => @identifier['texttypecode'],
          'content' => @identifier['text']
        }

        text['author'] = @identifier['textauthor'] if @identifier['textauthor']
        text['content'] = HTMLEntities.new.decode(text['content']) if text['content'] =~ /&(?:#?\d{2,3}|[a-z]+);/
        # Santize (HTML) output
        text['content'] = sanitize_html(text['content'])
        (state['book'][type] ||= []).push(text)
      end
    end

    TYPES = YAML.load(open(File.join(__dir__, "../../../../config/othertext.yaml"))).freeze
  end
end