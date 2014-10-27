descriptor = ReaderExamples.add "languages"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    %w{eng ENG spa fre}.each do |lang|
      it "must extract language codes from LanguageOfText: #{lang}" do
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <LanguageOfText>#{lang}</LanguageOfText>
          </Product>
        </ONIXmessage>
        XML

        expect(book['languages'].size).to eq(1)
        expect(book['languages'].first).to eq(lang.downcase)
      end
    end

    %w{eng ENG spa fre}.each do |lang|
      it "must extract original language codes from OriginalLanguage: #{lang}" do
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <OriginalLanguage>#{lang}</OriginalLanguage>
          </Product>
        </ONIXmessage>
        XML

        expect(book['originalLanguages'].size).to eq(1)
        expect(book['originalLanguages'].first).to eq(lang.downcase)
      end
    end

    %w{eng ENG spa fre}.each do |lang|
      it "must extract language codes from Language: #{lang}" do
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <Language>
              <LanguageRole>01</LanguageRole>
              <LanguageCode>#{lang}</LanguageCode>
            </Language>
          </Product>
        </ONIXmessage>
        XML

        expect(book['languages'].size).to eq(1)
        expect(book['languages'].first).to eq(lang.downcase)
      end
    end

    %w{eng ENG spa fre}.each do |lang|
      it "must extract language codes (in multilingual edition) from Language: #{lang}" do
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <Language>
              <LanguageRole>07</LanguageRole>
              <LanguageCode>#{lang}</LanguageCode>
            </Language>
          </Product>
        </ONIXmessage>
        XML

        expect(book['languages'].size).to eq(1)
        expect(book['languages'].first).to eq(lang.downcase)
      end
    end

    %w{eng ENG spa fre}.each do |lang|
      it "must extract original language codes from Language: #{lang}" do
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <Language>
              <LanguageRole>02</LanguageRole>
              <LanguageCode>#{lang}</LanguageCode>
            </Language>
          </Product>
        </ONIXmessage>
        XML

        expect(book['originalLanguages'].size).to eq(1)
        expect(book['originalLanguages'].first).to eq(lang.downcase)
      end
    end

    %w{eng ENG spa fre}.each do |lang|
      it "must extract original language codes (in multilingual book) from Language: #{lang}" do
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <Language>
              <LanguageRole>06</LanguageRole>
              <LanguageCode>#{lang}</LanguageCode>
            </Language>
          </Product>
        </ONIXmessage>
        XML

        expect(book['originalLanguages'].size).to eq(1)
        expect(book['originalLanguages'].first).to eq(lang.downcase)
      end
    end
  end
end