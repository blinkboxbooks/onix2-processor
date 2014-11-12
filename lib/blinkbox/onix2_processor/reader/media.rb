module Blinkbox::Onix2Processor
  class Media < Processor
    handles_xpath '/onixmessage/product/mediafile'

    def up(node, state)
      @identifier = {}
      state['book']['media'] ||= {}
    end

    def process(node, state)
      container = normalize_tags(node.position).last
      @identifier[container] ||= node.value if %w{#text #cdata-section}.include?(node.name)
    end

    def down(node, state)
      # Will raise an error if it's not a URI
      URI.parse(@identifier['mediafilelink'])
      # MediaFileTypeCode = front cover etc
      if @identifier['mediafilelinktypecode'] == "01" # Only accept URLs
        case @identifier['mediafiletypecode']
        # Only processes the media file types we've specified a location for below
        when *TYPES.keys
          media_def = TYPES[@identifier['mediafiletypecode']]

          (state['book']['media'][media_def['location']] ||= []).push(
            "classification" => [{
              "realm" => "type",
              "id" => media_def['type']
            }],
            "uris" => [{
              "type" => "remote",
              "uri" => @identifier['mediafilelink']
            }]
          )
        else
          # Unusable mediatype
        end
      end
    rescue URI::InvalidURIError
      product_failure(state, "InvalidURI", uri: @identifier['mediafilelink'])
    end

    TYPES = yaml_config("mediafiles")
  end
end