descriptor = ReaderExamples.add "contributors"

RSpec.shared_examples descriptor do
  describe "while reading #{descriptor}" do
    it "must extract contributor display name" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <PersonName>Valentine Cunningham</PersonName>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect(book["contributors"].size).to eq(1)
      expect(book["contributors"].first["names"]["display"]).to eq("Valentine Cunningham")
    end

    it "must remove extra whitespace from display names" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <PersonName> Valentine Cunningham </PersonName>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect(book["contributors"].size).to eq(1)
      expect(book["contributors"].first["names"]["display"]).to eq("Valentine Cunningham")
    end

    it "must extract contributor sort name" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <PersonNameInverted>Cunningham, Valentine</PersonNameInverted>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect(book["contributors"].size).to eq(1)
      expect(book["contributors"].first["names"]["sort"]).to eq("Cunningham, Valentine")
    end

    it "must extract contributor role" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <ContributorRole>A01</ContributorRole>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect(book["contributors"].size).to eq(1)
      expect(book["contributors"].first["role"]).to eq("A01")
    end

    it "must ingest the NoContributor tag" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <NoContributor/>
        </Product>
      </ONIXmessage>
      XML
      expect(book["contributors"].size).to eq(0)
    end

    it "must extract corporate name as a contributor name" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <CorporateName>Top Gear</CorporateName>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect(book["contributors"].size).to eq(1)
      expect(book["contributors"].first["names"]["display"]).to eq("Top Gear")
    end

    it "must extract component names" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <TitlesBeforeNames>TitlesBeforeNames</TitlesBeforeNames>
            <PrefixToKey>PrefixToKey</PrefixToKey>
            <NamesBeforeKey>NamesBeforeKey</NamesBeforeKey>
            <KeyNames>KeyNames</KeyNames>
            <NamesAfterKey>NamesAfterKey</NamesAfterKey>
            <SuffixToKey>SuffixToKey</SuffixToKey>
            <LettersAfterNames>LettersAfterNames</LettersAfterNames>
            <TitlesAfterNames>TitlesAfterNames</TitlesAfterNames>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect(book["contributors"].size).to eq(1)
      expect(book["contributors"].first["names"]["titlesBeforeNames"]).to eq("TitlesBeforeNames")
      expect(book["contributors"].first["names"]["namesBeforeKey"]).to eq("NamesBeforeKey")
      expect(book["contributors"].first["names"]["prefixToKey"]).to eq("PrefixToKey")
      expect(book["contributors"].first["names"]["namesBeforeKey"]).to eq("NamesBeforeKey")
      expect(book["contributors"].first["names"]["keyNames"]).to eq("KeyNames")
      expect(book["contributors"].first["names"]["namesAfterKey"]).to eq("NamesAfterKey")
      expect(book["contributors"].first["names"]["suffixToKey"]).to eq("SuffixToKey")
      expect(book["contributors"].first["names"]["lettersAfterNames"]).to eq("LettersAfterNames")
      expect(book["contributors"].first["names"]["titlesAfterNames"]).to eq("TitlesAfterNames")
    end

    it "must extract basic display and sort names from component names" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <NamesBeforeKey>Charles and Mary</NamesBeforeKey>
            <KeyNames>Lamb</KeyNames>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect(book["contributors"].size).to eq(1)
      expect(book["contributors"].first["names"]["display"]).to eq("Charles and Mary Lamb")
      expect(book["contributors"].first["names"]["sort"]).to eq("Lamb, Charles and Mary")
      expect(book["contributors"].first["names"]["namesBeforeKey"]).to eq("Charles and Mary")
      expect(book["contributors"].first["names"]["keyNames"]).to eq("Lamb")
    end

    it "must take given display and sort names in preference to generated ones" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <PersonName>Valentine Cunningham</PersonName>
            <PersonNameInverted>Cunningham, Valentine</PersonNameInverted>
            <NamesBeforeKey>Charles and Mary</NamesBeforeKey>
            <KeyNames>Lamb</KeyNames>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect(book["contributors"].size).to eq(1)
      expect(book["contributors"].first["names"]["display"]).to eq("Valentine Cunningham")
      expect(book["contributors"].first["names"]["sort"]).to eq("Cunningham, Valentine")
      expect(book["contributors"].first["names"]["namesBeforeKey"]).to eq("Charles and Mary")
      expect(book["contributors"].first["names"]["keyNames"]).to eq("Lamb")
    end

    it "must extract name information from within CDATA tags" do
      book = process_xml_with_service <<-XML
      <onixmessage>
        <product>
          <contributor>
            <b035>A01</b035>
            <b036><![CDATA[Cliff Sloan]]></b036>
            <b037><![CDATA[Sloan, Cliff 'I have a weird sort name']]></b037>
            <b039><![CDATA[Cliff]]></b039>
            <b040><![CDATA[Sloan]]></b040>
          </contributor>
        </product>
      </onixmessage>
      XML
      expect(book["contributors"].size).to eq(1)
      expect(book["contributors"].first["names"]["display"]).to eq("Cliff Sloan")
      expect(book["contributors"].first["names"]["sort"]).to eq("Sloan, Cliff 'I have a weird sort name'")
      expect(book["contributors"].first["names"]["namesBeforeKey"]).to eq("Cliff")
      expect(book["contributors"].first["names"]["keyNames"]).to eq("Sloan")
    end

    it "must extract biographies" do
      book = process_xml_with_service <<-XML
      <ONIXmessage>
        <Product>
          <Contributor>
            <BiographicalNote>A biography</BiographicalNote>
          </Contributor>
        </Product>
      </ONIXmessage>
      XML
      expect(book["contributors"].size).to eq(1)
      expect(book["contributors"].first["biography"]).to eq("A biography")
    end
  end
end