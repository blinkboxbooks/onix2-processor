descriptor = ReaderExamples.add "regions"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    it "must extract list of applicable supply regions" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SupplyDetail>
            <SupplyToCountry>GB IE</SupplyToCountry>
            <SupplyToCountryExcluded>US</SupplyToCountryExcluded>
          </SupplyDetail>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['supplyRights'].size).to eq(3)
      expect(book['supplyRights']['GB']).to eq(true)
      expect(book['supplyRights']['IE']).to eq(true)
      expect(book['supplyRights']['US']).to eq(false)
    end

    it "must extract WORLD rights" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SupplyDetail>
            <SupplyToTerritory>WORLD</SupplyToTerritory>
          </SupplyDetail>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['supplyRights'].size).to eq(1)
      expect(book['supplyRights']['WORLD']).to eq(true)
    end

    it "must untangle conflicting supply regions" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SupplyDetail>
            <SupplyToCountry>GB IE</SupplyToCountry>
            <SupplyToCountryExcluded>IE</SupplyToCountryExcluded>
          </SupplyDetail>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['supplyRights'].size).to eq(2)
      expect(book['supplyRights']['GB']).to eq(true)
      expect(book['supplyRights']['IE']).to eq(false)
    end

    {
      true => %w{01 02},
      false => %w{00 03 04 05 06}
    }.each_pair do |available, sales_rights_types|
      sales_rights_types.each do |sales_rights_type|
        it "must extract sales regions" do
          book = process_xml_with_service <<-XML
          <ONIXmessage>
            <product>
              <salesrights>
                <b089>#{sales_rights_type}</b089>
                <b090>AA</b090>
              </salesrights>
            </product>
          </ONIXmessage>
          XML
          expect_schema_compliance(book)
          expect(book['salesRights'].size).to eq(1)
          expect(book['salesRights']['AA']).to eq(available)
        end
      end
    end

    it "must extract sales regions" do
      book = process_xml_with_service <<-XML
      <ONIXMessage>
        <Product>
          <SalesRights>
            <SalesRightsType>01</SalesRightsType>
            <RightsTerritory>WORLD</RightsTerritory>
          </SalesRights>
        </Product>
      </ONIXMessage>
      XML
      expect_schema_compliance(book)
      expect(book['salesRights'].size).to eq(1)
      expect(book['salesRights']['WORLD']).to eq(true)
    end
    
  end
end