import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFranchiseGlobalPicklist from '@salesforce/apex/COEBiddingController.getFranchisePicklist';
import searchingTMSPOGroup from '@salesforce/apex/TreasuryManagementController.searchTMSPOGroup';


export default class TreasuryManagement_SearchingTMSPOGroup extends LightningElement {
    spinner  = false;  
    @track haveTMSPOs = false;
    franchiseOptions;
    selectedFranchise;
    selectedProductionMth;    

    @track listWrapper;
    
    @wire(getFranchiseGlobalPicklist, {})
    wiredFranchise({error, data})
    {
        if (error)
        {
            console.error(error);
        }
        else if (data)
        {   
            let franchises = [];
            data.forEach(item => {
                franchises.push({ value: item.value, label : item.label });
            })
            this.franchiseOptions = franchises;
        }
    }

    handleChange(event)
    {
        let inputNm = event.target.name;
        let value   = event.target.value;

        switch(inputNm)
        {
            case 'franchise':
                this.selectedFranchise = value;
                break;
            case 'production_month':
                this.selectedProductionMth = value;
                break;
            default:
                break;
        }
    }

    searchTMSPO()
    {
        this.spinner = true;
        console.log('this.selectedFranchise', this.selectedFranchise)
        console.log('this.selectedProductionMth', this.selectedProductionMth)
        searchingTMSPOGroup({
            franchise: this.selectedFranchise,
            productionMonth: this.selectedProductionMth
        }).then(result => {

            this.listWrapper = result;
            this.listWrapper = this.deepClone(this.listWrapper);
            
            if(this.listWrapper.length > 0)
            {
                this.haveTMSPOs = true;
            } 
            this.listWrapper.forEach(wp => {

                if(wp.tmsRecord)
                {
                    wp.tmsRecord.nameUrl = `/${wp.tmsRecord.Id}`;
                }
                // if(wp.fobWrappers.length > 0)
                // {
                //     wp.tmsRecord.nameUrl = `/${wp.tmsRecord.Id}`;
                // }

                if(wp.fobWrappers.length > 0)
                {
                    wp.tmsRecord.haveFOBContract = true;
                    wp.fobWrappers.forEach(fobWp => {

                        fobWp.fobContract.nameUrl = `/${fobWp.fobContract.Id}`;
                        
                        if(fobWp.fobAddContracts.length > 0)
                        {
                            fobWp.fobContract.haveFOBAdditional = true;
                            
                            fobWp.fobAddContracts.forEach(fobAdd =>{
                                fobAdd.nameUrl = `/${fobAdd.Id}`;
                                console.log('😒😒');
                            })
                            
                        }else{
                            fobWp.fobContract.haveFOBAdditional = false;
                        }
                    })
                    console.log('❤️❤️😍😍😒😒');

                }else{
                    wp.tmsRecord.haveFOBContract = false;
                }
                
                if(wp.dutyWrappers.length > 0)
                {
                    wp.tmsRecord.haveDutyContract = true;
                    wp.dutyWrappers.forEach(dutyWp => {
                        dutyWp.dutyContract.nameUrl = `/${dutyWp.dutyContract.Id}`;

                        if(dutyWp.dutyAddContracts.length > 0)
                        {
                            dutyWp.dutyContract.haveDutyAdditional = true;

                            dutyWp.dutyAddContracts.forEach(dutyAdd =>{
                                dutyAdd.nameUrl = `/${dutyAdd.Id}`;
                                console.log('😒😒');
                            })
                        }else{
                            dutyWp.dutyContract.haveDutyAdditional = false;
                        }                        
                    })

                }else{
                    wp.tmsRecord.haveDutyContract = false;
                }

                if(wp.vpoList != null)
                {
                    wp.tmsRecord.haveVPOs = true;
                    wp.vpoList.forEach(vpo => {
                        vpo.nameUrl = `/${vpo.Id}`;
                    })
                }else{
                    wp.tmsRecord.haveVPOs = false;
                }
            })

            console.log(result);
            console.log('success');
            this.spinner = false;
        }).catch(error => {
            console.log('error');
            console.log(error);
            this.showNotification('Error!', 'An error occurred. Please contact your System Admin ' + error.body.message, 'error', 'dissmissible');
            this.spinner = false;
        })

    }


