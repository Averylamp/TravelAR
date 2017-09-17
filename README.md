# Trvlr
Just about the best augmented reality travel app you've ever seen.

## Prizes to go for
- amadeus - using api for travel, most innovated mobile
- concur - best and most innovative idea for a travel hack
- microsoft - best microsoft hack (more backend focused)

### OTHER OPTIONS
- Facebook API (your friend's been here)
- best use of location data (samsara)... maybe?
- wolfram alpha (background information on the location)
- 3 prizes for data viz

### Using Azure (Flask) Endpoints

##### Example Usage
- http://trvlar.azurewebsites.net/get_pictures?location=denver
- returns json object of names and images

- http://trvlar.azurewebsites.net/trip_info?location=boston
- returns flight information as dictionary

- http://trvlar.azurewebsites.net/population?location=boston
- return population for a city

#### Travel information by APIs

Amadeus APIs
- popular sites/destinations
- lat / lon
- airport and airport code
- flight info: 3x for the next three weeks each with list of 10 [price, currency, airline, time of day]

Microsoft Bing Image Search API
- images of popular sites (as determined by Amadeus API)

WolframAlpha API
- population


#### Helpful Resources
- https://docs.microsoft.com/en-us/azure/app-service-web/app-service-web-get-started-python
- http://docs.python-requests.org/en/master/
- http://docs.python-requests.org/en/master/user/quickstart/

#### API Keys

Wolfram Alpha
- HK83UR-UHGPY7A8JA
