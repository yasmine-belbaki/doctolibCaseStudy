## General Observations

The component Weather information get the user or the account location depending on which window it is displayed.
It starts by checking if the longitude and latitude are filled up if it's not it uses the fields city and country.
If all the location fields are empty it diplays : No information available.

For the send report button, as the org has a limit of 15 emails sent per day, it can displays an error message when it's reached. The error message displayed on the component : "An error occured. The report has not been sent.Otherwise, we display : "The report was sent successfully".

Note that the Send Report Button only appears if the user on the home page didn't sent the report at all that day. The same condition is applied for the Account. Thus, the user is not able to send to report twice a day.

The weather condition may have the following values : sunny, stormy, rainy, snowy and cloudy. If no information about the weather condition is available (none is returned from the geoname api) a default value is set to 'sunny,cloudy,rainy' with it's respective icon.

The component is accessible from the home page (of the Sales Console Salesforce Standard Application), from the account page and from the public site : https://weather-observation-developer-edition.fra19.sfdc-urlt2q.force.com/

Note that this application is a proof of concept, many additional evolutions can be added.

## Access for testing
The component is deployed on a salesforce sandbox. Please use :
- url : https://cunning-otter-5h6xn6-dev-ed.my.salesforce.com/
- username : yasmine.bel@test.com
- password : (sent by email)
- a verification code is required and may be send by email

## What this project mainly contains
### Custom Setting : 
Geonames API (search API, Server URL, weather API)	 
		
### Custom Field on User:
Weather_Report_Last_Sent_Date__c

### Custom Field on Account:
Weather_Report_Last_Sent_Date__c
	
### Apex Classes:
DisplayWeatherInfoController, DisplayWeatherInfoControllerTest

### LWC:
lwc_displayWeatherInfo
	
### Remote sites:
GeonamesAPI
	
### Flexi page: 
Account Record Page, Home Page Default
	
### Static Resources:
weatherIconsResource

## For the Extra Part
### Site:
Weather Observation

### VF Page:
WeatherObservation

### Lightning App:
WeatherInfoApp

### LWC:
lwc_getLocationInfo
