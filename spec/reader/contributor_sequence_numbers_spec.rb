descriptor = ReaderExamples.add "contributor sequence numbers"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    it "must extract contributor sequence numbers" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <PersonName>Valentine Cunningham</PersonName>
            <ContributorRole>A01</ContributorRole>
            <SequenceNumber>1</SequenceNumber>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["contributors"].size).to eq(1)
      c = book["contributors"].first
      expect(c["seq"]).to eq(1)
    end

    it "must extract multiple contributor sequence numbers" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <PersonName>Author 1</PersonName>
            <ContributorRole>A01</ContributorRole>
            <SequenceNumber>1</SequenceNumber>
          </Contributor>
          <Contributor>
            <PersonName>Author 2</PersonName>
            <ContributorRole>A01</ContributorRole>
            <SequenceNumber>2</SequenceNumber>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["contributors"].size).to eq(2)
      contributors = Hash[book["contributors"].map { |c|
        [c['seq'], c]
      }]
      expect(contributors[1]["names"]["display"]).to eq("Author 1")
      expect(contributors[2]["names"]["display"]).to eq("Author 2")
    end

    it "must infer contributor sequence numbers from implicit ordering" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <PersonName>Author 1</PersonName>
            <ContributorRole>A01</ContributorRole>
          </Contributor>
          <Contributor>
            <PersonName>Author 2</PersonName>
            <ContributorRole>A01</ContributorRole>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book["contributors"].size).to eq(2)
      contributors = Hash[book["contributors"].map { |c|
        expect(c).to have_key('seq')
        [c['seq'], c]
      }]
      expect(contributors[1]["names"]["display"]).to eq("Author 1")
      expect(contributors[2]["names"]["display"]).to eq("Author 2")
    end

    it "must raise failure if there are missing sequences" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <PersonName>Author 1</PersonName>
            <ContributorRole>A01</ContributorRole>
            <SequenceNumber>1</SequenceNumber>
          </Contributor>
          <Contributor>
            <PersonName>Author 2</PersonName>
            <ContributorRole>A01</ContributorRole>
            <SequenceNumber>3</SequenceNumber>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(failures.size).to eq(1)
      failure = failures.first
      expect(failure[:error_code]).to eq("IncorrectContributorSequenceNumbers")
      expect(failure[:data][:sequence_numbers]).to eq([1, 3])
      expect(book["contributors"].size).to eq(2)
      contributors = Hash[book["contributors"].map { |c|
        [c['seq'], c]
      }]
      expect(contributors[1]["names"]["display"]).to eq("Author 1")
      expect(contributors[3]["names"]["display"]).to eq("Author 2")
    end

    it "must infer implicit sequence numbers with conflicting explicit numbers" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <PersonName>Author 1</PersonName>
            <ContributorRole>A01</ContributorRole>
            <SequenceNumber>1</SequenceNumber>
          </Contributor>
          <Contributor>
            <PersonName>Author 2</PersonName>
            <ContributorRole>A01</ContributorRole>
            <SequenceNumber>1</SequenceNumber>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(failures.size).to eq(1)
      failure = failures.first
      expect(failure[:error_code]).to eq("IncorrectContributorSequenceNumbers")
      expect(failure[:data][:sequence_numbers]).to eq([1, 1])
      expect(book["contributors"].size).to eq(2)
      expect(book["contributors"].map{ |c| c['seq'] }).to eq([1, 1])
    end
  end
end