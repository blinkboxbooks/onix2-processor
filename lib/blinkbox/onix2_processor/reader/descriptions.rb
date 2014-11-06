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
        @identifier[container] = content unless content.empty?
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
        text['content'].clever_decode!
        text['content'] = sanitize_html(text['content'])
        return product_failure(state, "EmptyDescription") if text['content'].empty?
        (state['book'][type] ||= []).push(text)
      end
    end

    TYPES = yaml_config("othertext")
  end
end