descriptor = ReaderExamples.add "isbns"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    it "must extract ISBN-13s" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <ProductIdentifier>
            <ProductIDType>15</ProductIDType>
            <IDValue>9781780511191</IDValue>
          </ProductIdentifier>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['isbn']).to eq("9781780511191")
    end

    it "must extract GTIN-13s" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <ProductIdentifier>
            <ProductIDType>03</ProductIDType>
            <IDValue>9781780511192</IDValue>
          </ProductIdentifier>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['isbn']).to eq("9781780511192")
    end

    it "must extract EAN.UCC-13" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <EAN13>9780111222333</EAN13>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['isbn']).to eq("9780111222333")
    end
  end
end