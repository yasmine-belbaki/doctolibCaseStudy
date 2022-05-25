import { LightningElement, track, api } from 'lwc';
export default class Lwc_getLocationInfo extends LightningElement {
  @track showWeatherComponent = false;
  @api inputCity;
  @api inputCountry;
  title = 'Location Information';
  handleSubmit() {
    var inp=this.template.querySelectorAll("lightning-input");
        inp.forEach(function(element){
            if(element.name=="inputCity")
              this.inputCity=element.value;

            else if(element.name=="inputCountry")
                this.inputCountry=element.value;
        },this);

    setTimeout(() => this.template.querySelector("c-lwc_display-weather-info").weatherInfoWithLocationInput());
    this.showWeatherComponent = true;

  }

}