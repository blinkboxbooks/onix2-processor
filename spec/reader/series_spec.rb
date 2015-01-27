context Blinkbox::Onix2Processor::Reader do
  describe "while reading series" do
    it "must extract series name and number" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Series>
            <TitleOfSeries>Battersea Dogs &amp; Cats Home</TitleOfSeries>
            <NumberWithinSeries>5</NumberWithinSeries>
          </Series>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['series']['title']).to eq("Battersea Dogs & Cats Home")
      expect(book['series']['number']).to eq(5)
    end
  end
end