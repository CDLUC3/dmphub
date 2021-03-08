# frozen_string_literal:  true

module Mocks
  # Module for mocking result from the ROR API
  # Using the top 3 results from: https://api.ror.org/organizations?query=Berkeley
  # rubocop:disable Metrics/ModuleLength
  module Ror

    def mock_ror_calls
      stub_request(:get, "https://api.ror.org/heartbeat")
        .to_return(status: 200, body: "", headers: {})

      stub_request(:get, /ror\.org\/organizations/)
        .to_return(status: 200, body: mock_ror_success, headers: {})
    end

    # rubocop:disable Metrics/MethodLength
    def mock_ror_success
      {
        'number_of_results': 17,
        'time_taken': 22,
        'items': [
          {
            'id': 'https://ror.org/02xewxa75',
            'name': 'Berkeley College',
            'types': ['Education'],
            'links': ['http://berkeleycollege.edu/'],
            'aliases': [],
            'acronyms': [],
            'status': 'active',
            'wikipedia_url': 'https://en.wikipedia.org/wiki/Berkeley_College',
            'labels': [],
            'country': {
              'country_name': 'United States',
              'country_code': 'US'
            },
            'external_ids': {
              'ISNI': {
                'preferred': nil,
                'all': ['0000 0004 0525 4640']
              },
              'OrgRef': {
                'preferred': '5348554',
                'all': %w[5348554 10069304]
              },
              'Wikidata': {
                'preferred': nil,
                'all': ['Q2897191']
              },
              'GRID': {
                'preferred': 'grid.454604.7',
                'all': 'grid.454604.7'
              }
            }
          },
          {
            'id': 'https://ror.org/02jbv0t02',
            'name': 'Lawrence Berkeley National Laboratory',
            'types': ['Facility'],
            'links': ['http://www.lbl.gov/'],
            'aliases': ['Berkeley Lab'],
            'acronyms': %w[LBNL LBL],
            'status': 'active',
            'wikipedia_url': 'https://en.wikipedia.org/wiki/Lawrence_Berkeley_National_Laboratory',
            'labels': [
              {
                'label': 'Laboratoire national lawrence-berkeley',
                'iso639': 'fr'
              }
            ],
            'country': {
              'country_name': 'United States',
              'country_code': 'US'
            },
            'external_ids': {
              'ISNI': {
                'preferred': nil,
                'all': ['0000 0001 2231 4551']
              },
              'FundRef': {
                'preferred': nil,
                'all': ['100006235']
              },
              'OrgRef': {
                'preferred': nil,
                'all': ['62214']
              },
              'Wikidata': {
                'preferred': 'Q1133630',
                'all': %w[Q1133630 Q4686229]
              },
              'GRID': {
                'preferred': 'grid.184769.5',
                'all': 'grid.184769.5'
              }
            }
          },
          {
            'id': 'https://ror.org/01an7q238',
            'name': 'University of California, Berkeley',
            'types': ['Education'],
            'links': ['http://www.berkeley.edu/'],
            'aliases': ['UC Berkeley'],
            'acronyms': ['UCB'],
            'status': 'active',
            'wikipedia_url': 'http://en.wikipedia.org/wiki/University_of_California,_Berkeley',
            'labels': [
              {
                'label': 'UniversitÃ© de Californie Ã  Berkeley',
                'iso639': 'fr'
              },
              {
                'label': 'Universidad de California en Berkeley',
                'iso639': 'es'
              },
              {
                'label': 'University of California, Berkeley',
                'iso639': 'en'
              }
            ],
            'country': {
              'country_name': 'United States',
              'country_code': 'US'
            },
            'external_ids': {
              'ISNI': {
                'preferred': nil,
                'all': ['0000 0001 2181 7878']
              },
              'FundRef': {
                'preferred': '100006978',
                'all': %w[100006978 100010556 100010501 100009773 100009999 100009998 100007502]
              },
              'OrgRef': {
                'preferred': '31922',
                'all': %w[31922 6009056 4683165 4342409 25714291]
              },
              'Wikidata': {
                'preferred': nil,
                'all': ['Q168756']
              },
              'GRID': {
                'preferred': 'grid.47840.3f',
                'all': 'grid.47840.3f'
              }
            }
          },
          {
            'id': 'https://ror.org/00b6wzg36',
            'name': 'Acupuncture & Integrative Medicine College',
            'types': ['Education'],
            'links': ['http://aimc.edu/'],
            'aliases': ['AIMC Berkeley'],
            'acronyms': ['AIMC'],
            'status': 'active',
            'wikipedia_url': '',
            'labels': [],
            'country': {
              'country_name': 'United States',
              'country_code': 'US'
            },
            'external_ids': {
              'GRID': {
                'preferred': 'grid.465563.7',
                'all': 'grid.465563.7'
              }
            }
          }
        ]
      }.to_json
    end
    # rubocop:enable Metrics/MethodLength
  end
  # rubocop:enable Metrics/ModuleLength
end
