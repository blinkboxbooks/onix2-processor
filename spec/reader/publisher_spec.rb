descriptor = ReaderExamples.add "publishers"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    it "must extract publisher names" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <publisher>
            <b291>01</b291>
            <b081>HarperCollins Publishers</b081>
          </publisher>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["publisher"]).to eq("HarperCollins Publishers")
    end

    it "must extract imprint names" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <imprint>
            <b079>HarperSport</b079>
          </imprint>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["imprint"]).to eq("HarperSport")
    end

    it "must extract proprietary imprint names" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <imprint>
            <b241>02</b241>
            <b079>HarperSport</b079>
          </imprint>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["imprint"]).to eq("HarperSport")
    end

    it "must extract the first imprint name given" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <imprint>
            <b079>Imprint A</b079>
          </imprint>
          <imprint>
            <b079>Imprint B</b079>
          </imprint>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["imprint"]).to eq("Imprint A")
    end

    it "must extract publishers & imprints from within CDATA tags" do
      book = process_xml_with_service <<-XML
      <onixmessage>
        <product>
          <imprint>
            <b079><![CDATA[Imprint]]></b079>
          </imprint>
          <publisher>
            <b081><![CDATA[Publisher]]></b081>
          </publisher>
        </product>
      </onixmessage>
      XML
      expect_schema_compliance(book)
      expect(book["publisher"]).to eq("Publisher")
      expect(book["imprint"]).to eq("Imprint")
    end
  end
end