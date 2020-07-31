# DMPHub

This repository covers work on a machine actionable DMP hub, from work funded by an NSF EAGER grant (https://www.nsf.gov/awardsearch/showAward?AWD_ID=1745675&HistoricalAwards=false). This 'Hub' application provides the following services:

1) Allows DMPs to be 'registered' via an API call (in the illustration below this is repredented by a system based off of the [DMPRoadmap](https://github.com/DMPRoadmap/roadmap) codebase). For an example of how the DMPRoadmap codebase interacts with the Hub, please refer to the `app/services/dmphub/registration_service.rb` in the `dmphub` branch.
2) This registration process mints a Datacite DOI for the DMP and returns that DOI back to the system that has registered their DMP.
3) Once the DMP has been registered, its DOI resolves to a landing page that is hosted by the Hub. This landing page has an HTML version for humans wishing to view the DMP's metadata as well as a JSON version for machines wishing to make use of the metadata
4) Provides API endpoints that allow other external systems to gather pertinent DMP metadata and enrich that metadata. In our example we use a [simple application](https://github.com/CDLUC3/nsf_award_scanner) that harvests award information from the NSF Awards API. The harvester app receives a list of DMP metadata and then searches the awards API for matching awards. If any are found it sends that information back to the hub.
5) The Hub then sends the award information to Datacite's EventData to assert the relationship between the DMP and the Award
6) The Hub preserves a copy of the DMP metadata and PDF in a repository (for future development)

![](public/topology.jpg)

## Feedback

We welcome any and all feedback. Please use Github Issues to provide suggestions or to report a bug, and a PR if if you wish to contribute.

## Installation

- Clone this repository (you must have Ruby 2.4+)
- Manually add the following files to the config directory: `master.key`, `credentials.yml.enc`, `database.yml`, `initializers/constants.rb`, `initializers/devise.rb`. Refer to the examples of these files in the config directory. Then update the information in those files accordingly.
- Run `bundle install`
- Run `yarn install`
- Run `bundle exec rake db:migrate`
- Run `bundle exec rake initialize:all`
- Run `rails s` to start the application and then go to `http://localhost:3000` and login as the temporary system admin account: username - super.user@example.org, password password_123 (this account gets created in the `initialize:all` task. you should of course change it when appropriate)

You can also optionally edit and run the `bundle exec rake initialize:dmptool_nsf_client_apps` task to authoriize any applications you need to use the API


## API

### Authorization

You must first register your application with the DMPHub (this is currently an entry in the database table `oauth_applications`)

```shell
curl -v -X POST http://localhost:3000/oauth/token -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -H "Accept: application/json" -d "grant_type=client_credentials&client_id=[my application uid]&client_secret=[my application secret]"
```

Returns `401 Unauthorized` for invalid client credentials or a `200` and the authorization token as JSON like the following:

```javascript
{
  "access_token":"eyJhbGciOiJIUzUxMiIsImtpZCI6IkM4MVV6dG9jaHFGOEhMTWxHbHZRUHZCWnJySmx3UTNfOW1PQkROWUMwUGMifQ.eyJpc3MiOiJEbXBodWI6OkFwcGxpY2F0aW9uIiwiaWF0IjoxNTY3NTM3MDg0LCJqdGkiOiI2YzEyNTVjMC1iOWU4LTRiODgtOGZjZC1kYjlhODJiOWFiMjYiLCJjbGllbnQiOnsiaWQiOiJDODFVenRvY2hxRjhITE1sR2x2UVB2Qlpyckpsd1EzXzltT0JETllDMFBjIiwidG9rZW5fc2VjcmV0IjoiNzZhNzVkMDMtMTVmYy00MDZjLWFhMjMtZmM0N2RkYmY3MDUxIn19.f7w_RV62VY4o058-vTK1mvkO-oVnzOnvydCgH9022U9KxspKmmXN2z-4wIauRKIc8nU74wpW3AccUYE0BqeNvQ",
  "token_type":"Bearer",
  "expires_in":7200,
  "created_at":1567537084
}
````

This token should then be passed along in the Headers of all subsequent requests to the API!

### Retrieve a list of DMPs associated with your application

Results are returned as [JSON in the RDA Common Standard format](https://github.com/CDLUC3/dmphub/blob/master/spec/support/mocks/complete_common_standard.json).

```shell
curl -v http://localhost:3000/api/v1/data_management_plans
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8"
  -H "Accept: application/json"
  -H "Authorization: Bearer [Your Authorization Token]"
```

This will return a `404 Not Found` for invalid or unauthorized requests.

If successful it will return a list of your Data Management Plans as JSON:
```javascript
{
  "generation_date":"2019-09-13 14:09:40 -0700",
  "caller":"default_app",
  "source":"GET http://localhost:3000/api/v1/data_management_plans",
  "content":{
    "dmps":[]
  }
}
````

### Add a DMP to the DMPHub (returns the DMP's DOI)

You should send the DMP as [JSON in the RDA Common Standard format](https://github.com/CDLUC3/dmphub/blob/master/spec/support/mocks/complete_common_standard.json).

```shell
curl -v -X http://localhost:3000/api/v1/data_management_plans
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8"
  -H "Accept: application/json"
  -H "Authorization: Bearer [Your Authorization Token]"
  ```

### Retrieve a specific DMP by its DOI

The DMP is returned as [JSON in the RDA Common Standard format](https://github.com/CDLUC3/dmphub/blob/master/spec/support/mocks/complete_common_standard.json).

```shell
curl -v http://localhost:3000/api/v1/data_management_plans/[DOI]
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8"
  -H "Accept: application/json"
  -H "Authorization: Bearer [Your Authorization Token]"
```

### Update a DMP

You should send the DMP as [JSON in the RDA Common Standard format](https://github.com/CDLUC3/dmphub/blob/master/spec/support/mocks/complete_common_standard.json).

```shell
curl -v -X 'PUT' http://localhost:3000/api/v1/data_management_plans
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8"
  -H "Accept: application/json"
  -H "Authorization: Bearer [Your Authorization Token]"
```

### Provisioning with Puppet

work in progress

```shell
agould@uc3-dmphub02x2-stg:~/git/github/cdluc3/dmphub> git status
On branch puppet_integration
nothing to commit, working tree clean
agould@uc3-dmphub02x2-stg:~/git/github/cdluc3/dmphub> git tag -am'dev release 0.0.0dev2' 0.0.0dev2
agould@uc3-dmphub02x2-stg:~/git/github/cdluc3/dmphub> git push ashleygould --tags

agould@uc3-dmphub02x2-stg:~/puppet/uc3/data/node> vi uc3-dmphub02x2-stg.cdlib.org.yaml
agould@uc3-dmphub02x2-stg:~/puppet/uc3/data/node> head uc3-dmphub02x2-stg.cdlib.org.yaml
---

uc3_dmphub::dmphub::config:
  default:
    git_repo: "https://github.com/ashleygould/dmphub.git"
    revision: "0.0.0dev1"
    cap_environment: "uc3_dmphub02x2"

agould@uc3-dmphub02x2-stg:~/puppet/uc3/modules/uc3_dmphub/manifests> pupapply.sh --exec

```
