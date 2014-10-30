descriptor = ReaderExamples.add "dates"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    it "must extract announcement dates" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <AnnouncementDate>20130101</AnnouncementDate>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['dates']['announce']).to eq("2013-01-01")
    end

    it "must extract publish dates (YYYYMMDD)" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <PublicationDate>20120202</PublicationDate>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['dates']['publish']).to eq("2012-02-02")
    end

    it "must extract publish dates (YYYYMM)" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <PublicationDate>201202</PublicationDate>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['dates']['publish']).to eq("2012-02-01")
    end

    it "must extract publish dates (YYYY)" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <PublicationDate>2012</PublicationDate>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['dates']['publish']).to eq("2012-01-01")
    end

    # This is a hack to allow for publishers who can't read the ONIX spec
    it "must extract publish dates (YYYY-MM-DD)" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <PublicationDate>2013-02-04</PublicationDate>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['dates']['publish']).to eq("2013-02-04")
    end
  end
end