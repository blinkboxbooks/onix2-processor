context Blinkbox::Onix2Processor::Reader do
  describe "while reading isbns" do
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

    %w{13}.each do |relation_code|
      %w{15 03}.each do |product_id_type|
        it "must extract related ISBNs" do
          isbn = "9780091856090"
          book = process_xml_with_service <<-XML
          <ONIXmessage>
            <Product>
              <RelatedProduct>
                <RelationCode>#{relation_code}</RelationCode>
                <ProductIdentifier>
                  <ProductIDType>#{product_id_type}</ProductIDType>
                  <IDValue>#{isbn}</IDValue>
                </ProductIdentifier>
              </RelatedProduct>
            </Product>
          </ONIXmessage>
          XML
          expect_schema_compliance(book)
          expect(book['related'].size).to eq(1)
          related = book['related'].first
          expect(related['classification']).to eq([{ "realm" => "isbn", "id" => isbn }])
          expect(related['relation']).to eq(relation_code)
          expect(related['isbn']).to eq(isbn)
        end
      end
    end

    it "must raise a failure if an ISBN isn't 13 digits long" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <EAN13>145</EAN13>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      relevant_failures = failures("InvalidISBN")
      expect(relevant_failures.size).to eq(1)
      failure = relevant_failures.first
      expect(failure[:data][:isbn]).to eq("145")
      expect(book).to_not have_key('isbn')
    end

    it "must raise a failure if an ISBN doesn't start with 9780, 9781 or 979" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <EAN13>1234567890123</EAN13>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      relevant_failures = failures("InvalidISBN")
      expect(relevant_failures.size).to eq(1)
      failure = relevant_failures.first
      expect(failure[:data][:isbn]).to eq("1234567890123")
      expect(book).to_not have_key('isbn')
    end
  end
end