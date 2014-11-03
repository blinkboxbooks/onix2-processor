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

    it "must extract series name and number from titles where appropriate" do
      [
        "Book name (Series name - book 2)",
        "Book name (Series name - book two)",
        "Book name (Series name book 2)",
        "Book name: Series name Book 2",
        "Book name: Series name Book Two",
        "Book name (Series name, book 2)"
      ].each do |title|
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <Title>
              <TitleText>#{title}</TitleText>
            </Title>
          </Product>
        </ONIXmessage>
        XML
        expect_schema_compliance(book)
        expect(book['title']).to eq("Book name")
        expect(book['series']['title']).to eq("Series name")
        expect(book['series']['number']).to eq(2)
      end
    end
  end
end