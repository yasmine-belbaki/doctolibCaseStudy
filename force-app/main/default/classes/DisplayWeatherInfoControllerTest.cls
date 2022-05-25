/**
* @author Yasmine BELBAKI 
* @date May 2022
* @description Apex Test Class of the Controller : DisplayWeatherInfoController
*/
@IsTest
public class DisplayWeatherInfoControllerTest {
	@testSetup static void setup() {
        
        Geonames_API__c authInfo = new Geonames_API__c();
        authInfo.Server_URL__c = 'http://api.geonames.org';
        authInfo.weather_API__c = '/findNearByWeatherJSON';
        authInfo.search_API__c = '/searchJSON';
        authInfo.username__c = 'demo';
        insert authInfo;  

        Account acc = new Account(Name = 'Name', BillingCity = 'Paris', BillingCountry = 'France');
        insert acc;
        
        Contact c = new Contact(LastName = 'Name2', email = 'name@testcunning.test', accountId = acc.Id);
        insert c;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        User u = new User(Alias = 'st', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='ABC', LanguageLocaleKey='en_US', LocaleSidKey='en_US',
                          ProfileId = p.Id ,TimeZoneSidKey='America/Los_Angeles', Username='systemad@testorgcuuning.com',CommunityNickname = 'Test',
                         Latitude = 43.35 , Longitude = -1.8);      
        insert u;
    }
    
    @isTest static void testGetWeatherInfoAccount() {
        Test.setMock(HttpCalloutMock.class, new DisplayWeatherInfo_WSMockImpl200());
        Account c = [SELECT ID FROM Account][0];
		Test.startTest();        
        DisplayWeatherInfoController.getWeatherInfo(c.Id, 'Account');
        Test.stopTest(); 
    }
    
    @isTest static void testGetWeatherInfoUser() {
        Test.setMock(HttpCalloutMock.class, new DisplayWeatherInfo_WSMockImpl200());
        User u = [SELECT ID FROM User WHERE Alias = 'st'][0];
		Test.startTest();        
        DisplayWeatherInfoController.getWeatherInfo(u.Id, 'User');
        Test.stopTest(); 
    }
    
    @isTest static void testsendWeatherReportAccount() {
        Account c = [SELECT ID FROM Account][0];
        List<Map<String, Object>> weatherInfo = new List<Map<String, Object>>();
        Map<String, Object> m = new Map<String, Object>();
        m.put('weatherCondition','stormy');
        weatherInfo.Add(m);
        m = new Map<String, Object>();
        m.put('Temperature','27');
        weatherInfo.Add(m);
        m = new Map<String, Object>();
        m.put('Humidity','27');
        weatherInfo.Add(m);
        m = new Map<String, Object>();
        m.put('Wind Speed','27');
        weatherInfo.Add(m);
		Test.startTest();        
        DisplayWeatherInfoController.sendWeatherReport(c.Id, 'Account', weatherInfo);
        Test.stopTest(); 
    }

    public class DisplayWeatherInfo_WSMockImpl200 implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String jsonBody;
            res.setHeader('Content-Type', 'application/json');   
            if(req.getEndpoint().contains('findNearByWeatherJSON')) {
                jsonBody = '{'+
                               '"weatherObservation":{'+
                                  '"elevation":8,'+
                                 ' "lng":-1.8,'+
                                  '"weatherConditionCode":"VCTS",'+
                                 ' "observation":"LESO 151430Z 33007G22KT 280V040 9999 VCTS SCT035 SCT040CB 27/15 Q1011",'+
                                 ' "ICAO":"LESO",'+
                                  '"clouds":"scattered clouds",'+
                                 ' "dewPoint":"15",'+
                                  '"cloudsCode":"SCT",'+
                                 ' "datetime":"2022-05-15 14:30:00",'+
                                  '"countryCode":"ES",'+
                                  '"temperature":"27",'+
                                  '"humidity":47,'+
                                  '"stationName":"San Sebastian / Fuenterrabia",'+
                                 ' "weatherCondition":"in vicinity: thunderstorm ",'+
                                  '"windDirection":330,'+
                                 ' "hectoPascAltimeter":1011,'+
                                  '"windSpeed":"07",'+
                                 '"lat":43.35'+
                               '}'+
                            '}';
            }
            else {
                jsonBody = '{'+
                    ' "geonames":['+
                    '   {'+
                    '     "toponymName":"Paris",'+
                    '     "name":"Paris",'+
                    '    "lat":"51.50853",'+
                    '   "lng":"-0.12574",'+
                    '     "geonameId":"2643743",'+
                    '     "countryCode":"GB",'+
                    '     "countryName":"France",'+
                    '     "fcl":"P",'+
                    '     "fcode":"PPLC"'+
                    '  },'+
                    '  {'+
                    '     "toponymName":"London",'+
                    '     "name":"London",'+
                    '     "lat":"42.98339",'+
                    '     "lng":"-81.23304",'+
                    '     "geonameId":"6058560",'+
                    '     "countryCode":"CA",'+
                    '     "countryName":"Canada",'+
                    '     "fcl":"P",'+
                    '     "fcode":"PPL"'+
                    '  }'+
                    ']'+
                '}';		
            }
            res.setBody(jsonBody);                            
            res.setStatusCode(200);
            return res;
        }
    }
}