module Blinkbox::Onix2Processor
  class Title < Processor
    handles_xpath '/onixmessage/product/title'
    # handles_xpath '/onixmessage/product/titleprefix'
    # handles_xpath '/onixmessage/product/titlewithoutprefix'
    handles_xpath '/onixmessage/product/distinctivetitle'
    handles_xpath '/onixmessage/product/titletext'

    def up(node, state)
      @identifier ||= {}
    end

    def process(node, state)
      container = normalize_tags(node.position[2..-1])

      @identifier[container] = node.value if %w{#text #cdata-section}.include?(node.name)
    end

    def down(node, state)
      state['book']['title'] = # next line
        @identifier[%w{title distinctivetitle}] || @identifier[%w{distinctivetitle}] ||
        @identifier[%w{title titletext}] || @identifier[%w{titletext}] || 
        [
          @identifier[%w{title titleprefix}] || @identifier[%w{titleprefix}],
          @identifier[%w{title titlewithoutprefix}] || @identifier[%w{titlewithoutprefix}]
        ].compact.join(' ')

      extract_series_name_from_title(state)
    end

    private

    # Hack: Checking for a series and book within the title
    def extract_series_name_from_title(state)
      if state['book']['title'] =~ /^(.+?)\s*\(([^\)]+?),? (?:- )?book ([^\ ]+)\)$/i
        state['book']['title'] = $1
        (state['book']['series'] ||= {})['title'] ||= $2
        (state['book']['series'] ||= {})['number'] ||= $3.integerize
      elsif state['book']['title'] =~ /^(.+?):\s?([^\)]+?) book ([^\ ]+)$/i
        state['book']['title'] = $1
        (state['book']['series'] ||= {})['title'] ||= $2
        (state['book']['series'] ||= {})['number'] ||= $3.integerize
      end
    end
  end
end