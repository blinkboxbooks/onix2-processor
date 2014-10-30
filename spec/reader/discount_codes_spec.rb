descriptor = ReaderExamples.add "discount codes"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    {
      "CSPLUS" => {
        "typename" => "CSPLUS",
        "codes" => {
          "01" => 0.5,
          "02" => 0.4,
          "03" => 0.3,
          "04" => 0.525
        }
      },
      "Perseus" => {
        # No typename for perseus
        "codes" => {
          "SDT" => 0.3,
          "EB"  => 0.4,
          "FEB" => 0.4
        }
      },
      "Bloomsbury Non-Trade" => {
        "typename" => "Non-Trade",
        "codes" => {
          "BNT" => 0.25
        }
      },
      "Bloomsbury Trade" => {
        "typename" => "Trade",
        "codes" => {
          "BTR" => 0.4
        }
      }
    }.each_pair do |name, details|
      details['codes'].each_pair do |code, discount_rate|
        it "must extract #{name} discount code #{code} as #{discount_rate * 100}%" do
          book = process_xml_with_service <<-XML
          <ONIXmessage>
            <Product>
              <SupplyDetail>
                <Price>
                  <PriceTypeCode>02</PriceTypeCode>
                  <CurrencyCode>GBP</CurrencyCode>
                  <DiscountCoded>
                    <DiscountCodeType>02</DiscountCodeType>
                    <DiscountCodeTypeName>#{details['typename']}</DiscountCodeTypeName>
                    <DiscountCode>#{code}</DiscountCode>
                  </DiscountCoded>
                </Price>
              </SupplyDetail>
            </Product>
          </ONIXmessage>
          XML
          expect_schema_compliance(book)
          expect(book['prices'].size).to eq(1)
          price = book['prices'].first
          expect(price['discountRate']).to eq(discount_rate)
        end
      end
    end

    [0.125, 0.15, 0.17, 0.20, 0.25, 0.30, 0.32, 0.35, 0.40, 0.425, 0.45, 0.50].each do |discount_rate|
      it "must extract Gardners discount percentages for #{discount_rate * 100}%" do
        pc = "%0.2f" % (discount_rate * 100)
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <SupplyDetail>
              <Price>
                <PriceTypeCode>02</PriceTypeCode>
                <CurrencyCode>GBP</CurrencyCode>
                <DiscountCoded>
                  <DiscountCodeType>02</DiscountCodeType>
                  <DiscountPercent>#{pc}</DiscountPercent>
                </DiscountCoded>
              </Price>
            </SupplyDetail>
          </Product>
        </ONIXmessage>
        XML
        expect_schema_compliance(book)
        expect(book['prices'].size).to eq(1)
        price = book['prices'].first
        expect(price['discountRate']).to eq(discount_rate)
      end
    end
  end
end