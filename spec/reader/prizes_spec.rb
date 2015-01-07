context Blinkbox::Onix2Processor::Reader do
  describe "while reading prizes" do
    it "must extract prize name" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Prize>
            <PrizeName>Booker Prize</PrizeName>
            <PrizeYear>1999</PrizeYear>
          </Prize>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prizes'].size).to eq(1)
      prize = book['prizes'].first
      expect(prize['name']).to eq("Booker Prize")
      expect_no_failures(/Prize/)
    end

    it "must extract prize year" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Prize>
            <PrizeName>Booker Prize</PrizeName>
            <PrizeYear>1999</PrizeYear>
          </Prize>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prizes'].size).to eq(1)
      prize = book['prizes'].first
      expect(prize['year']).to eq(1999)
      expect_no_failures(/Prize/)
    end

    it "must extract prize country" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Prize>
            <PrizeName>Booker Prize</PrizeName>
            <PrizeYear>1999</PrizeYear>
            <PrizeCountry>US</PrizeCountry>
          </Prize>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prizes'].size).to eq(1)
      prize = book['prizes'].first
      expect(prize['country']).to eq("US")
      expect_no_failures(/Prize/)
    end

    it "must not extract prize country if it is invalid" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Prize>
            <PrizeName>Booker Prize</PrizeName>
            <PrizeYear>1999</PrizeYear>
            <PrizeCountry>NOT ISO-3166-1 2-alpha</PrizeCountry>
          </Prize>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prizes'].size).to eq(1)
      prize = book['prizes'].first
      expect(prize).to_not have_key("country")
      relevant_failures = failures("InvalidPrizeCountry")
      expect(relevant_failures.size).to eq(1)
      failure = relevant_failures.first
      # TODO: check that the correct ISBN is referenced
    end

    it "must extract prize level" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Prize>
            <PrizeName>Booker Prize</PrizeName>
            <PrizeYear>1999</PrizeYear>
            <PrizeCode>02</PrizeCode>
          </Prize>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prizes'].size).to eq(1)
      prize = book['prizes'].first
      expect(prize['level']).to eq("02")
      expect_no_failures(/Prize/)
    end

    it "must not extract prize level outside ONIX codelist 41" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Prize>
            <PrizeName>Booker Prize</PrizeName>
            <PrizeYear>1999</PrizeYear>
            <PrizeCode>08</PrizeCode>
          </Prize>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prizes'].size).to eq(1)
      prize = book['prizes'].first
      expect(prize).to_not have_key("level")
      relevant_failures = failures("InvalidPrizeLevel")
      expect(relevant_failures.size).to eq(1)
      failure = relevant_failures.first
      # TODO: check that the correct ISBN is referenced
    end

    it "must not extract a prize if there is no name" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Prize>
            <PrizeYear>1999</PrizeYear>
            <PrizeCountry>US</PrizeCountry>
            <PrizeCode>02</PrizeCode>
            <PrizeJury></PrizeJury>
          </Prize>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prizes'].size).to eq(0)
      relevant_failures = failures("NoPrizeName")
      expect(relevant_failures.size).to eq(1)
      failure = relevant_failures.first
      # TODO: check that the correct ISBN is referenced
    end

    it "must not extract a prize if there is no year" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Prize>
            <PrizeName>Booker Prize</PrizeName>
            <PrizeCountry>US</PrizeCountry>
            <PrizeCode>02</PrizeCode>
            <PrizeJury></PrizeJury>
          </Prize>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prizes'].size).to eq(0)
      relevant_failures = failures("NoPrizeYear")
      expect(relevant_failures.size).to eq(1)
      failure = relevant_failures.first
      # TODO: check that the correct ISBN is referenced
    end
  end
end