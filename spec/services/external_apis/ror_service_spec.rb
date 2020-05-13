# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::RorService do
  include Mocks::Ror

  describe '#ping' do
    before(:each) do
      @headers = described_class.headers
      @heartbeat = URI("#{described_class.api_base_url}#{described_class.heartbeat_path}")
    end
    it 'returns true if an HTTP 200 is returned' do
      stub_request(:get, @heartbeat).with(headers: @headers)
                                    .to_return(status: 200, body: '', headers: {})
      expect(described_class.ping).to eql(true)
    end
    it 'returns false if an HTTP 200 is NOT returned' do
      stub_request(:get, @heartbeat).with(headers: @headers)
                                    .to_return(status: 404, body: '', headers: {})
      expect(described_class.ping).to eql(false)
    end
  end

  describe '#search' do
    before(:each) do
      @headers = described_class.headers
      @search = URI("#{described_class.api_base_url}#{described_class.search_path}")
      @heartbeat = URI("#{described_class.api_base_url}#{described_class.heartbeat_path}")
      stub_request(:get, @heartbeat).with(headers: @headers).to_return(status: 200)
    end

    it 'returns nil if term is blank' do
      expect(described_class.search(term: nil)).to eql(nil)
    end

    context 'ROR did not return a 200 status' do
      before(:each) do
        @term = Faker::Lorem.word
        uri = "#{@search}?page=1&query=#{@term}"
        stub_request(:get, uri).with(headers: @headers)
                               .to_return(status: 404, body: '', headers: {})
      end
      it 'returns nil' do
        expect(described_class.search(term: @term)).to eql(nil)
      end
      it 'logs the response as an error' do
        allow(described_class).to receive(:handle_http_failure).and_return(true)
        described_class.search(term: @term)
        expect(described_class).to have_received(:handle_http_failure)
      end
    end

    it 'returns nil if ROR found no matches' do
      results = {
        'number_of_results': 0,
        'time_taken': 23,
        'items': [],
        'meta': { 'types': [], 'countries' => [] }
      }
      term = Faker::Lorem.word
      uri = "#{@search}?page=1&query=#{term}"
      stub_request(:get, uri).with(headers: @headers)
                             .to_return(status: 200, body: results.to_json, headers: {})
      expect(described_class.search(term: term)).to eql(nil)
    end

    context 'Successful response from API' do
      before(:each) do
        @results = JSON.parse(mock_success).with_indifferent_access
      end

      it 'returns nil if the ROR results had no exact match on the name' do
        term = 'Berkeley'
        uri = "#{@search}?page=1&query=#{term}"
        stub_request(:get, uri).with(headers: @headers)
                               .to_return(status: 200, body: @results.to_json, headers: {})
        @org = described_class.search(term: term)
        expect(@org).to eql(nil)
      end
      it 'returns an existing Organization' do
        term = 'Berkeley College'
        uri = "#{@search}?page=1&query=#{term}"
        stub_request(:get, uri).with(headers: @headers)
                               .to_return(status: 200, body: @results.to_json, headers: {})
        expected = create(:organization, name: term, provenance: 'ror')
        @org = described_class.search(term: term)
        expect(@org).to eql(expected)
      end
      it 'returns a new Organization' do
        term = 'Berkeley College'
        uri = "#{@search}?page=1&query=#{term}"
        stub_request(:get, uri).with(headers: @headers)
                               .to_return(status: 200, body: @results.to_json, headers: {})
        @org = described_class.search(term: term)
        expect(@org.name).to eql(term)
        expect(@org.new_record?).to eql(true)
      end
    end
  end

  context 'private methods' do
    describe '#query_ror' do
      before(:each) do
        @results = {
          'number_of_results': 1,
          'time_taken': 5,
          'items': [{
            'id': Faker::Internet.url,
            'name': Faker::Lorem.word,
            'country': { 'country_name': Faker::Lorem.word }
          }]
        }
        @term = Faker::Lorem.word
        @headers = described_class.headers
        search = URI("#{described_class.api_base_url}#{described_class.search_path}")
        @uri = "#{search}?page=1&query=#{@term}"
      end

      it 'returns an empty array if term is blank' do
        expect(described_class.send(:query_ror, term: nil)).to eql([])
      end
      it 'calls the handle_http_failure method if a non 200 response is received' do
        stub_request(:get, @uri).with(headers: @headers)
                                .to_return(status: 403, body: '', headers: {})
        allow(described_class).to receive(:handle_http_failure).and_return(true)
        expect(described_class.send(:query_ror, term: @term)).to eql([])
        expect(described_class).to have_received(:handle_http_failure)
      end
      it 'returns the response body as JSON' do
        stub_request(:get, @uri).with(headers: @headers)
                                .to_return(status: 200, body: @results.to_json,
                                           headers: {})
        expect(described_class.send(:query_ror, term: @term)).not_to eql([])
      end
    end

    describe '#query_string' do
      it 'assigns the search term to the :query argument' do
        str = described_class.send(:query_string, term: 'Foo')
        expect(str).to eql('query=Foo&page=1')
      end
      it 'defaults the page number to 1' do
        str = described_class.send(:query_string, term: 'Foo')
        expect(str).to eql('query=Foo&page=1')
      end
      it 'assigns the page number to the :page argument' do
        str = described_class.send(:query_string, term: 'Foo', page: 3)
        expect(str).to eql('query=Foo&page=3')
      end
      it 'ignores empty filter options' do
        str = described_class.send(:query_string, term: 'Foo', filters: [])
        expect(str).to eql('query=Foo&page=1')
      end
      it 'assigns a single filter' do
        str = described_class.send(:query_string, term: 'Foo', filters: ['types:A'])
        expect(str).to eql('query=Foo&page=1&filter=types:A')
      end
      it 'assigns multiple filters' do
        str = described_class.send(:query_string, term: 'Foo', filters: [
                                     'types:A', 'country.country_code:GB'
                                   ])
        expect(str).to eql('query=Foo&page=1&filter=types:A,country.country_code:GB')
      end
    end

    describe '#process_pages' do
      before(:each) do
        allow(described_class).to receive(:max_pages).and_return(2)
        allow(described_class).to receive(:max_results_per_page).and_return(5)

        @search = URI("#{described_class.api_base_url}#{described_class.search_path}")
        @term = Faker::Lorem.word
        @headers = described_class.headers
      end

      it 'returns an empty array if json is blank' do
        rslts = described_class.send(:process_pages, term: @term, json: nil)
        expect(rslts.length).to eql(0)
      end
      it 'properly manages results with only one page' do
        items = 4.times.map do
          {
            'id': Faker::Internet.unique.url,
            'name': Faker::Lorem.word,
            'country': { 'country_name': Faker::Lorem.word }
          }
        end
        results1 = { 'number_of_results': 4, 'items': items }

        stub_request(:get, "#{@search}?page=1&query=#{@term}")
          .with(headers: @headers)
          .to_return(status: 200, body: results1.to_json, headers: {})

        json = JSON.parse({ 'items': items, 'number_of_results': 4 }.to_json)
        rslts = described_class.send(:process_pages, term: @term, json: json)

        expect(rslts.length).to eql(4)
      end
      it 'properly manages results with multiple pages' do
        items = 7.times.map do
          {
            'id': Faker::Internet.unique.url,
            'name': Faker::Lorem.word,
            'country': { 'country_name': Faker::Lorem.word }
          }
        end
        results1 = { 'number_of_results': 7, 'items': items[0..4] }
        results2 = { 'number_of_results': 7, 'items': items[5..6] }

        stub_request(:get, "#{@search}?page=1&query=#{@term}")
          .with(headers: @headers)
          .to_return(status: 200, body: results1.to_json, headers: {})
        stub_request(:get, "#{@search}?page=2&query=#{@term}")
          .with(headers: @headers)
          .to_return(status: 200, body: results2.to_json, headers: {})

        json = JSON.parse({ 'items': items[0..4], 'number_of_results': 7 }.to_json)
        rslts = described_class.send(:process_pages, term: @term, json: json)
        expect(rslts.length).to eql(7)
      end
      it 'does not go beyond the max_pages' do
        items = 12.times.map do
          {
            'id': Faker::Internet.unique.url,
            'name': Faker::Lorem.word,
            'country': { 'country_name': Faker::Lorem.word }
          }
        end
        results1 = { 'number_of_results': 12, 'items': items[0..4] }
        results2 = { 'number_of_results': 12, 'items': items[5..9] }

        stub_request(:get, "#{@search}?page=1&query=#{@term}")
          .with(headers: @headers)
          .to_return(status: 200, body: results1.to_json, headers: {})
        stub_request(:get, "#{@search}?page=2&query=#{@term}")
          .with(headers: @headers)
          .to_return(status: 200, body: results2.to_json, headers: {})

        json = JSON.parse({ 'items': items[0..4], 'number_of_results': 12 }.to_json)
        rslts = described_class.send(:process_pages, term: @term, json: json)
        expect(rslts.length).to eql(10)
      end
    end

    describe '#parse_results' do
      it 'returns an empty array if there are no items' do
        expect(described_class.send(:parse_results, json: nil)).to eql([])
      end
      it 'ignores items with no name' do
        json = { 'items': [
          { 'id': SecureRandom.uuid, 'url': Faker::Internet.url },
          { 'id': SecureRandom.uuid, 'name': Faker::Lorem.word }
        ] }.to_json
        items = described_class.send(:parse_results, json: JSON.parse(json))
        expect(items.length).to eql(1)
      end
      it 'returns the correct number of results' do
        json = { 'items': [
          { 'id': SecureRandom.uuid, 'name': Faker::Lorem.unique.word },
          { 'id': SecureRandom.uuid, 'name': Faker::Lorem.unique.word }
        ] }.to_json
        items = described_class.send(:parse_results, json: JSON.parse(json))
        expect(items.length).to eql(2)
      end
    end

    describe '#org_country(item:)' do
      it 'returns empty string if no :country is not present' do
        item = JSON.parse({ 'country': nil }.to_json)
        expect(described_class.send(:org_country, item: item)).to eql('')
      end
      it 'returns empty string if no :country[:country_name] is not present' do
        item = JSON.parse({ 'country': { country_code: 'FOO' } }.to_json)
        expect(described_class.send(:org_country, item: item)).to eql('')
      end
      it 'returns the country name' do
        name = Faker::Lorem.word
        item = JSON.parse({ 'country': { country_name: name } }.to_json)
        expect(described_class.send(:org_country, item: item)).to eql(name)
      end
    end

    describe '#org_website(item:)' do
      it 'returns nil if no :links are in the json' do
        item = JSON.parse({ 'links': nil }.to_json)
        expect(described_class.send(:org_website, item: item)).to eql(nil)
      end
      it 'returns nil if the item is nil' do
        expect(described_class.send(:org_website, item: nil)).to eql(nil)
      end
      it 'returns the domain only' do
        item = JSON.parse({ 'links': ['https://example.org/path?a=b'] }.to_json)
        expect(described_class.send(:org_website, item: item)).to eql('example.org')
      end
      it 'removes the www prefix' do
        item = JSON.parse({ 'links': ['www.example.org'] }.to_json)
        expect(described_class.send(:org_website, item: item)).to eql('example.org')
      end
    end

    describe '#gather_names(item:)' do
      it 'returns an empty array if no item is present' do
        expect(described_class.send(:gather_names, item: nil)).to eql([])
      end
      it 'returns an empty array if item is not a Hash' do
        expect(described_class.send(:gather_names, item: [])).to eql([])
      end
      it 'returns an empty array if no names are available' do
        hash = { name: Faker::Lorem.word }
        expect(described_class.send(:gather_names, item: hash)).to eql([])
      end
      it 'returns the names' do
        hash = {
          domain: Faker::Internet.url,
          aliases: [Faker::Company.unique.name, Faker::Company.unique.name],
          acronyms: [Faker::Lorem.unique.word, Faker::Lorem.unique.word],
          labels: [{ label: Faker::Company.unique.name, iso639: 'fr' }]
        }
        results = described_class.send(:gather_names, item: hash)
        expect(results.include?(hash[:domain]))
        expect(results.include?(hash[:aliases].first))
        expect(results.include?(hash[:aliases].last))
        expect(results.include?(hash[:acronyms].first))
        expect(results.include?(hash[:acronyms].last))
        expect(results.include?(hash[:labels].first[:label]))
      end
    end

    describe '#deserialize_identifier' do
      before(:each) do
        @category = Identifier.categories.keys.sample.to_s
        @value = SecureRandom.uuid
      end
      it 'returns nil if :category is not present' do
        result = described_class.send(:deserialize_identifier, category: nil, value: @value)
        expect(result).to eql(nil)
      end
      it 'returns nil if :value is not present' do
        result = described_class.send(:deserialize_identifier, category: @category, value: nil)
        expect(result).to eql(nil)
      end
      it 'returns exisiting Identifier' do
        org = create(:organization)
        identifier = create(:identifier, identifiable: org, category: @category,
                                         value: @value, provenance: 'ror')
        result = described_class.send(:deserialize_identifier, category: @category,
                                                               value: @value)
        expect(result).to eql(identifier)
      end
      it 'initializes an Identifier' do
        result = described_class.send(:deserialize_identifier, category: @category,
                                                               value: @value)
        expect(result.new_record?).to eql(true)
        expect(result.identifiable_type).to eql('Organization')
        expect(result.provenance).to eql('ror')
        expect(result.send(:"#{@category}?")).to eql(true)
        expect(result.value).to eql(@value)
      end
    end

    describe '#deserialize_organization(item:)' do
      before(:each) do
        @item = {
          ror: Faker::Internet.url,
          url: Faker::Internet.url,
          name: Faker::Movies::StarWars.planet,
          acronyms: [Faker::Lorem.unique.word],
          types: [Faker::Lorem.unique.word, Faker::Lorem.unique.word],
          domain: Faker::Internet.url,
          country: Faker::Movies::StarWars.planet,
          abbreviation: Faker::Lorem.word.upcase
        }
      end
      it 'returns nil if :item is not present' do
        result = described_class.send(:deserialize_organization, item: nil)
        expect(result).to eql(nil)
      end
      it 'returns nil if :item[:name] is not present' do
        result = described_class.send(:deserialize_organization, item: {})
        expect(result).to eql(nil)
      end
      it 'returns exisiting Identifier' do
        org = create(:organization, name: @item[:name], provenance: 'ror')
        result = described_class.send(:deserialize_organization, item: @item)
        expect(result).to eql(org)
      end
      it 'initializes an Identifier' do
        result = described_class.send(:deserialize_organization, item: @item)
        expect(result.new_record?).to eql(true)
        expect(result.name).to eql(@item[:name])
        expect(result.alternate_names.include?(@item[:acronyms].first)).to eql(true)
        expect(result.alternate_names.include?(@item[:domain])).to eql(true)
        expect(result.types).to eql(@item[:types].to_s)
        expect(result.attrs['domain']).to eql(@item[:domain])
        expect(result.attrs['country']).to eql(@item[:country])
        expect(result.attrs['abbreviation']).to eql(@item[:abbreviation])
        expect(result.provenance).to eql('ror')
        expect(result.rors.first.value).to eql(@item[:ror])
        expect(result.urls.first.value).to eql(@item[:url])
      end
    end
  end
end
