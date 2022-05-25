import Id from '@salesforce/user/Id';
import My_Resource  from '@salesforce/resourceUrl/weatherIconsResource';
import getWeatherInfo from '@salesforce/apex/DisplayWeatherInfoController.getWeatherInfo';
import getweatherInfoFromCityName from '@salesforce/apex/DisplayWeatherInfoController.getweatherInfoFromCityName';
import sendWeatherReport from '@salesforce/apex/DisplayWeatherInfoController.sendWeatherReport';
import isWeatherReportSentToday from '@salesforce/apex/DisplayWeatherInfoController.isWeatherReportSentToday';
import { LightningElement, api } from 'lwc';

export default class Lwc_displayWeatherInfo extends LightningElement {

    title = 'Weather Information';
    @api objectApiName;
    @api recordId;
    error;
    userId = Id;
    context;
    objectId;
    weatherIcon;
    noInfo = true;
    weatherInfoList = [];
    showSendButton = true;
    showSendConfirmation = false;
    disbaleSendButton=false;
    showSendConfirmationMsg;
    @api cityinfo;
    @api countryinfo;
    @api currentPage;

    /* this methods is exuctutes first when the component is initialised*/
    connectedCallback() {
        if(this.currentPage == 'Account' || this.currentPage == 'Home') {
            if(this.currentPage == 'Account') {
                this.context = 'Account';
                this.objectId = this.recordId;
            }
            else {
                this.context = 'User';
                this.objectId = this.userId;
            }
            this.weatherInfo();
            this.checkSendReport();
        } 
    } 

    weatherInfo() {
        getWeatherInfo({Id: this.objectId, Context: this.context})
        .then((data) => {
            if(data){
                this.noInfo = false;
                this.weatherIcon = My_Resource + '/images/' +data['Weather Condition'] + '.png';
                //delete data.weatherCondition; // if we want to not display weather condition text
                for (let key in data) {;
                    this.weatherInfoList.push({value:data[key], key:key});
                }

            }
        })
        .catch(error => {
            console.log('Error: ', error);
            this.error = error;
        })
    }

    handleSendReport() {
        sendWeatherReport({Id: this.objectId, Context: this.context, WeatherInfoList: this.weatherInfoList})
        .then((data) => {
            if(data) {
                this.showSendConfirmation = true;
                this.disbaleSendButton = true;
                this.showSendConfirmationMsg = 'The report was sent successfully.';
            }
        })
        .catch(error => {
            this.error = error;
            this.showSendConfirmation = true;
            this.showSendConfirmationMsg = 'An error occured. The report has not been sent.';
        }) 
    }

    checkSendReport() {
        isWeatherReportSentToday({Id: this.objectId, Context: this.context})
        .then((data) => {
            if(data) {
                this.showSendButton = false; //the report has already been sent by this user/account we don't display the button

            }
        })
        .catch(error => {
            this.error = error;
        })
    } 

    /* this method is called from the parent lwc component : lwc_getLocationInfo*/
    @api weatherInfoWithLocationInput() {        
        getweatherInfoFromCityName({city: this.cityinfo, country: this.countryinfo})
        .then((data) => {
            this.weatherInfoList = [];
            if(data){
                this.noInfo = false;
                this.showSendButton = false;
                this.weatherIcon = My_Resource + '/images/' +data['Weather Condition'] + '.png';
                for (let key in data) {;
                    this.weatherInfoList.push({value:data[key], key:key});
                }
            }
            else {
                this.noInfo = true;
            } 
        })
        .catch(error => {
            this.noInfo = true;
            this.error = error;
        })    
    }
}