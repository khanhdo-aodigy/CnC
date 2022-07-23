import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';


export default class BroadcastVehicleType extends LightningElement 
{
    @wire(CurrentPageReference) pageRef;

    renderedCallback()
    {
        this.handleFirstRender();
    }

    handleFirstRender()
    {
        this.template.querySelector('input[data-id="Registered_Vehicle__c"]').checked = true;
    }

    get options()
    {
        return [
            { label: 'Registered Vehicle', value : 'Registered_Vehicle__c'},
            { label: 'Used Car', value: 'Used_Car_Vehicle_Stock__c'},
            { label: 'Non C&C', value: 'Non_C_C_Vehicle__c'}
        ];
    }

    handleChange(event)
    {
        fireEvent(this.pageRef, 'vehicleTypeChange', event.target.value);
    }
}