descriptor = ReaderExamples.add "epub types"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    {
      false => %w{023 029 099},
      true => %w{002 022}
    }.each_pair do |incompatible, codes|
      codes.each do |code|
        it "must extract epub type: #{code}" do
          book = process_xml_with_service <<-XML
          <ONIXmessage>
            <Product>
              <EpubType>#{code}</EpubType>
            </Product>
          </ONIXmessage>
          XML
          expect_schema_compliance(book)
          expect(book["format"]["marvinIncompatible"]).to eq(incompatible)
          expect(book["format"]["epubType"]).to eq(code)
        end
      end
    end
  end
end