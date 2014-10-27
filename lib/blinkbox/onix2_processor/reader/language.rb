module Blinkbox::Onix2Processor
  class Language < Processor
    handles_xpath '/onixmessage/product/language'

    def up(node, state)
      @identifier = {}
      state['book']['languages'] ||= []
      state['book']['originalLanguages'] ||= []
    end

    def process(node, state)
      container = normalize_tags(node.position).last
      @identifier[container] = node.value if %w{#text #cdata-section}.include?(node.name)
    end

    def down(node, state)
      lang = @identifier['languagecode'].downcase
      if lang !=~ /^[a-z]{3}$/
        # TODO: Add to failures
      end

      case @identifier['languagerole']
      when '01', '07'
        state['book']['languages'].push(lang)
      when '02', '06'
        state['book']['originalLanguages'].push(lang)
      else
        # TODO: What language role is this?
      end
    end
  end

  class LanguageOfText < Processor
    handles_xpath '/onixmessage/product/languageoftext'
    handles_xpath '/onixmessage/product/originallanguage'

    def up(node, state)
      state['book']['languages'] ||= []
      state['book']['originalLanguages'] ||= []
    end

    def process(node, state)
      unless node.value.nil?
        container = normalize_tags(node.position).last
        lang = node.value.strip.downcase
        if lang =~ /^[a-z]{3}$/
          type = {
            'languageoftext' => 'languages',
            'originallanguage' => 'originalLanguages'
          }[container]
          # TODO: if type.nil?
          state['book'][type].push(lang)
        else
          # TODO: add to failures
        end
      end
    end
  end
end