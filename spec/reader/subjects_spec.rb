descriptor = ReaderExamples.add "subjects"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    it "must extract BASICMainSubject" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <BASICMainSubject>LIT004120</BASICMainSubject>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['subjects'].size).to eq(1)
      subj = book['subjects'].first
      expect(subj['type']).to eq("BISAC")
      expect(subj['code']).to eq("LIT004120")
      expect(subj['main']).to eq(true)
    end

    it "must extract BASIC Subject codes" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Subject>
            <SubjectSchemeIdentifier>10</SubjectSchemeIdentifier>
            <SubjectCode>FIC029000</SubjectCode>
            <SubjectHeadingText>FICTION / Short Stories (single author)</SubjectHeadingText>
          </Subject>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['subjects'].size).to eq(1)
      subj = book['subjects'].first
      expect(subj['type']).to eq("BISAC")
      expect(subj['code']).to eq("FIC029000")
    end

    it "must extract BIC Main Subject codes" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <product>
          <mainsubject>
            <b191>12</b191>
            <b069>FH</b069>
            <b070>Fiction and related items / Thriller / suspense</b070>
          </mainsubject>
        </product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['subjects'].size).to eq(1)
      subj = book['subjects'].first
      expect(subj['type']).to eq("BIC")
      expect(subj['code']).to eq("FH")
      expect(subj['main']).to eq(true)

    end

    it "must extract BIC Subject codes" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Subject>
            <SubjectSchemeIdentifier>12</SubjectSchemeIdentifier>
            <SubjectCode>FYB</SubjectCode>
            <SubjectHeadingText>Short Stories</SubjectHeadingText>
          </Subject>
        </Product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['subjects'].size).to eq(1)
      subj = book['subjects'].first
      expect(subj['type']).to eq("BIC")
      expect(subj['code']).to eq("FYB")
    end

    it "must extract keywords with HTML encoded characters" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <product>
          <mainsubject>
            <b191>20</b191>
            <b070>Country Life &amp; Pets</b070>
          </mainsubject>
        </product>
      </ONIXmessage>
      XML
      expect_schema_compliance(book)
      expect(book['subjects'].size).to eq(1)
      subj = book['subjects'].first
      expect(subj['type']).to eq("Keyword")
      expect(subj['code']).to eq("Country Life & Pets")
    end

    [",", ";", ", ", "; "].each do |delim|
      it "must extract keywords delimited by #{delim.inspect}" do
        words = ["Antony Beevor", "The Second World War", "Berlin", "D-Day"]
        book = process_xml_with_service <<-XML
        <ONIXmessage>
          <product>
            <mainsubject>
              <b191>20</b191>
              <b070>#{words.join(delim)}</b070>
            </mainsubject>
          </product>
        </ONIXmessage>
        XML
        expect_schema_compliance(book)
        expect(book['subjects'].size).to eq(words.size)
        book['subjects'].each do |subj|
          expect(subj['type']).to eq("Keyword")
          expect(words).to include(subj['code']), "The code #{subj['code'].inspect} was in the parsed subjects, but not in the ONIX"
          words.delete(subj['code'])
        end
        expect(words)
      end
    end
  end
end