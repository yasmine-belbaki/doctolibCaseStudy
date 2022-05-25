/**
* @author Yasmine BELBAKI 
* @date May 2022
* @description Apex Controller of du Lightning Component Display Weather Info : lwc_displayWeatherInfo
*/
global without sharing class DisplayWeatherInfoController {
    
    /* this method allows to get the weather information of either the User or the Account 
    * which ID is Id depending on the context Context
    * Id : is eather the user Id or the Account Id
    * Context : is eather "User" or "Account"
    * it returns a map that contains the weather info (temperature, wind speed, humidity, weather condition)
    */
    @AuraEnabled
    public static Map<String,String> getWeatherInfo(String Id, String Context) {
        Map<String,String> weatherInfoMap;
        Map<String,String> location = new Map<String,String>();
        location = getLocationInfo(Id, Context);
        if(location!=null) {
            if(!String.isEmpty(location.get('Latitude')) && !String.isEmpty(Location.get('Longitude'))) {
            weatherInfoMap = getweatherInfoFromLatLng(location.get('Latitude'),location.get('Longitude'));
            }
            else {
                if(!String.isEmpty(location.get('City')) && !String.isEmpty(location.get('Country'))) {
                    weatherInfoMap = getweatherInfoFromCityName(location.get('City'),location.get('Country'));
                }
                else {
                    throw new WException('error : empty inputs');
                }
            }
        }
        return weatherInfoMap;
    }

    /* this method allows to get the city, the latitude and the longitude of either the User or the Account 
    * which ID is Id depending on the context Context
    * Id : is eather the user Id or the Account Id
    * Context : is eather "User" or "Account"
    * it returns a map that contains the latitude and longitude info
    */
    public static Map<String,String> getLocationInfo(String Id, String Context) {
        Map<String,String> location = new Map<String,String>();
        if(Context == 'User' || Context == 'Account') {
            if(Context == 'User') {
                User user = [SELECT City, Country, Latitude, Longitude FROM User WHERE Id=: Id];
                location.put('Latitude', user.Latitude != null ? String.valueOf(user.Latitude) : '');
                location.put('Longitude', user.Longitude != null ? String.valueOf(user.Longitude): '');
                location.put('City', user.City);
                location.put('Country', user.Country);
            }
            else {
                Account account = [SELECT BillingCity, BillingCountry, BillingLatitude, BillingLongitude FROM Account WHERE Id=: Id];
                location.put('Latitude', account.BillingLatitude != null ? String.valueOf(account.BillingLatitude) : '');
                location.put('Longitude', account.BillingLongitude != null ? String.valueOf(account.BillingLongitude) : '');
                location.put('City', account.BillingCity);
                location.put('Country', account.BillingCountry);
            }
        }
        else {
            throw new WException('error : invalid context');
        }
        return location;
    }
    
    /* This method performs a web service call to get weather information basing on latitude and longitude inputs
    * Lat : Latitude parameter to use in the api call as an input
    * lng : Longitude parameter to use in the api call as an input
    * it returns a map that contains the weather info 
    */
    private static Map<String,String> getweatherInfoFromLatLng(String lat, String lng) {
            Geonames_API__c authInfo = Geonames_API__c.getOrgDefaults();
            if (authInfo == null || String.isBlank(authInfo.Server_URL__c) || String.isBlank(authInfo.weather_API__c)
               || String.isBlank(authInfo.username__c)) {
                throw new WException('Geonames_API__c is empty or not valid.');
            }
            HttpRequest req = new HttpRequest(); 
            String endpoint = authInfo.Server_URL__c + authInfo.weather_API__c + '?';
            endpoint =  endpoint + 'lat='+ lat + '&lng=' + lng + '&username=' + authInfo.username__c;  
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            
            Http http = new Http(); 
            try {	        
                HTTPResponse res = http.send(req); 
                
                if (res.getStatusCode() == 200) {  
                    return weatherObservationJsonBodyParser(res.getBody());
                }
                else {
                    String responseBody = res.getBody();  
                    throw new WException(responseBody);
                }  
            }
            catch (Exception  e) {
                throw new WException(e.getMessage());
            }
    
    }
    
    /* This method performs a web service call to get Latitude and Longitude of a city
    * city : a city name
    * country : a country name
    * it returns a Map of longitude and latitude information
    * it returns a map that contains the latitude and longitude info
    */
    private static Map<String,String> getLatLngFromCityName(String city, String country) {

            Geonames_API__c authInfo = Geonames_API__c.getOrgDefaults();
            if (authInfo == null || String.isBlank(authInfo.Server_URL__c) || String.isBlank(authInfo.search_API__c)
			|| String.isBlank(authInfo.username__c)) {
                throw new WException('Geonames_API__c is empty or not valid.');
            }
            HttpRequest req = new HttpRequest(); 
            String endpoint = authInfo.Server_URL__c + authInfo.Search_API__c + '?';
            String cityURL = city.replace(' ','%20');
            endpoint =  endpoint + 'q='+ cityURL + '&username=' + authInfo.username__c;  
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            Http http = new Http(); 
            try {
                HTTPResponse res = http.send(req); 
                if (res.getStatusCode() == 200) {  
                    return searchJsonBodyParser(res.getBody(), city, country);
                }
                else {
                    String responseBody = res.getBody();  
                    throw new WException(responseBody);
                } 
            }
            catch (Exception  e) {
                throw new WException(e.getMessage());
            }

    }
    
    /* This method to get weather info based on a city name and a country name
    * city : a city name, country : a country name
    * it returns a Map of longitude and latitude information
    */
    @AuraEnabled
    public static Map<String,String> getweatherInfoFromCityName(String city, String country) {
        Map<String,String> latLngInfoMap = new Map<String, String>();
        latLngInfoMap = getLatLngFromCityName(city, country);
        if(latLngInfoMap!=null) {
            String lat = latLngInfoMap.get('Latitude');
            String lng = latLngInfoMap.get('Longitude');
            if(!String.isBlank(lat) && !String.isBlank(lng)) {
                return getweatherInfoFromLatLng(lat,lng);
            } 
        }
        return null;
    }
    
    /* This method allows to parse a json string response that is a result of the ws call of weather observation
    * jsonBody : a Json Body response
    * it returns a map that contains the weather info needed
    */
    private static Map<String,String> weatherObservationJsonBodyParser(String jsonBody) {
        Map<String,String> weatherInfoMap;
        Map<String, Object> response =  (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
        Map<String, Object> weatherObservation = (Map<String, Object>)response.get('weatherObservation');
        if(weatherObservation != null) {
            weatherInfoMap = new Map<String, String>();
            weatherInfoMap.put('Weather Condition', weatherCondition(String.valueOf(weatherObservation.get('weatherCondition'))));
            weatherInfoMap.put('Temperature', String.valueOf(weatherObservation.get('temperature'))+'°');
            weatherInfoMap.put('Humidity', String.valueOf(weatherObservation.get('humidity'))+'%');
            weatherInfoMap.put('Wind Speed', transformToKmPerH(String.valueOf(weatherObservation.get('windSpeed')))+' km/h');   
        }
        return weatherInfoMap;
    }
    
    /* This method allows to parse a json string response that is a result of the ws call of search
    * jsonBody : a Json Body response
    * it returns a map that contains the latitude and longitude info
    */
    private static Map<String,String> searchJsonBodyParser(String jsonBody, String city, String country) {
        Map<String,String> latLngInfoMap;
        Map<String, Object> response =  (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
            List<Object> geoname = (List<Object>)response.get('geonames');
            if(geoname != null) {
                for(Object geo : geoname) {
                    Map<String, Object> geoMap = (Map<String, Object>)geo;	
                    if(geoMap.get('name') == city && geoMap.get('countryName') == country) {
                        latLngInfoMap = new Map<String, String>();
                        latLngInfoMap.put('Latitude', String.valueOf(geoMap.get('lat')));
                        latLngInfoMap.put('Longitude', String.valueOf(geoMap.get('lng')));
                        return latLngInfoMap; // Exit the loop as soon as we found the corresponded city and country geoname
                    }
                }
                
            }
        SYSTEM.debug('ybe not found');
        return latLngInfoMap; //will return an empty list if no correspondance is found
    }
    
    /* This method allows to set the weather condition on one of these values
    * : sunny, stormy, rainy, snowy, cloudy, sunny_cloudy_rainy
    */
    private static String weatherCondition(String weatherCondition) {
        if(weatherCondition.contains('sun')) return 'sunny';
        if(weatherCondition.contains('storm')) return 'stormy';
        if(weatherCondition.contains('rain')) return 'rainy';
        if(weatherCondition.contains('snow')) return 'snowy';
        if(weatherCondition.contains('cloud')) return 'cloudy';
        return 'sunny,cloudy,rainy'; //default value
    }
    
    /* This method allows to send a report containing the weather observation to either all users of the org, or the contact 
    * of an account which Id is Id based on the Context (User or Account)
    * Id : is eather the user Id or the Account Id
    * Context : is eather "User" or "Account"
    * WeatherInfoList contains the weather information to be included in the report email.
    * it returns a boolean, true if the emails where send false if not
    */
    @AuraEnabled
    public static Boolean sendWeatherReport(String Id, String Context, List<Map<String, Object>> WeatherInfoList) {
        List<String> emails = new  List<String>();
        Decimal lat;
        Decimal lng;
        String city;
        String Country;
        if(Context == 'User' || Context == 'Account') {
            if(Context == 'User') {
                List<User> users = [SELECT Email FROM User /*WHERE Id != Id*/];
                for(User u:users) {
                    if(validateEmail(u.Email))
                        emails.add(u.Email);
                }
            }
            else { //Context = Acocunt
                List<Contact> contacts = [SELECT Email, Account.BillingCity, Account.BillingCountry, Account.BillingLatitude, Account.BillingLongitude FROM Contact 
                WHERE AccountId=: Id AND Email != null];
                for(Contact c:contacts) {
                    if(validateEmail(c.Email))
                        emails.add(c.Email);
                }
            }
            try {
                Map<String,String> location = new Map<String,String>();
                location = getLocationInfo(Id, Context);
                sendEmails(emails, location.get('City'), location.get('Country'), location.get('Latitude'), location.get('Longitude'), WeatherInfoList);
                updateWeatherReportLastSentDate(Id, Context);
            }
            catch(WException e) {
                throw new WException('error while sending email');
            }
        }
        else {
            throw new WException('error : invalid context');
        }
        return true;
    }
    
    /* This method checks if the weather report has been sent today for the Id "Id"
    * Id : is eather the user Id or the Account Id
    * Context : is eather "User" or "Account"
    * it returns a boolean set to true if it has been sent today, no otherwise.
    */
    @AuraEnabled
    public static Boolean isWeatherReportSentToday(String Id, String Context) {
        Date weatherLastDate;
        if(Context == 'User' || Context == 'Account') {
            if(Context == 'User') {
                User user = [SELECT Weather_Report_Last_Sent_Date__c FROM User WHERE Id=: Id];
                weatherLastDate = user.Weather_Report_Last_Sent_Date__c;
            }
            else {
                Account account = [SELECT Weather_Report_Last_Sent_Date__c FROM Account WHERE Id=: Id];
                weatherLastDate = account.Weather_Report_Last_Sent_Date__c;
            }
            if(weatherLastDate == system.today()) return true;
        }
        else {
            throw new WException('error : invalid inputs');
        }
        return false;
    }
    
    /* This method sends a report containing the weather observation "WeatherInfoList" to either "toAddresses" emails
    * the report concerns the city "city" and the country "country"
    */
    private static void sendEmails(List<String> toAddresses, String city, String country, String lat, String lng, List<Map<String, Object>> WeatherInfoList) {
        List<Organization> org = [ SELECT IsSandbox FROM Organization LIMIT 1 ];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('noreply@salesforce.com');
        mail.setSubject('[' + (org[0].IsSandbox ? 'Sandbox' : 'PROD') + '] Today\'s Weather Report' );
        String message = 'Hi enveryone,\n\n' +
            'The weather today is : ' + WeatherInfoList[0].get('value') + '\n' + 
            'for the location : ' + (!String.isEmpty(lat) && !String.isEmpty(lng) ? '\nLatitude : ' + lat + '\nLogitude : '+ lng + '\n' : city + ' ' + country + '\n') +
            '\n' + WeatherInfoList[1].get('key') + ' : ' +  WeatherInfoList[1].get('value') +
            '\n' + WeatherInfoList[2].get('key') + ' : ' +  WeatherInfoList[2].get('value') +
            '\n' + WeatherInfoList[3].get('key') + ' : ' +  WeatherInfoList[3].get('value') +
            '\n\n' +
            'Have a great day !\n';
        mail.setPlainTextBody(message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    /* This method checks if a email "email" is valide
    * it return true if it is and false if it's not
    */
    private static Boolean validateEmail(String email) {
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
    
        if (!MyMatcher.matches()) 
            res = false;
        return res;	
    }

    /* This method update the field Weather_Report_Last_Sent_Date__c on the Account or on the User Object 
    * which Id is "Id" based on the Context attribute
    */
    private static void updateWeatherReportLastSentDate(String Id, String Context) {
        if(Context == 'User' || Context == 'Account') {
            if(Context == 'User') {
                User u = new User(Id = Id, Weather_Report_Last_Sent_Date__c  = system.today());
                update u;
            }
            else {
                Account a = new Account(Id = Id, Weather_Report_Last_Sent_Date__c  = system.today());
                update a;
            }
        }
    }
    
    /* This method do a conversion from Knot to Km/h
    * it returns the speed in Km/h in a string format
    */
    private static String transformToKmPerH(String windSpeed) {
        Decimal windSpeedKmh; 
        windSpeedKmh = Decimal.valueOf(windSpeed) * 1.852;
        return String.valueOf(windSpeedKmh);
    }
    class WException extends Exception {}   
}