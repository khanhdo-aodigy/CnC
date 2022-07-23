import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import BRANCH_FIELD from '@salesforce/schema/Registered_Vehicle__c.Branch__c';
import FRANCHISE_FIELD from '@salesforce/schema/Registered_Vehicle__c.Franchise__c';
import getModels from '@salesforce/apex/BroadcastController.getModelAsSelectOptions';
import getVariants from '@salesforce/apex/BroadcastController.getVariantAsSelectOptions';
import { registerListener, fireEvent , unregisterAllListeners } from 'c/pubsub';

const DELAY = 350;

export default class broadcastFilter extends LightningElement {
    
    @track filters = 
    { 
        vehicleType: 'Registered_Vehicle__c'
    };

    @track selected_branches;
    @track selected_models;
    @track selected_variants;
    @track brand_options;
    @track model_options = [];
    @track variant_options = [];
    @track initialRender = true;

    @track vehicleType = 'Registered_Vehicle__c';
    @track isRegisteredVehicle = true;
    @track isUsedCar           = false;
    @track isNonCC             = false; 

    
    @track errorList = [];

    renderedCallback() 
    {
        if (this.initialRender) 
        {
            this.initialRender = false;
        }
    }

    connectedCallback() 
    {
		registerListener( 'slider__NumberRangeChange', this.handleNumberRangeChange, this );
		registerListener( 'numberRangeChange', this.handleNumberRangeChange, this );
		registerListener( 'dateRangeChange', this.handleDateRangeChange, this );
        registerListener( 'vehicleTypeChange', this.handleVehicleTypeChange, this );
        window.addEventListener('DualPickilistValueChanged', this.onValueChanged.bind(this));
	}

    disconnectedCallback() 
    {
        unregisterAllListeners(this);
    }
    
    initializeBrands () 
    {
        getBrands()
        .then(result => 
        {
            this.brand_options = this.processPicklistToDisplay(result);
        })
        .catch(error => {
            console.log(error);
        });
    }

    initializeVariants() 
    {
        getVariants()
        .then(result => 
        {
            this.variant_options = this.processPicklistToDisplay(result);
        })
        .catch(error => {
            console.log(error);
        });
    }

    get isDisabled()
    {
        console.log('Error list: ' + JSON.stringify(this.errorList));
        return this.errorList.length !== 0;
    }

    processPicklistToDisplay = ( Records ) => 
    {
        let temporarystorage = [];
        for (let x = 0; x < Records.length; x++) 
        {
            if (Records[x].Name != null) 
            {
                temporarystorage.push({
                    label: Records[x].Name,
                    value: Records[x].Id
                });
            }
        }
        
        return temporarystorage;
    }    

