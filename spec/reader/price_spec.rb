descriptor = ReaderExamples.add "price"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    it "must extract wholesale, ex VAT prices" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SupplyDetail>
            <Price>
              <PriceTypeCode>01</PriceTypeCode>
              <CurrencyCode>GBP</CurrencyCode>
            </Price>
          </SupplyDetail>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prices'].size).to eq(1)
      price = book['prices'].first
      expect(price['isAgency']).to eq(false)
      expect(price['includesTax']).to eq(false)
    end

    it "must extract wholesale, inc VAT prices" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SupplyDetail>
            <Price>
              <PriceTypeCode>02</PriceTypeCode>
              <CurrencyCode>GBP</CurrencyCode>
            </Price>
          </SupplyDetail>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prices'].size).to eq(1)
      price = book['prices'].first
      expect(price['isAgency']).to eq(false)
      expect(price['includesTax']).to eq(true)
    end

    it "must extract agency, ex VAT prices" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SupplyDetail>
            <Price>
              <PriceTypeCode>41</PriceTypeCode>
              <CurrencyCode>GBP</CurrencyCode>
            </Price>
          </SupplyDetail>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prices'].size).to eq(1)
      price = book['prices'].first
      expect(price['isAgency']).to eq(true)
      expect(price['includesTax']).to eq(false)
    end

    it "must extract agency, inc VAT prices" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SupplyDetail>
            <Price>
              <PriceTypeCode>42</PriceTypeCode>
              <CurrencyCode>GBP</CurrencyCode>
            </Price>
          </SupplyDetail>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prices'].size).to eq(1)
      price = book['prices'].first
      expect(price['isAgency']).to eq(true)
      expect(price['includesTax']).to eq(true)
    end

    it "must extract price amount" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SupplyDetail>
            <Price>
              <PriceTypeCode>01</PriceTypeCode>
              <PriceAmount>3.14</PriceAmount>
              <CurrencyCode>GBP</CurrencyCode>
            </Price>
          </SupplyDetail>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prices'].size).to eq(1)
      price = book['prices'].first
      expect(price['amount']).to eq(3.14)
    end

    %w{GBP gbp usd USD}.each do |currency|
      it "must extract price currency" do
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <SupplyDetail>
              <Price>
                <PriceTypeCode>01</PriceTypeCode>
                <CurrencyCode>#{currency}</CurrencyCode>
              </Price>
            </SupplyDetail>
          </Product>
        </ONIXmessage>
        XML
        expect_schema_compliance(book)
        expect(book['prices'].size).to eq(1)
        price = book['prices'].first
        expect(price['currency']).to eq(currency.upcase)
      end
    end

    it "must extract available regions" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SupplyDetail>
            <Price>
              <PriceTypeCode>01</PriceTypeCode>
              <PriceAmount>3.14</PriceAmount>
              <CurrencyCode>GBP</CurrencyCode>
              <CountryCode>UK</CountryCode>
              <CountryCode>DE</CountryCode>
              <CountryExcluded>FR</CountryExcluded>
              <CountryExcluded>US</CountryExcluded>
            </Price>
          </SupplyDetail>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prices'].size).to eq(1)
      price = book['prices'].first
      expect(price['applicableRegions'].size).to eq(4)
      expect(price['applicableRegions']['UK']).to eq(true)
      expect(price['applicableRegions']['DE']).to eq(true)
      expect(price['applicableRegions']['FR']).to eq(false)
      expect(price['applicableRegions']['US']).to eq(false)
    end

    it "must extract British tax rates" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <SupplyDetail>
            <Price>
              <CurrencyCode>GBP</CurrencyCode>
              <PriceTypeCode>01</PriceTypeCode>
              <PriceAmount>10.44</PriceAmount>
              <TaxRateCode1>S</TaxRateCode1>
              <TaxRatePercent1>20</TaxRatePercent1>
              <TaxableAmount1>8.7</TaxableAmount1>
              <TaxAmount1>1.74</TaxAmount1>
            </Price>
          </SupplyDetail>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prices'].size).to eq(1)
      price = book['prices'].first
      expect(price['tax'].size).to eq(1)
      tax = price['tax'].first
      expect(tax['rate']).to eq('S')
      expect(tax['percent']).to eq(0.2)
      expect(tax['taxableAmount']).to eq(8.7)
      expect(tax['amount']).to eq(1.74)
    end

    it "must extract price territories" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <product>
          <supplydetail>
            <price>
              <j152>GBP</j152>
              <j148>01</j148>
              <j151>3.14</j151>
              <j303>ROW</j303>
              <j304>US</j304>
            </price>
          </supplydetail>
        </product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prices'].size).to eq(1)
      price = book['prices'].first
      expect(price['applicableRegions']['ROW']).to eq(true)
      expect(price['applicableRegions']['US']).to eq(false)
    end

    it "must extract price countries" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <product>
          <supplydetail>
            <price>
              <j152>GBP</j152>
              <j148>01</j148>
              <j151>3.14</j151>
              <b251>UK</b251>
              <b251>US</b251>
            </price>
          </supplydetail>
        </product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['prices'].size).to eq(1)
      price = book['prices'].first
      expect(price['applicableRegions']['UK']).to eq(true)
      expect(price['applicableRegions']['US']).to eq(true)
    end
  end
end