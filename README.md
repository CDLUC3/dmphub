# DMPHub

[![Actions Status](https://github.com/CDLUC3/dmphub/actions/workflows/brakeman-analysis/badge.svg)](https://github.com/CDLUC3/dmphub/actions)
[![Actions Status](https://github.com/CDLUC3/dmphub/actions/workflows/rubocop-analysis/badge.svg)](https://github.com/CDLUC3/dmphub/actions)
[![Actions Status](https://github.com/CDLUC3/dmphub/actions/workflows/rspec-tests/badge.svg)](https://github.com/CDLUC3/dmphub/actions)

This repository covers work on a machine actionable DMP hub, from work funded by an NSF EAGER grant (https://www.nsf.gov/awardsearch/showAward?AWD_ID=1745675&HistoricalAwards=false). This 'Hub' application provides the following services:

1) Allows DMPs to be 'registered' via an API call (in the illustration below this is repredented by a system based off of the [DMPRoadmap](https://github.com/DMPRoadmap/roadmap) codebase). For an example of how the DMPRoadmap codebase interacts with the Hub, please refer to the `app/services/external_apis/dmphub.rb` service.
2) This registration process mints an EZID DOI for the DMP and returns that DOI back to the system that has registered their DMP.
3) Once the DMP has been registered, its DOI resolves to a landing page that is hosted by the Hub. This landing page has an HTML version for humans wishing to view the DMP's metadata as well as a JSON version for machines wishing to make use of the metadata
4) Provides API endpoints that allow other external systems to gather pertinent DMP metadata and enrich that metadata. In our example we use a [simple application](https://github.com/CDLUC3/nsf_award_scanner) that harvests award information from the NSF Awards API. The harvester app receives a list of DMP metadata and then searches the awards API for matching awards. If any are found it sends that information back to the hub.
5) The Hub then amends the EZID metadata record with the award information found in sstep 4.

![](public/topology.jpg)

## Feedback

We welcome any and all feedback. Please use Github Issues to provide suggestions or to report a bug, and a PR if if you wish to contribute.

## Requirements
- ruby 2.6.6

## Installation

- Clone this repository
- Generate your credentials by running `EDITOR=vi rails credentials:edit` which will open the default credentials file. Copy the contents of that file and then run `EDITOR=vi rails credentials:edit -e development` and once again for 'production' and any other environments you want to support. Paste the default credentials into these new files and update the content accordingly. This will generate 2 files per environment and place them in `config/credentials/`. By default, the `config/credentials/[environment].key` files are ignored by github. You will need to make sure you store these keys in a secure place and then copy them into the directory when you deploy.
- Run `bundle install`
- Run `yarn install`
- Run `bundle exec rake db:setup`
- Run `bundle exec rake initialize:all`. This will generate the super user account (forthcoming) and an API client account for the DMPHub itself, a DMPRoadmap application and the NSF awards scanning service
- Run `rails s` to start the application and then run to `http://localhost:3000/api/v0/heartbeat` to ensure that the site is functional. You can also visit http://localhost:3000 to see the empty landing page.
- Then follow the API instructions in the Wiki to start adding DMPs

## API

Every application/user that wishes to use the DMPHub API must have an account registered within the system. To register an application you will need to add an entry into the following tables:
- `api_clients` this is the primary API Client table. The name of the client should be lower case.
- `provenances` this table is used to relate an entry in one of the DMP tables to the API Client. The `name` must match the one in the `api_clients` table.
- `api_client_permissions` an entry for each type of permission the client is allowed to perform should be added here. See the enum on the ApiClientPermission model for a list of possible permissions.

At some point in the near future we will be adding an Admin login that will include a UI page that allows you to perform these actions via the website.

### Authorization

```shell
curl -v -X POST http://localhost:3000/api/v0/authenticate
  -H "Content-Type: application/json"
  -H "Accept: application/json"
  -d "grant_type=client_credentials&client_id=[my application uid]&client_secret=[my application secret]"
```

Returns 40x errors when you send invalid credentials, are unauthorized or your token has expired Unauthorized

Returns a 200 and the authorization token as JSON like the following when successful:
```json
{
  "access_token":"eyJhbGciOiJIUzI1NiJ9.eyJjbGllbnRfaWQiOiJKeWJ3UHEzeHphZ1pBRGUtSUNTUWxtVEhsT1FLRnplNllmZ1pIOFhMSm5VIiwiZXhwIjoxNjAxNDE4Mzc1fQ.GUxmND3qEY9RACn7Oq1N0mhg1p0M7Z3PuV-vDZOabZg",
  "token_type":"Bearer",
  "expires_in":1601418375,
  "created_at":"2020-09-28T22:26:15:00Z"
}
````

This token should then be passed along with a Server-Agent in the Headers of all subsequent requests to the API as follows:
```shell
-H "Content-Type: application/json"
-H "Accept: application/json"
-H "User-Agent: [api_clients.name] ([api_clients.client_id])"
-H "Authorization: Bearer [token]"
```
For example:
```shell
curl -v http://localhost:3000/api/v0/data_management_plans
-H "Content-Type: application/json"
-H "Accept: application/json"
-H "User-Agent: dmphub (1234567890)"
-H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJjbGllbnRfaWQiOiJKeWJ3UHEzeHphZ1pBRGUtSUNTUWxtVEhsT1FLRnplNllmZ1pIOFhMSm5VIiwiZXhwIjoxNjAxNDE4Mzc1fQ.GUxmND3qEY9RACn7Oq1N0mhg1p0M7Z3PuV-vDZOabZg"
```

### Retrieve a list of DMPs associated with your application

Results are returned as a subset of the [JSON in the RDA Common Standard format](https://github.com/CDLUC3/dmphub/blob/master/spec/support/mocks/complete_common_standard.json). The response contains the DMP's title, DOI and other high level information that would be relevant in helping you identify records.

Note that each DMP's JSON contains an "extension -> dmphub -> links" array which contains all of the available REST API calls for that DMP. You can use the 'get' link to retrieve the full metadata for that DMP (see below for an example of the full metadata record).

When there are multiple pages of results, you can use the "next" and "prev" links returned in the top level of the JSON response.

See above for the appropriate HTTP headers to send along with your request
`curl -v http://localhost:3000/api/v0/data_management_plans`

This will return a `404 Not Found` for invalid or unauthorized requests.

If successful it will return a list of your Data Management Plans and their primary contact as JSON. For example:
```javascript
{
  "application": "dmphub",
  "status": "OK",
  "code": 200,
  "time": "2020-09-28T22:33:25:00Z",
  "caller": "dmphub",
  "source": "GET https://dmphub-stg.cdlib.org/api/v0/data_management_plans",
  "page": 2,
  "per_page": 20,
  "total_items": 63,
  "prev": "https://dmphub-stg.cdlib.org/api/v0/data_management_plans?page=1",
  "next": "https://dmphub-stg.cdlib.org/api/v0/data_management_plans?page=3",
  "items": [
    {
      "dmp": {
        "schema":"https://github.com/RDA-DMP-Common/RDA-DMP-Common-Standard/tree/master/examples/JSON/JSON-schema/1.0",
        "title": "My sample DMP",
        "created": "2020-08-27T16:01:58:00Z",
        "modified": "2020-08-27T16:01:58:00Z",
        "dmp_id": {
          "type": "DOI",
          "identifier": "https://doi.org/10.0000/AB12CD34"
        },
        "contact": {
          "name": "Jane Doe",
          "affiliation":{
            "name": "Some University",
            "affiliation_id": {
              "type": "ROR",
              "identifier": "https://ror.org/0000001"
            }
          }
        },
        "extension": {
          "dmphub": {
            "links": [
              {
                "post": "http://localhost:3000/api/v0/data_management_plans/",
                "get": "http://localhost:3000/api/v0/data_management_plans/doi:10.5072/FK2CZ39S49",
                "put": "http://localhost:3000/api/v0/data_management_plans/doi:10.5072/FK2CZ39S49",
                "delete": "http://localhost:3000/api/v0/data_management_plans/doi:10.5072/FK2CZ39S49"
              }
            ]
          }
        }
      }
    },
    {
      "dmp": "..."
    }
  ]
}
````

### Retrieve a specific DMP by its DOI

The DMP is returned as [JSON in the RDA Common Standard format](https://github.com/CDLUC3/dmphub/blob/master/spec/support/mocks/complete_common_standard.json). Note that the example below contains a complete metadata record. The DMP you are retrieving may not contain all elements from the common standard. In situations where no data is available for a particular field, then it is omitted from the JSON. For example if your DMP's dataset has no distribution information, then the distribution portion of the record will not appear in the JSON response.


See above for the appropriate HTTP headers to send along with your request (be sure to include the `doi:` prefix)
`curl -v http://localhost:3000/api/v1/data_management_plans/doi:10.0000/AB12CD34`

This will return a 404 not found if the DMP does not exist or if you are unauthorized to retrieve it.
```javascript
{
  "application": "dmphub",
  "status": "OK",
  "code": 200,
  "time": "2020-09-28T22:44:19:00Z",
  "caller": "dmphub",
  "source": "GET https://dmphub-stg.cdlib.org/api/v0/data_management_plans/10.0000/AB12CD34",
  "page": 1,
  "per_page": 20,
  "total_items": 1,
  "items": [
    {
      "dmp": {
        "schema": "https://github.com/RDA-DMP-Common/RDA-DMP-Common-Standard/tree/master/examples/JSON/JSON-schema/1.0",
        "title": "Sample DMP",
        "description": "An abstract for our sample data management plan.",
        "created": "2020-08-27T16:01:58:00Z",
        "modified": "2020-08-27T16:01:58:00Z",
        "language": "eng",
        "ethical_issues_exist": "yes",
        "ethical_issues_description": "Our datasets will be based off of patient information",
        "ethical_issues_report": "https://some.uni.org/privacy_policy.html",
        "dmp_id": {
          "type": "DOI",
          "identifier": "https://doi.org/10.0000/AB12CD34"
        },
        "contact": {
          "name": "Jane Doe",
          "mbox": "jane.doe@sample.edu",
          "contact_id": {
            "type": "ORCID",
            "identifier": "https://orcid.org/0000-0000-0000-0000"
          },
          "affiliation": {
            "name": "Some University",
            "affiliation_id": {
              "type": "ROR",
              "identifier": "https://ror.org/000000"
            }
          }
        },
        "contributor": [
          {
            "name": "John Doe",
            "mbox":"john.doe@another.edu",
            "affiliation": {
              "name": "Another University",
              "affiliation_id": {
                "type": "ROR",
                "identifier": "https://ror.org/000009"
              }
            },
            "contributor_id": {
              "type": "ORCID",
              "identifier": "https://orcid.org/0000-0000-0000-000X"
            },
            "role": [
              "https://dictionary.casrai.org/Contributor_Roles/Data_curation",
              "https://dictionary.casrai.org/Contributor_Roles/Investigation"
            ]
          }
        ],
        "cost": [
          {
            "currency_code": "USD",
            "title": "Long term server storage",
            "description": "The cost of storing the research outputs for preservation",
            "value": 10500
          }
        ],
        "project": [
          {
            "title": "Sample DMP project",
            "description": "An abstract describing what this project is about.",
            "start": "2020-08-27T15:14:09:00Z",
            "end": "2022-08-27T15:14:09:00Z",
            "funding": [
              {
                "name": "National Science Foundation (NSF)",
                "funder_id": {
                  "type": "ROR",
                  "identifier": "https://ror.org/00000X"
                },
                "funding_status": "granted",
                "grant_id": {
                  "type": "URL",
                  "identifier": "https://nsf.org/awards/123abc"
                },
                "extension": {
                  "dmphub": {
                    "funded_affiliations": [
                      {
                        "name": "Another University",
                        "affiliation_id": {
                          "type": "ROR",
                          "identifier": "https://ror.org/000009"
                        }
                      }
                    ]
                  }
                }
              }
            ]
          }
        ],
        "dataset": [
          {
            "title": "Dataset: Sample dataset A",
            "type": "dataset",
            "personal_data": "unknown",
            "sensitive_data": "unknown",
            "data_quality_assurance": "Our data will be of very high quality!",
            "dataset_id": {
              "type": "DOI",
              "identifier": "https://doix.org/10.1234.123abc/y3"
            },
            "description": "A collection of MRI scans of cerebral cortex for all candidates",
            "distribution": [
              {
                "title": "Open access copy of Dataset A",
                "access_url": "https://secure.repo.org/dataset/12345",
                "available_until": "2050-01-01",
                "byte_size": 10000,
                "data_access": "open",
                "description": "Open access copy of the dataset",
                "download_url": "https://secure.repo.org/dataset/12345.pdf",
                "format": "image/tiff",
                "host": {
                  "title": "Dryad",
                  "availability": "99,5",
                  "backup_frequency": "weekly",
                  "backup_type": "tapes",
                  "certified_with": "coretrustseal",
                  "description": "Merritt repository via Dryad",
                  "geo_location": "US",
                  "pid_system": "doi",
                  "storage_type": "AWS cloud disk",
                  "support_versioning": "yes",
                  "url": "https://datadryad.org"
                },
                "license": [
                  {
                    "license_ref": "https://creativecommons.org/licenses/by/4.0/",
                    "start_date": "2019-06-30"
                  }
                ]
              }
            ],
            "issued": "2020-09-13T08:48:12",
            "keyword": ["brain", "cerebral", "squishy"],
            "language": "eng",
            "metadata": [
              {
                "description": "Some biological sample standard",
                "language": "eng",
                "metadata_standard_id": {
                  "type": "url",
                  "identifier": "https://some.standard.org/biology"
                }
              }
            ],
            "preservation_statement": "We will preserve the data long term.",
            "security_and_privacy": [
              {
                "title": "Patient personal information",
                "description": "We are going to anonymize all of the patient personal info"
              }
            ],
            "technical_resource": [
              {
                "title": "123/45/43/AT",
                "description": "MRI scanner"
              }
            ]
          }
        ],
        "extension": {
          "dmphub": {
            "related_identifiers": [
              {
                "type": "URL",
                "identifier": "http://dmproadmap.site.org/api/v1/plans/12345",
                "descriptor": "is_metadata_for"
              }
            ],
            "links": [
              {
                "post": "http://localhost:3000/api/v0/data_management_plans/",
                "get": "http://localhost:3000/api/v0/data_management_plans/doi:10.5072/FK2CZ39S49",
                "put": "http://localhost:3000/api/v0/data_management_plans/doi:10.5072/FK2CZ39S49",
                "delete": "http://localhost:3000/api/v0/data_management_plans/doi:10.5072/FK2CZ39S49"
              }
            ]
          }
        }
      }
    }
  ]
}
```

### Add a DMP to the DMPHub (returns the DMP's DOI)

You should send the DMP as [JSON in the RDA Common Standard format](https://github.com/CDLUC3/dmphub/blob/master/spec/support/mocks/complete_common_standard.json). See above for an example of the JSON.

See above for the appropriate HTTP headers to send along with your request
`curl -v http://localhost:3000/api/v1/data_management_plans/10.0000/AB12CD34`

Note that you can create DMPs if you have permission to do so.

```shell
curl -v -X POST http://localhost:3000/api/v1/data_management_plans
```

If successful an HTTP 201 - 'Created' status will be returned along with the full RDA Common Standard JSON for the DMP. Note that the `dmp_id` attribute will contain the new DMP ID (DOI) for your DMP.

If there is an issue with the JSON format, or a required attribute is missing then you will receive a 400 'Bad Request' response from the system with information about what the issue was in the 'errors' array. For example:
```json
{
  "application": "dmphub",
  "status": "Bad Request",
  "code": 400,
  "time": "2020-09-28T22:44:19:00Z",
  "caller": "dmphub",
  "source": "POST https://dmphub-stg.cdlib.org/api/v0/data_management_plans",
  "page": 1,
  "per_page": 20,
  "total_items": 0,
  "items": [],
  "errors": ["Invalid JSON format", "DataManagementPlan - title cannot by blank"]
}
```

### Update a DMP

You should send the full DMP as [JSON in the RDA Common Standard format](https://github.com/CDLUC3/dmphub/blob/master/spec/support/mocks/complete_common_standard.json). See above for an example of the JSON. Note that you should use the DMP ID (DOI) in the URL.

See above for the appropriate HTTP headers to send along with your request
`curl -v http://localhost:3000/api/v1/data_management_plans/10.0000/AB12CD34`

Note that you can only update DMPs that you have created or have been given permission to edit.

```shell
curl -v -X PUT http://localhost:3000/api/v1/data_management_plans/10.123/123ABC00
```

If successful an HTTP 200 - 'Success' status will be returned along with the full RDA Common Standard JSON for the DMP (See above for an example). Note that the `dmp_id` attribute will contain the new DMP ID (DOI) for your DMP.

If there is an issue with the JSON format, or a required attribute is missing then you will receive a 400 'Bad Request' response from the system with information about what the issue was in the 'errors' array. For example:
```json
{
  "application": "dmphub",
  "status": "Bad Request",
  "code": 400,
  "time": "2020-09-28T22:44:19:00Z",
  "caller": "dmphub",
  "source": "PUT https://dmphub-stg.cdlib.org/api/v0/data_management_plans/10.0000/AB12CD34",
  "page": 1,
  "per_page": 20,
  "total_items": 0,
  "items": [],
  "errors": ["Invalid JSON format", "DataManagementPlan - title cannot by blank"]
}
```

### Delete a DMP

You should send the full DMP as [JSON in the RDA Common Standard format](https://github.com/CDLUC3/dmphub/blob/master/spec/support/mocks/complete_common_standard.json). See above for an example of the JSON. Note that you should use the DMP ID (DOI) in the URL.

See above for the appropriate HTTP headers to send along with your request
`curl -v http://localhost:3000/api/v1/data_management_plans/10.0000/AB12CD34`

Note that you can only delete DMPs that you have created or have been given permission to edit.

```shell
curl -v -X PUT http://localhost:3000/api/v1/data_management_plans/10.123/123ABC00
```

If successful an HTTP 200 - 'Success' status will be returned along with the full RDA Common Standard JSON for the DMP. Note that the `dmp_id` attribute will contain the new DMP ID (DOI) for your DMP.
```json
{
  "application": "dmphub",
  "status": "Success",
  "code": 200,
  "time": "2020-09-28T22:44:19:00Z",
  "caller": "dmphub",
  "source": "DELETE https://dmphub-stg.cdlib.org/api/v0/data_management_plans/10.0000/AB12CD34",
  "page": 1,
  "per_page": 20,
  "total_items": 0,
  "items": []
}
```

If you do not have the authority to delete the DMP, or it could not be found, you will receive a 404 'Not Found' response.
```json
{
  "application": "dmphub",
  "status": "Not Found",
  "code": 404,
  "time": "2020-09-28T22:44:19:00Z",
  "caller": "dmphub",
  "source": "DELETE https://dmphub-stg.cdlib.org/api/v0/data_management_plans/10.0000/AB12CD34",
  "page": 1,
  "per_page": 20,
  "total_items": 0,
  "items": [],
  "errors": []
}
```

### Provisioning with Puppet

Increment the git tag on the project repo and push the new tag
to the remote:

```shell
dmphub> git status

dmphub> git tag -am'dev release 0.0.1' 0.0.1
dmphub> git push origin --tags
```

Edit puppet hiera data:

```shell
~/puppet/uc3/data/fqsn> vi uc3-dmp-hub-prd.yaml
~/puppet/uc3/data/fqsn> git diff .
diff --git a/data/fqsn/uc3-dmp-hub-prd.yaml b/data/fqsn/uc3-dmp-hub-prd.yaml
index c6032c1..c08592f 100644
--- a/data/fqsn/uc3-dmp-hub-prd.yaml
+++ b/data/fqsn/uc3-dmp-hub-prd.yaml
@@ -5,6 +5,6 @@ uc3_dmphub::dmphub::config:
     app_name: "dmphub"
     ensure: "running"
     git_repo: "https://github.com/cdluc3/dmphub.git"
-    revision: "0.0.0dev11"
+    revision: "0.0.1"
     cap_environment: "%{lookup('fqsn')}"
     rails_env: 'production'
~/puppet/uc3/data/fqsn> git commit -am'increment revision of dmphub in prod'
```

Depending on your access rights in puppet, either push your commit to IAS
puppet master, or request uc3ops folks to do it for you:
