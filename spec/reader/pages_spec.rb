descriptor = ReaderExamples.add "pages"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    it "must extract page count" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <NumberOfPages>42</NumberOfPages>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['statistics']['pages']).to eq(42)
    end

    it "must extract page count by short code" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <product>
          <b061>125</b061>
        </product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['statistics']['pages']).to eq(125)
    end

    it "must extract page count from extent" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Extent>
            <ExtentType>00</ExtentType>
            <ExtentValue>12</ExtentValue>
            <ExtentUnit>03</ExtentUnit>
          </Extent>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['statistics']['pages']).to eq(12)
    end

    it "must extract page count from extent (main content count)" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Extent>
            <ExtentType>00</ExtentType>
            <ExtentValue>12</ExtentValue>
            <ExtentUnit>03</ExtentUnit>
          </Extent>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['statistics']['pages']).to eq(12)
    end

    it "must extract page count from extent (print pages)" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Extent>
            <ExtentType>08</ExtentType>
            <ExtentValue>13</ExtentValue>
            <ExtentUnit>03</ExtentUnit>
          </Extent>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['statistics']['pages']).to eq(13)
    end

    it "must extract page count from extent (digital pages)" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Extent>
            <ExtentType>10</ExtentType>
            <ExtentValue>12</ExtentValue>
            <ExtentUnit>03</ExtentUnit>
          </Extent>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['statistics']['pages']).to eq(12)
    end

    it "must ensure physical pages takes precidence" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Extent>
            <ExtentType>08</ExtentType>
            <ExtentValue>9</ExtentValue>
            <ExtentUnit>03</ExtentUnit>
          </Extent>
          <Extent>
            <ExtentType>10</ExtentType>
            <ExtentValue>13</ExtentValue>
            <ExtentUnit>03</ExtentUnit>
          </Extent>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['statistics']['pages']).to eq(9)
    end

    it "must raise failure for non-numeric extents" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Extent>
            <ExtentType>08</ExtentType>
            <ExtentValue>s</ExtentValue>
            <ExtentUnit>03</ExtentUnit>
          </Extent>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(failures.size).to eq(1)
      failure = failures.first
      expect(failure[:error_code]).to eq("InvalidExtent")
      expect(failure[:data][:extent]).to eq("s")
    end
  end
end