# DMPHub

This repository covers work on a machine actionable DMP hub, from work funded by an NSF EAGER grant (https://www.nsf.gov/awardsearch/showAward?AWD_ID=1745675&HistoricalAwards=false). This 'Hub' application: 

1) Accepts common standard metadata and PDF from systems like DMPRoadmap
2) Sends that metadata to Datacite to mint a DOI (which it returns to the system from step 1)
3) Provides landing pages for DMPs registered with the Hub
4) Provides a simple entry form for users who want to manually enter the DMP info
5) A separate application that will gather DOIs from the hub, scan the NSF awards API, and then return any award info to the Hub
6) The Hub then sends any award info returned in step 5 to Datacite via their EventData api
