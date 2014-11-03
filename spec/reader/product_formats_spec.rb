context Blinkbox::Onix2Processor::Reader do
  describe "while reading epub types" do
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

    it "must extract product form: DG" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <ProductForm>DG</ProductForm>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["format"]["productForm"]).to eq("DG")
      expect(book["format"]["marvinIncompatible"]).to eq(false)
    end

    %w{BA BB}.each do |form|
      it "must extract product form: #{form}" do
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <ProductForm>#{form}</ProductForm>
          </Product>
        </ONIXmessage>
        XML
        expect_schema_compliance(book)
        expect(book["format"]["productForm"]).to eq(form)
        expect(book["format"]["marvinIncompatible"]).to eq(true)
      end
    end
    
    it "must not extract product form: 00" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <ProductForm>00</ProductForm>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["format"]["productForm"]).to be_nil
    end
  end
end