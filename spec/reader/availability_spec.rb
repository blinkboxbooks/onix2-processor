descriptor = ReaderExamples.add "availability"
require "ostruct"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    describe "AvailabilityCode" do
      {
        'IP' => true,
        'MD' => true,
        'NP' => true,
        'NY' => true,
        'RP' => true,
        'RU' => true,
        'TO' => true,
        'TP' => true,
        'TU' => true,
        'WR' => true,
        'AB' => false,
        'AD' => false,
        'CS' => false,
        'EX' => false,
        'OF' => false,
        'OI' => false,
        'OP' => false,
        'OR' => false,
        'PP' => false,
        'RF' => false,
        'RM' => false,
        'UR' => false,
        'WS' => false
      }.each_pair do |code, availability|
        it "must be marked as #{availability ? '' : 'un'}available for #{code}" do
          book = process_xml_with_service <<-XML
          <ONIXmessage>
            <Product>
              <SupplyDetail>
                <AvailabilityCode>#{code}</AvailabilityCode>
              </SupplyDetail>
            </Product>
          </ONIXmessage>
          XML
          expect_schema_compliance(book)
          expect(book["availability"]).to_not be_nil
          expect(book["availability"]["availabilityCode"]).to_not be_nil
          expect(book["availability"]["availabilityCode"]["available"]).to eq(availability)
          expect(book["availability"]["availabilityCode"]["code"]).to eq(code)
        end
      end

      it "must raise a failure for unknown availability codes" do
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <SupplyDetail>
              <AvailabilityCode>nope</AvailabilityCode>
            </SupplyDetail>
          </Product>
        </ONIXmessage>
        XML
        expect_schema_compliance(book)
        expect(failures.size).to eq(1)
        failure = failures.first
        expect(failure[:error_code]).to eq("UnknownAvailabilityCode")
        expect(failure[:data][:code]).to eq("NOPE")
      end
    end

    describe "NotificationType" do
      {
        '01' => true,
        '02' => true,
        '03' => true,
        '04' => true,
        '08' => true,
        '09' => true,
        '12' => true,
        '13' => true,
        '14' => true,
        '05' => false
      }.each_pair do |code, availability|
        it "must be marked as #{availability ? '' : 'un'}available for #{code}" do
          book = process_xml_with_service <<-XML
          <ONIXmessage>
            <Product>
              <NotificationType>#{code}</NotificationType>
            </Product>
          </ONIXmessage>
          XML
          expect_schema_compliance(book)
          expect(book["availability"]).to_not be_nil
          expect(book["availability"]["notificationType"]).to_not be_nil
          expect(book["availability"]["notificationType"]["available"]).to eq(availability)
          expect(book["availability"]["notificationType"]["code"]).to eq(code)
        end
      end

      it "must raise a failure for unknown availability codes" do
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <NotificationType>nope</NotificationType>
          </Product>
        </ONIXmessage>
        XML
        expect_schema_compliance(book)
        expect(failures.size).to eq(1)
        failure = failures.first
        expect(failure[:error_code]).to eq("UnknownAvailabilityCode")
        expect(failure[:data][:code]).to eq("NOPE")
      end
    end

    describe "PublishingStatus" do
      {
        '00' => true,
        '02' => true,
        '04' => true,
        '09' => true,
        '01' => false,
        '03' => false,
        '05' => false,
        '06' => false,
        '07' => false,
        '08' => false,
        '10' => false,
        '11' => false,
        '12' => false,
        '15' => false,
        '16' => false
      }.each_pair do |code, availability|
        it "must be marked as #{availability ? '' : 'un'}available for #{code}" do
          book = process_xml_with_service <<-XML
          <ONIXmessage>
            <Product>
              <PublishingStatus>#{code}</PublishingStatus>
            </Product>
          </ONIXmessage>
          XML
          expect_schema_compliance(book)
          expect(book["availability"]).to_not be_nil
          expect(book["availability"]["publishingStatus"]).to_not be_nil
          expect(book["availability"]["publishingStatus"]["available"]).to eq(availability)
          expect(book["availability"]["publishingStatus"]["code"]).to eq(code)
        end
      end

      it "must raise a failure for unknown availability codes" do
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <PublishingStatus>nope</PublishingStatus>
          </Product>
        </ONIXmessage>
        XML
        expect_schema_compliance(book)
        expect(failures.size).to eq(1)
        failure = failures.first
        expect(failure[:error_code]).to eq("UnknownAvailabilityCode")
        expect(failure[:data][:code]).to eq("NOPE")
      end

      # TODO: Add forthcoming & dates
    end

    describe "ProductAvailability" do
      {
        '10' => true,
        '11' => true,
        '20' => true,
        '21' => true,
        '22' => true,
        '33' => true,
        '34' => true,
        '97' => true,
        '01' => false,
        '12' => false,
        '23' => false,
        '30' => false,
        '31' => false,
        '32' => false,
        '40' => false,
        '41' => false,
        '42' => false,
        '43' => false,
        '44' => false,
        '45' => false,
        '46' => false,
        '47' => false,
        '48' => false,
        '49' => false,
        '50' => false,
        '51' => false,
        '52' => false,
        '98' => false,
        '99' => false
      }.each_pair do |code, availability|
        it "must be marked as #{availability ? '' : 'un'}available for #{code}" do
          book = process_xml_with_service <<-XML
          <ONIXmessage>
            <Product>
              <SupplyDetail>
                <ProductAvailability>#{code}</ProductAvailability>
              </SupplyDetail>
            </Product>
          </ONIXmessage>
          XML
          expect_schema_compliance(book)
          expect(book["availability"]).to_not be_nil
          expect(book["availability"]["productAvailability"]).to_not be_nil
          expect(book["availability"]["productAvailability"]["available"]).to eq(availability)
          expect(book["availability"]["productAvailability"]["code"]).to eq(code)
        end
      end

      it "must raise a failure for unknown availability codes" do
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <SupplyDetail>
              <ProductAvailability>nope</ProductAvailability>
            </SupplyDetail>
          </Product>
        </ONIXmessage>
        XML
        expect_schema_compliance(book)
        expect(failures.size).to eq(1)
        failure = failures.first
        expect(failure[:error_code]).to eq("UnknownAvailabilityCode")
        expect(failure[:data][:code]).to eq("NOPE")
      end
    end

    it "must raise a failure for unknown availability types" do
      node = OpenStruct.new(
        value: "whatever",
        position: %w{ONIXMessage product somethingunexpected}
      )
      state = { product_failures: [] }
      Blinkbox::Onix2Processor::Availability.allocate.process(node, state)
      expect(state[:product_failures].size).to eq(1)
      failure = state[:product_failures].first
      expect(failure[:error_code]).to eq("UnknownAvailabilityType")
      expect(failure[:data][:type]).to eq("somethingunexpected")
    end
  end
end