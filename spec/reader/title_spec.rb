context Blinkbox::Onix2Processor::Reader do
  describe "while reading titles" do
    it "must extract from within the Title tag" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Title>
            <TitleText>Inside title</TitleText>
          </Title>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["title"]).to eq("Inside title")
    end

    it "must extract from outside the Title tag" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <TitleText>Outside title</TitleText>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["title"]).to eq("Outside title")
    end

    it "must correctly extract accents" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Title>
            <TitleText>Titlè wïth áccents</TitleText>
          </Title>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["title"]).to eq("Titlè wïth áccents")
    end

    it "must extract split titles" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Title>
            <TitlePrefix>The</TitlePrefix>
            <TitleWithoutPrefix>Split Title</TitleWithoutPrefix>
          </Title>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["title"]).to eq("The Split Title")
    end
    
    it "must extract titles with short tags" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <product>
          <title>
            <b203>inside title</b203>
          </title>
        </product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["title"]).to eq("inside title")
    end

    it "must extract distinctive titles" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <product>
          <title>
            <b028>distinctive title</b028>
          </title>
        </product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["title"]).to eq("distinctive title")
    end

    it "must extract titles in CDATA" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <product>
          <title>
            <b203><![CDATA[The Great Decision]]></b203>
          </title>
        </product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["title"]).to eq("The Great Decision")
    end
  end
end