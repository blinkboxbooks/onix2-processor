module Blinkbox::Onix2Processor
  class Contributors < Processor
    handles_xpath '/onixmessage/product/contributor'

    def up(node, state)
      @identifier = {}
    end

    def process(node, state)
      container = normalize_tags(node.position).last
      @identifier[container] = node.value.strip if %w{#text #cdata-section}.include?(node.name)
    end

    def down(node, state)
      c = {
        'role' => @identifier['contributorrole'],
        'names' => {
          'titlesBeforeNames' => @identifier['titlesbeforenames'],
          'namesBeforeKey'    => @identifier['namesbeforekey'],
          'prefixToKey'       => @identifier['prefixtokey'],
          'keyNames'          => @identifier['keynames'],
          'namesAfterKey'     => @identifier['namesafterkey'],
          'suffixToKey'       => @identifier['suffixtokey'],
          'lettersAfterNames' => @identifier['lettersafternames'],
          'titlesAfterNames'  => @identifier['titlesafternames'],
        }.delete_if { |k, n| n.nil? || n.empty? }
      }

      c['names']['display'] = @identifier['personname'] || @identifier['corporatename'] || c['names'].values.join(' ')
      c['names']['sort'] = @identifier['personnameinverted']

      # Guess display or sort name, if they're missing.
      guessed_sort = [
        c['names'].select { |k, v| %w{keyNames namesAfterKey suffixToKey lettersAfterNames titlesAfterNames}.include?(k) }.values.join(' '),
        c['names'].select { |k, v| %w{titlesBeforeNames namesBeforeKey prefixToKey}.include?(k) }.values.join(' ')
      ].select { |v| !v.empty? } .join(', ')
      c['names']['sort'] = guessed_sort if !c['names']['sort'] && !guessed_sort.empty?

      if c['names']['display'] && (c['names']['sort'].nil? || c['names']['sort'].empty?)
        first, *last = c['names']['display'].split(" ")
        c['names']['sort'] = [last.join(" "), first].join(", ")
      elsif c['names']['sort'] && (c['names']['display'].nil? || c['names']['display'].empty?)
        c['names']['display'] = c['names']['sort'].split(", ").reverse.join(" ")
      end

      c['biography'] = sanitize_html(@identifier['biographicalnote']) if @identifier['biographicalnote']

      state['book']['contributors'].push(c)
    end
  end
end