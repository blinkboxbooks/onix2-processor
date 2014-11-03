descriptor = ReaderExamples.add "contributor images"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    it "must extract remote contributor images" do
      asset_url = "http://domain.com/path/to/image.jpg"
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <MediaFile>
            <MediaFileTypeCode>08</MediaFileTypeCode>
            <MediaFileLinkTypeCode>01</MediaFileLinkTypeCode>
            <MediaFileLink>#{asset_url}</MediaFileLink>
          </MediaFile>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["media"]["images"].size).to eq(1)
      img = book["media"]["images"].first
      expect(img['classification']).to eq([{"realm" => "type", "id" => "contributors"}])
      expect(img['uris'].size).to eq(1)
      url = img['uris'].first
      expect(url['type']).to eq('remote')
      expect(url['uri']).to eq(asset_url)
    end

    it "must insert remote contributor images into a contributor if there is only one" do
      asset_url = "http://domain.com/path/to/image.jpg"
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <PersonName>Valentine Cunningham</PersonName>
            <ContributorRole>A01</ContributorRole>
          </Contributor>
          <MediaFile>
            <MediaFileTypeCode>08</MediaFileTypeCode>
            <MediaFileLinkTypeCode>01</MediaFileLinkTypeCode>
            <MediaFileLink>#{asset_url}</MediaFileLink>
          </MediaFile>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["contributors"].size).to eq(1)
      contributor = book["contributors"].first
      expect(contributor["media"]["images"].size).to eq(1)
      img = contributor["media"]["images"].first
      expect(img['classification']).to eq([{"realm" => "type", "id" => "profile"}])
      expect(img['uris'].size).to eq(1)
      url = img['uris'].first
      expect(url['type']).to eq('remote')
      expect(url['uri']).to eq(asset_url)
    end

    it "must raise error for non-URI contributor remote image" do
      asset_url = "not a URI"
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <MediaFile>
            <MediaFileTypeCode>08</MediaFileTypeCode>
            <MediaFileLinkTypeCode>01</MediaFileLinkTypeCode>
            <MediaFileLink>#{asset_url}</MediaFileLink>
          </MediaFile>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      relevant_failures = failures("InvalidURI")
        expect(relevant_failures.size).to eq(1)
        failure = relevant_failures.first
      expect(failure[:data][:uri]).to eq(asset_url)
    end
  end
end