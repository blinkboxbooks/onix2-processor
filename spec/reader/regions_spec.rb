context Blinkbox::Onix2Processor::Reader do
  describe "while reading regions" do
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

    it "must infer WORLD rights if only ROW is specified" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SupplyDetail>
            <SupplyToTerritory>ROW</SupplyToTerritory>
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

    
    it "must extract NotForSale tags" do
      book = process_xml_with_service <<-XML
      <ONIXMessage>
        <Product>
          <NotForSale>
            <RightsCountry>GB</RightsCountry>
          </NotForSale>
        </Product>
      </ONIXMessage>
      XML
      expect_schema_compliance(book)
      expect(book['salesRights'].size).to eq(1)
      expect(book['salesRights']['GB']).to eq(false)
    end

    it "must adhere to NotForSale tags ahead of other sales regions" do
      book = process_xml_with_service <<-XML
      <ONIXMessage>
        <Product>
          <NotForSale>
            <RightsCountry>GB</RightsCountry>
          </NotForSale>
          <SalesRights>
            <SalesRightsType>01</SalesRightsType>
            <RightsTerritory>GB</RightsTerritory>
          </SalesRights>
        </Product>
      </ONIXMessage>
      XML
      expect_schema_compliance(book)
      expect(book['salesRights'].size).to eq(1)
      expect(book['salesRights']['GB']).to eq(false)
    end

    it "must convert WORLD to ROW if other regions are specified" do
      book = process_xml_with_service <<-XML
      <ONIXMessage>
        <Product>
          <NotForSale>
            <RightsCountry>GB</RightsCountry>
          </NotForSale>
          <SalesRights>
            <SalesRightsType>01</SalesRightsType>
            <RightsTerritory>WORLD</RightsTerritory>
          </SalesRights>
        </Product>
      </ONIXMessage>
      XML
      expect_schema_compliance(book)
      expect(book['salesRights'].size).to eq(2)
      expect(book['salesRights']['GB']).to eq(false)
      expect(book['salesRights']['ROW']).to eq(true)
    end
    
    it "must raise failure for invalid supply regions" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SupplyDetail>
            <SupplyToCountry>WAT</SupplyToCountry>
          </SupplyDetail>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      relevant_failures = failures("InvalidSupplyRightsRegion")
      expect(relevant_failures.size).to eq(1)
      failure = relevant_failures.first
      expect(failure[:data][:region]).to eq("WAT")
    end

    it "must raise failure for invalid supply regions" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SupplyDetail>
            <SupplyToCountryExcluded>WAT</SupplyToCountryExcluded>
          </SupplyDetail>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      relevant_failures = failures("InvalidSupplyRightsRegion")
      expect(relevant_failures.size).to eq(1)
      failure = relevant_failures.first
      expect(failure[:data][:region]).to eq("WAT")
    end

    it "must raise failure for invalid sales regions" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SalesRights>
            <SalesRightsType>01</SalesRightsType>
            <RightsTerritory>WAT</RightsTerritory>
          </SalesRights>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      relevant_failures = failures("InvalidSalesRightsRegion")
      expect(relevant_failures.size).to eq(1)
      failure = relevant_failures.first
      expect(failure[:data][:region]).to eq("WAT")
    end
  end
end