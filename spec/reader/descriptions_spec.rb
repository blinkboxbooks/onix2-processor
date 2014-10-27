descriptor = ReaderExamples.add "descriptions"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    it "must extract back cover text" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <OtherText>
            <TextTypeCode>18</TextTypeCode>
            <TextFormat>06</TextFormat>
            <Text>My description</Text>
          </OtherText>
        </Product>
      </ONIXmessage>
      XML

      expect(book['descriptions'].size).to eq(1)
      desc = book['descriptions'].first
      expect(desc['type']).to eq("18")
      expect(desc['content']).to eq("My description")
    end

    it "must extract back cover html" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <OtherText>
            <TextTypeCode>18</TextTypeCode>
            <TextFormat>05</TextFormat>
            <Text><![CDATA[<em>emphatically</em>]]></Text>
          </OtherText>
        </Product>
      </ONIXmessage>
      XML

      expect(book['descriptions'].size).to eq(1)
      desc = book['descriptions'].first
      expect(desc['type']).to eq("18")
      expect(desc['content']).to eq("<em>emphatically</em>")
    end

    it "must extract back cover with short tags" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <othertext>
            <d102>18</d102>
            <d103>06</d103>
            <d104>A description</d104>
          </othertext>
        </Product>
      </ONIXmessage>
      XML

      expect(book['descriptions'].size).to eq(1)
      desc = book['descriptions'].first
      expect(desc['type']).to eq("18")
      expect(desc['content']).to eq("A description")
    end

    it "must extract and convert HTML entities" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <othertext>
            <d102>18</d102>
            <d103>05</d103>
            <d104>This is &lt;strong&gt;html&lt;/strong&gt; dammit!</d104>
          </othertext>
        </Product>
      </ONIXmessage>
      XML

      expect(book['descriptions'].size).to eq(1)
      desc = book['descriptions'].first
      expect(desc['content']).to eq("This is <strong>html</strong> dammit!")
    end

    it "must extract and convert HTML entities from within CDATA tags (ugh)" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <othertext>
            <d102>18</d102>
            <d103>05</d103>
            <d104><![CDATA[This is &lt;strong&gt;html&lt;/strong&gt; dammit!]]></d104>
          </othertext>
        </Product>
      </ONIXmessage>
      XML

      expect(book['descriptions'].size).to eq(1)
      desc = book['descriptions'].first
      expect(desc['content']).to eq("This is <strong>html</strong> dammit!")
    end

    it "must extract HTML classified as SGML" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <product>
          <othertext>
          <d102>01</d102>
          <d103>01</d103>
          <d104><![CDATA[This really isn't SGML]]></d104>
          </othertext>
        </product>
      </ONIXmessage>
      XML

      expect(book['descriptions'].size).to eq(1)
      desc = book['descriptions'].first
      expect(desc['content']).to eq("This really isn't SGML")
    end

    it "must extract XHTML tags in the description" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <product>
          <othertext>
            <d102>02</d102>
            <d104 textformat="05"><p>Howdy</p></d104>
          </othertext>
        </product>
      </ONIXmessage>
      XML

      expect(book['descriptions'].size).to eq(1)
      desc = book['descriptions'].first
      expect(desc['content']).to eq("<p>Howdy</p>")
    end

    it "must leave acceptable HTML in descriptions" do
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
              <TextTypeCode>18</TextTypeCode>
              <TextFormat>05</TextFormat>
              <Text><![CDATA[#{data}]]></Text>
            </OtherText>
          </Product>
        </ONIXmessage>
        XML
        desc = book["descriptions"].first
        expect(desc["content"]).to eq(data)
      end
    end
  end
end