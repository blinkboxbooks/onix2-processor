context Blinkbox::Onix2Processor::Reader do
  describe "while reading subtitles" do
    it "must extract from within the Title tag" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Title>
            <Subtitle>Inside title</Subtitle>
          </Title>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["subtitle"]).to eq("Inside title")
    end

    it "must extract from outside the Title tag" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Subtitle>Outside title</Subtitle>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["subtitle"]).to eq("Outside title")
    end

    it "must extract desribed with short tags" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <b029>shrt ttle</b029>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["subtitle"]).to eq("shrt ttle")
    end

    it "must extract subtitles in CDATA tags" do
      book = process_xml_with_service <<-XML
      <onixmessage>
        <product>
          <title>
            <b029><![CDATA[Jefferson, Adams, Marshall, and the Battle for the Supreme Court]]></b029>
          </title>
        </product>
      </onixmessage>
      XML
      expect_schema_compliance(book)
      expect(book["subtitle"]).to eq("Jefferson, Adams, Marshall, and the Battle for the Supreme Court")
    end
  end
end