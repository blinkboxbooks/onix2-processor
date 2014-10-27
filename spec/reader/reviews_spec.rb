descriptor = ReaderExamples.add "reviews"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    it "must extract back cover text" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <product>
          <othertext>
            <d102>07</d102>
            <d103>06</d103>
            <d104>A review</d104>
            <d107>J. G. Ballard</d107>
          </othertext>
        </product>
      </ONIXmessage>
      XML

      expect((book['descriptions'] || []).size).to eq(0)
      expect(book['reviews'].size).to eq(1)
      rev = book['reviews'].first
      expect(rev['type']).to eq("07")
      expect(rev['content']).to eq("A review")
      expect(rev['author']).to eq("J. G. Ballard")
    end

    it "must leave acceptable HTML in reviews" do
      [
        "<em>Emph</em>",
        "<ol></ol>",
        "<ul></ul>",
        "<li>work?</li>",
        "<strong>Strong</strong>",
        "<i>italic</i>",
        "<b>bold</b>",
        "<br />",
        "<a href=\"http://google.com\">google</a>",
        "<a href=\"http://path.to/place\" title=\"Title\">link</a>"
      ].each do |tag|
        data = "Acceptable tag #{tag} is kept"
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <OtherText>
              <TextTypeCode>07</TextTypeCode>
              <TextFormat>05</TextFormat>
              <Text><![CDATA[#{data}]]></Text>
            </OtherText>
          </Product>
        </ONIXmessage>
        XML
        rev = book["reviews"].first
        expect(rev["content"]).to eq(data)
      end
    end
  end
end