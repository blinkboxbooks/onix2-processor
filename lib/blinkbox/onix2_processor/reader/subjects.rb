module Blinkbox::Onix2Processor
  class Subject < Processor
    handles_xpath '/onixmessage/product/subject'
    handles_xpath '/onixmessage/product/mainsubject'
    handles_xpath '/onixmessage/product/basicmainsubject'

    def up(node, state)
      @identifier = {}
      state['book']['subjects'] ||= []
    end

    def process(node, state)
      container = normalize_tags(node.position).last

      @identifier[container] = node.value if %w{#text #cdata-section}.include?(node.name)

      if %w{mainsubject basicmainsubject}.include?(container)
        @identifier['main'] = true
        @identifier['subjectschemeidentifier'] = @identifier['mainsubjectschemeidentifier']
      end

      # Allows the BASICMainSubject tag
      if container == 'basicmainsubject'
        @identifier['subjectschemeidentifier'] = '10'
        @identifier['subjectcode'] = @identifier['basicmainsubject']
      end
    end

    def down(node, state)
      case @identifier['subjectschemeidentifier']
      when *TYPES.keys
        subject = {
          'type' => TYPES[@identifier['subjectschemeidentifier']],
          'code' => @identifier['subjectcode']
        }
        subject['main'] = true if @identifier['main']

        if @identifier['subjectschemeidentifier'] == "20"
          # Hack for publishers who send long strings as delimited by semicolons, commas etc, as keywords rather than as different items  
          keywords = (@identifier['subjectheadingtext'] || '').split(/[;,\|]\s*/)
          keywords.each do |keyword|
            new_subject = subject.dup
            new_subject['code'] = keyword
            state['book']['subjects'].push(new_subject)
          end
        else
          state['book']['subjects'].push(subject)
        end
      end
    end

    TYPES = {
      '10' => 'BISAC',
      '12' => 'BIC',
      '13' => 'BIC Geo',
      '15' => 'BIC Era',
      '20' => 'Keyword'
    }
  end
end