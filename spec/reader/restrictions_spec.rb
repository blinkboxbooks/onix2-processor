context Blinkbox::Onix2Processor::Reader do
  describe "while reading restrictions" do
    it "must prevent books targeted at iTunes from being sold" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <product>
          <salesrestriction>
            <b381>04</b381>
            <salesoutlet>
              <salesoutletidentifier>
                <b393>03</b393>
                <b244>APC</b244>
              </salesoutletidentifier>
            </salesoutlet>
          </salesrestriction>
        </product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["availability"]).to_not be_nil
      expect(book["availability"]["salesRestrictions"]).to_not be_nil
      expect(book["availability"]["salesRestrictions"]["available"]).to eq(false)
      expect(book["availability"]["salesRestrictions"]["code"]).to eq("04")
      expect(book["availability"]["salesRestrictions"]["extra"]).to eq("APC")
    end

    it "must prevent books targeted at Amazon from being sold" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <product>
          <salesrestriction>
            <b381>04</b381>
            <salesoutlet>
              <salesoutletidentifier>
                <b393>03</b393>
                <b244>AMZ</b244>
              </salesoutletidentifier>
            </salesoutlet>
          </salesrestriction>
        </product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["availability"]).to_not be_nil
      expect(book["availability"]["salesRestrictions"]).to_not be_nil
      expect(book["availability"]["salesRestrictions"]["available"]).to eq(false)
      expect(book["availability"]["salesRestrictions"]["code"]).to eq("04")
      expect(book["availability"]["salesRestrictions"]["extra"]).to eq("AMZ")
    end
  end
end