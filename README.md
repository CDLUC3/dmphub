# DMPHub

This repository covers work on a machine actionable DMP hub, from work funded by an NSF EAGER grant (https://www.nsf.gov/awardsearch/showAward?AWD_ID=1745675&HistoricalAwards=false). This 'Hub' application:

1) Accepts common standard metadata and PDF from systems like DMPRoadmap
2) Sends that metadata to Datacite to mint a DOI (which it returns to the system from step 1)
3) Provides landing pages for DMPs registered with the Hub
4) Provides a simple entry form for users who want to manually enter the DMP info
5) A separate application that will gather DOIs from the hub, scan the NSF awards API, and then return any award info to the Hub
6) The Hub then sends any award info returned in step 5 to Datacite via their EventData api


## API

### Authorization

You must first register your application with the DMPHub (this is currently an entry in the database table `oauth_applications`)

```shell
curl -X POST http://dmptool-stg.cdlib.org/oauth/token -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" -H "Accept: application/json" -d "grant_type=client_credentials&client_id=[my application uid]&client_secret=[my application secret]"
```

Which should return an authorization token as JSON that looks like this:
```javascript
{
  "access_token":"eyJhbGciOiJIUzUxMiIsImtpZCI6IkM4MVV6dG9jaHFGOEhMTWxHbHZRUHZCWnJySmx3UTNfOW1PQkROWUMwUGMifQ.eyJpc3MiOiJEbXBodWI6OkFwcGxpY2F0aW9uIiwiaWF0IjoxNTY3NTM3MDg0LCJqdGkiOiI2YzEyNTVjMC1iOWU4LTRiODgtOGZjZC1kYjlhODJiOWFiMjYiLCJjbGllbnQiOnsiaWQiOiJDODFVenRvY2hxRjhITE1sR2x2UVB2Qlpyckpsd1EzXzltT0JETllDMFBjIiwidG9rZW5fc2VjcmV0IjoiNzZhNzVkMDMtMTVmYy00MDZjLWFhMjMtZmM0N2RkYmY3MDUxIn19.f7w_RV62VY4o058-vTK1mvkO-oVnzOnvydCgH9022U9KxspKmmXN2z-4wIauRKIc8nU74wpW3AccUYE0BqeNvQ",
  "token_type":"Bearer",
  "expires_in":7200,
  "created_at":1567537084
}
````

You should then send this token in the Headers of all subsequent requests to the API

### Retrieve a list of DMPs associated with your application

Results are returned as [JSON in the RDA Common Standard format](https://github.com/CDLUC3/dmphub/blob/master/spec/support/mocks/complete_common_standard.json).

```shell
curl http://dmptool-stg.cdlib.org/api/v1/data_management_plans
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8"
  -H "Accept: application/json"
  -H "Authorization: Bearer [Your Authorization Token]"
```

### Retrieve a specific DMP by its DOI or DMPHub ID

The DMP is returned as [JSON in the RDA Common Standard format](https://github.com/CDLUC3/dmphub/blob/master/spec/support/mocks/complete_common_standard.json).

```shell
curl http://dmptool-stg.cdlib.org/api/v1/data_management_plans/[DMP id]
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8"
  -H "Accept: application/json"
  -H "Authorization: Bearer [Your Authorization Token]"
```

### Add a DMP to the DMPHub (returns the DMP's DOI)

You should send the DMP as [JSON in the RDA Common Standard format](https://github.com/CDLUC3/dmphub/blob/master/spec/support/mocks/complete_common_standard.json).

```shell
curl -X http://dmptool-stg.cdlib.org/api/v1/data_management_plans
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8"
  -H "Accept: application/json"
  -H "Authorization: Bearer [Your Authorization Token]"
  ```