    @wire(CurrentPageReference) pageRef;

    
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: BRANCH_FIELD
    })
    branches;


    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: FRANCHISE_FIELD
    })
    franchises;

    handleCheckboxChange(event) 
    {
        if (!this.filters.branches) {
            this.filters.branches = [];
        }

        const value = event.target.dataset.value;
        const filterArray = this.filters[event.target.dataset.filter];
        if (event.target.checked) {
            if (!filterArray.includes(value)) {
                filterArray.push(value);
            }
        } 
        else {
            this.filters[event.target.dataset.filter] = filterArray.filter(
                item => item !== value
            );
        }
        
        console.log('####DEBUG handleCheckboxChange :: this.filterArray 222 = ' + filterArray );
        console.log('####DEBUG handleCheckboxChange :: this.filters.branches 222 = ' + this.filters.branches );
        console.log('####DEBUG handleCheckboxChange :: this.selected_branches 111 = ' + this.selected_branches );
        this.selected_branches = this.filters.branches;
        console.log('####DEBUG handleCheckboxChange :: this.selected_branches 222 = ' + this.selected_branches );
        this.retriveModels();
        //HS this.delayedFireFilterChangeEvent();
    }


    handleModelChange(event) 
    {
        this.filters.model = event.target.value;
    }

    handleVariantChange(event) 
    {
        this.filters.variant = event.target.value;
    }

    delayedFireFilterChangeEvent()
    {
        // Debouncing this method: Do not actually fire the event as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex
        // method calls in components listening to this event.
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            fireEvent(this.pageRef, 'filterChange', this.filters);
        }, DELAY);
    }
  
    onValueChanged(event)
    {    
        if( event.detail.Model__c )
        {
            console.log('@@@@TESTING --- MODEL CHANGED !!! ');
            this.selected_models = typeof event.detail.Model__c !== 'undefined' ? event.detail.Model__c : this.selected_models;
            this.retrieveVariants();
        }

        if( event.detail.Variant__c )
        {
            console.log('@@@@TESTING --- VARIANT CHANGED !!! ');
            this.selected_variants = typeof event.detail.Variant__c != 'undefined' ? event.detail.Variant__c : this.selected_variants;
        }

        console.log('####RegVehicleFilter --> onValueChanged :: selected_models = ' + this.selected_models );
        console.log('####RegVehicleFilter --> onValueChanged :: selected_variants = ' + this.selected_variants );
        
        this.filters.models   = this.selected_models;
        this.filters.variants = this.selected_variants;

        this.valueChangedDetected();
    }


    valueChangedDetected() 
    {
        const selectEvent = new CustomEvent('change', {
            model_detail: this.selected_models,
            variant_details : this.selected_variants
        });
        this.dispatchEvent(selectEvent);
    }

    retriveModels () 
    {
        console.log('####DEBUG retriveModels :: selected_branches  = ' + this.selected_branches+ ' --- ' + JSON.stringify( this.selected_branches ) );
        getModels( {lstBranches : this.selected_branches} )
        .then(result => 
        {
            console.log('####DEBUG retriveModels :: result = ' + result.length  );
            if( result && result.length < 1 )
            {
                this.filters.models = this.selected_models = [];
            }

            this.model_options = this.processPicklistToDisplay( result );
            this.template.querySelector('.model-cls').setOptions( this.model_options );
            this.retrieveVariants();
        })
        .catch(error => {
            console.log(error);
        });
    }   

    retrieveVariants() 
    {
        getVariants( {lstBranches : this.selected_branches, lstModels : this.selected_models } )
        .then(result => 
        {
            console.log('####DEBUG retrieveVariants :: result = ' + result.length  );
            if( result && result.length < 1 )
            {
                this.filters.variants = this.selected_variants = [];
            }

            this.variant_options = this.processPicklistToDisplay(result);
            this.template.querySelector('.variant-cls').setOptions( this.variant_options );
        })
        .catch(error => {
            console.log(error);
        });
    }

	handleNumberRangeChange( event ) 
    {
        if (!event.isValid)
        {
            this.errorList.includes(event.filterName) === false && this.errorList.push(event.filterName);
            return;
        }

        this.errorList.includes(event.filterName) && this.errorList.splice(this.errorList.indexOf(event.filterName), 1);
		const filterName = event.filterName;
        const minValue   = event.minValue;
		const maxValue   = event.maxValue;
		console.log('####DEBUG handleNumberRangeChange :: filterName = ' + filterName + ' --- minValue = ' + minValue + ' --- maxValue = ' + maxValue );

        if (filterName === 'Contact__r.BirthDate') 
        {
			this.filters.bdayMonthFrom = minValue;
            this.filters.bdayMonthTo   = maxValue;
		}

		if (filterName === 'Vehicle_Age__c') 
        {
            this.filters.carAgeFrom = minValue;
            this.filters.carAgeTo   = maxValue;
		}

        if (filterName === 'Mileage')
        {
            this.filters.MileageFrom = minValue;
            this.filters.MileageTo   = maxValue;
        }
		
		this.filters = Object.assign({}, this.filters);
		this.pageNumber = 1;
		console.log('####DEBUG handleNumberRangeChange :: this.filters = ' + JSON.stringify( this.filters ) );
	}
	
    handleVehicleTypeChange( event )
    {
        console.log('-------------------------**************************************---------------------------------------');
        console.log('####BroadcastFilter --> handleVehicleTypeChange :: type = ' + event);
        this.handleReset();
        this.filters.vehicleType = this.vehicleType = event;
        switch (event) 
        {
            case 'Registered_Vehicle__c':
                this.isRegisteredVehicle = true;
                this.isUsedCar           = false;
                this.isNonCC             = false;
                break;
            case 'Used_Car_Vehicle_Stock__c':
                this.isRegisteredVehicle = false;
                this.isUsedCar           = true;
                this.isNonCC             = false;
                break;
            case 'Non_C_C_Vehicle__c':
                this.isRegisteredVehicle = false;
                this.isUsedCar           = false;
                this.isNonCC             = true;
                break;
            default:
                break;
        }
    }

	handleDateRangeChange( event )
    {
        if (!event.isValid)
        {
            this.errorList.includes(event.filterName) === false && this.errorList.push(event.filterName);
            return;
        }

        this.errorList.includes(event.filterName) && this.errorList.splice(this.errorList.indexOf(event.filterName), 1);
		const filterName = event.filterName;
        const minValue   = event.minValue;
		const maxValue   = event.maxValue;
		console.log('####DEBUG handleDateRangeChange :: filterName = ' + filterName + ' --- minValue = ' + minValue + ' --- maxValue = ' + maxValue );

		if( filterName === 'Last_Service_Date' )
        {
			this.filters.lastServiceDateFrom = minValue;
        	this.filters.lastServiceDateTo   = maxValue;
		}

		if( filterName === 'Upcoming_Service_Date' )
        {
			this.filters.upcomingServiceDateFrom = minValue;
        	this.filters.upcomingServiceDateTo   = maxValue;
		}

        if (filterName === 'Registration_Date') 
        {
            this.filters.registrationDateFrom = minValue;
            this.filters.registrationDateTo   = maxValue;
        }

		this.filters = Object.assign({}, this.filters);
		this.pageNumber = 1;
		console.log('####DEBUG handleDateRangeChange :: this.filters = ' + JSON.stringify( this.filters ) );
    }
    
    handleSearch()
    {
        console.log('####BroadcastFilter --> handleSearch :: filters = ' + this.filters + ' ---- ' + JSON.stringify( this.filters ) );
        this.delayedFireFilterChangeEvent();
    }

    handleReset()
    {
        console.log('####BroadcastFilter --> handleReset :: filters = ' + this.filters + ' ---- ' + JSON.stringify( this.filters ) );

        if (this.isRegisteredVehicle)
        {
            Array.from(this.template.querySelectorAll('.check-box-cls'))
            .forEach(element => {
                element.checked=false;
            });
            this.filters.branches = this.selected_branches = [];
    
            this.model_options   = [];
            this.template.querySelector('.model-cls').setOptions( this.model_options );
            this.filters.models = this.selected_models = [];
    
            this.variant_options    = [];
            this.template.querySelector('.variant-cls').setOptions( this.variant_options );
            this.filters.variants = this.selected_variants = [];
        }

        this.errorList = [];
        this.filters = {};
        this.filters.vehicleType = this.vehicleType;
        fireEvent(this.pageRef, 'reset_Filters', this.filters);
        console.log('####BroadcastFilter --> handleReset :: filters = ' + this.filters + ' ---- ' + JSON.stringify( this.filters ) );
        this.delayedFireFilterChangeEvent();
    }
}