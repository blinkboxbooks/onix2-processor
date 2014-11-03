descriptor = ReaderExamples.add "cover images"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    %w{04 06}.each do |front_cover_code|
      it "must extract remote book images (type #{front_cover_code})" do
        asset_url = "http://domain.com/path/to/image.jpg"
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <MediaFile>
              <MediaFileTypeCode>#{front_cover_code}</MediaFileTypeCode>
              <MediaFileLinkTypeCode>01</MediaFileLinkTypeCode>
              <MediaFileLink>#{asset_url}</MediaFileLink>
            </MediaFile>
          </Product>
        </ONIXmessage>
        XML
        expect_schema_compliance(book)
        expect(book["media"]["images"].size).to eq(1)
        img = book["media"]["images"].first
        expect(img['classification']).to eq([{"realm" => "type", "id" => "front_cover"}])
        expect(img['uris'].size).to eq(1)
        url = img['uris'].first
        expect(url['type']).to eq('remote')
        expect(url['uri']).to eq(asset_url)
      end

      it "must raise error for non-URI book remote image" do
        asset_url = "not a URI"
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <Product>
            <MediaFile>
              <MediaFileTypeCode>#{front_cover_code}</MediaFileTypeCode>
              <MediaFileLinkTypeCode>01</MediaFileLinkTypeCode>
              <MediaFileLink>#{asset_url}</MediaFileLink>
            </MediaFile>
          </Product>
        </ONIXmessage>
        XML
        expect_schema_compliance(book)
        expect(failures.size).to eq(1)
        failure = failures.first
        expect(failure[:error_code]).to eq("InvalidURI")
        expect(failure[:data][:uri]).to eq(asset_url)
      end
    end
  end
end