    handleShowDetail(event)
    {
        let tmspoId = event.target.dataset.tmspoId;
        let _selectPO = this.template.querySelector(`[data-id="${tmspoId}"]`);
        if(_selectPO.style.visibility=='collapse')
        {
            _selectPO.style.visibility='initial'; 
        }
        else
        {
            _selectPO.style.visibility='collapse';            
        }
    }

    // handleShowFOBAdditonal

    handleShowFOBAdditonal(event)
    {
        let fobId = event.target.dataset.fobId;
        let _selectFobPO = this.template.querySelector(`[data-id="${fobId}"]`);
        
        if(_selectFobPO.style.visibility=='collapse')
        {
            console.log('😂😂');
            _selectFobPO.style.visibility='initial'; 
            console.log('😂😂');
        }
        else
        {
            _selectFobPO.style.visibility='collapse';            
        }
    }

    handleShowDutyAdditonal(event)
    {
        let dutyId = event.target.dataset.dutyId;
        let _selectDutyPO = this.template.querySelector(`[data-id="${dutyId}"]`);
        
        if(_selectDutyPO.style.visibility=='collapse')
        {
            console.log('😂😂');
            _selectDutyPO.style.visibility='initial'; 
            console.log('😂😂');
        }
        else
        {
            _selectDutyPO.style.visibility='collapse';            
        }
    }

    deepClone(data)
    {
        return JSON.parse(JSON.stringify(data));
    }

    showNotification(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(evt);
    }

    // searchTMSPO1()
    // {
    //     this.spinner = true;
    //     console.log('this.selectedFranchise', this.selectedFranchise)
    //     console.log('this.selectedProductionMth', this.selectedProductionMth)
    //     getTMSPO({
    //         franchise: this.selectedFranchise,
    //         productionMonth: this.selectedProductionMth
    //     }).then(result => {
    //         let fobList = [];
    //         let dutyList = [];
    //         let vpoList = [];
    //         this.haveTMSPOs = true;
    //         let nameUrl;
    //         this.tmsPO = result.map(tmsPO => { 
    //             nameUrl = `/${tmsPO.Id}`;
    //             fobList = tmsPO.data.field
    //             return {...tmsPO , nameUrl} 
    //         }) 
            

    //         console.log(result);
    //         console.log('success');
    //         this.spinner = false;
    //     }).catch(error => {
    //         console.log('error');
    //         console.log(error);
    //         this.showNotification('Error!', 'An error occurred. Please contact your System Admin ' + error.body.message, 'error', 'dissmissible');
    //         this.spinner = false;
    //     })

    // }

    // @wire(searchingTMSPOGroup, {
    //     franchise: this.selectedFranchise,
    //     productionMonth: this.selectedProductionMth
    // }) 
    // wiredTMS(result) {
    //     this.wiredRecs = result;
    //     if (result.data)
    //     {
    //         this.tmsPOs                 = result.data.tmsPOs;
    //         this.fobContractListRecord  = result.data.fobContractListRecord;
    //         this.dutyContractListRecord = result.data.dutyContractListRecord;
    //         this.vpoListRecord          = result.data.vpoListRecord;            
    //         let nameUrl;
    //         this.tmsPOs.forEach(tmsPO => {
    //             nameUrl = `/${tmsPO.Id}`;
    //             return {...tmsPO , nameUrl} 
    //         })

    //         this.fobContractListRecord.forEach(fobRec => {
    //             nameUrl = `/${fobRec.Id}`;
    //             return {...fobRec , nameUrl} 
    //         })

    //         if(this.fobContractListRecord.length > 0)
    //         {
    //             this.haveFOBContract = true;
    //         }
    //         if(this.dutyContractListRecord.length > 0)
    //         {
    //             this.haveDutyContract = true;
    //         }
    //         if(this.vpoListRecord.length > 0)
    //         {
    //             this.haveVPOs = true;
    //         }
    //     }
    //     if (result.error)
    //     {
    //         this.errMsg = result.error.body.message;
    //     }
    // }
}