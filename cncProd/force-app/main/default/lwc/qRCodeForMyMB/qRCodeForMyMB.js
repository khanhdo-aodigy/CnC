import { LightningElement, api, track} from 'lwc';
import getChasis from '@salesforce/apex/RegisteredVehicleSelector.getChasisById';


export default class QRCodeForMyMB extends LightningElement {
    @track chasisNumber;
    @api divStyle = "height: " + window.innerHeight + "px;";
    
    connectedCallback() {
        let url = new URL(window.location.href);
        let rvId = url.searchParams.get("serviceappid");
        console.log(rvId);

        getChasis(
            { recordId : rvId}
        )
        .then(result => {
            console.log(result);
            if(result != null){
                this.chasisNumber = result[0].Chasis_Number__c;
            }
        })
    }

}