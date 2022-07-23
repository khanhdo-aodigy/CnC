/* eslint-disable no-unused-expressions */
import { LightningElement,api, track,wire } from 'lwc';
import getAccessoriesMaster from '@salesforce/apex/DigitalSalesAgreementApplication.getAccessoriesMaster';
import processSAAccessories from '@salesforce/apex/DigitalSalesAgreementApplication.processSAAccessories';


export default class AccessoriesAddOnList extends LightningElement {
    
    @api recordId;
    @api existingList;
    @api packageAddon;
    @api packageExistingList;

    @track accessoriesMasterList;
    @track additionAccessoriesGroup;
    @track mainAccessoriesGroup;
    @track insuranceGroup;
    @track serviceGroup;
    @track warrantyGroup;
    @track promotionGroup;
    
    @track cartItemList=[];
    @track cartItemListToRemove=[];
    @track cartTotalValue = 0;
    @track cartTotalItems = 0;
    @track error;

    firstTimeProcessExistingList = false;
    initialRender = false;
    returnFromGetAccessoriesMaster  = false;

    renderedCallback(){
        this.returnFromGetAccessoriesMaster && (this.setTradableInactive(),
                                                this.processUIForExistingList());
    }

    @wire(getAccessoriesMaster, {
        recordId: '$recordId'
    }) returnResult({data, error}){
        this.accessoriesMasterList = data  ? this.removePackageAddon(data) : undefined;
        this.returnFromGetAccessoriesMaster = this.accessoriesMasterList ? true : false;
        this.accessoriesMasterList && (this.processGroupSection(), this.processExistingList());
        this.error = error ? error : undefined; 
    }

    addItemWithCharges(event){
        const selectionStatus = event.currentTarget.className;
        selectionStatus.includes('active') ? this.removeItemFromCart(event) : this.addItemToCart(event, false);
    }

    addItemWithoutCharges(event){
        const selectionStatus = event.currentTarget.className;
        selectionStatus.includes('active') ? this.removeItemFromCart(event) : this.addItemToCart(event, true);
    }
    
    removeItemFromCart(event){
        const isFree = event.currentTarget.className.includes('deal') ? 'Y' : 'N';
        event.currentTarget.classList.remove('active');
        this.removeItem(event.currentTarget.dataset.itemid, isFree);
    }
 
    addItemToCart(event, isFree){
        this.checkOneSelection(event);
        //event.currentTarget.classList.add('active');
        const itemToCard = this.accessoriesMasterList.find(item=> item.Id === event.currentTarget.dataset.itemid);
        const newItem = {};
        newItem.Sales_Agreement__c = this.recordId;
        newItem.Accessories_Master__c = itemToCard.Id;
        newItem.SAC_PACKAGE__c = 'N';
        newItem.SACQTY__c = 1;
        newItem.SAC_ACCSTRADE__c = isFree ? 'Y' : 'N';
        //newItem.SAC_ACCSVALUE__c = isFree ? 0 : itemToCard.Rate__c; 
        newItem.SAC_ACCSVALUE__c = isFree ? 0 : (itemToCard.Rate__c ? itemToCard.Rate__c : 0 ); 
        this.cartItemList.push(newItem);
        this.calculateCartTotalValue();
    }

    removeItem(itemId, isFree){
        const removeIndex = this.cartItemList.findIndex(item=> item.Accessories_Master__c === itemId && item.SAC_ACCSTRADE__c === isFree);        
        const currentItem = this.cartItemList[removeIndex];
        try {
        typeof currentItem.Id !== "undefined" && this.cartItemListToRemove.push({Id : currentItem.Id});
        } catch (e) {
         console.log(' -', e);
        }
        removeIndex >= 0 && this.cartItemList.splice(removeIndex, 1);
        this.calculateCartTotalValue();
    }
    checkOneSelection(event){
        const currentElement = event.currentTarget.className;
        const currentButton = currentElement.includes('deal') ? 'deal' : 'add';
        const isFree = event.currentTarget.className.includes('deal') ? 'N' : 'Y';

        this.template.querySelectorAll(`button[data-itemid=${event.currentTarget.dataset.itemid}]`).forEach(elem=>{
            elem.className.includes(currentButton) ? elem.classList.add('active') :
                                                    ( elem.className.includes('active'), 
                                                        this.removeItem(elem.dataset.itemid,isFree), 
                                                        elem.classList.remove('active') ) ;

        })
    }

    calculateCartTotalValue()
    {
       this.cartTotalValue = 0;

       this.cartTotalValue = this.cartItemList.reduce((total, currentRow)=>{
            return total + Number(currentRow.SAC_ACCSVALUE__c);
        },0);

        this.cartTotalItems = this.cartItemList.length;
    }

    setTradableInactive(){
        this.template.querySelectorAll('button[data-disabled="N"]').forEach(elem=>{
            elem.setAttribute("disabled", true);
        });
        this.returnFromGetAccessoriesMaster = false;
    }
    

    collapseExpandSection(event){
        //const currentSection = event.currentTarget.dataset.node;
        event.currentTarget.getAttribute('aria-expanded') === "true" ? this.template.querySelector(`div[data-node=${event.currentTarget.dataset.node}]`).classList.remove('show') : 
                                                                        this.template.querySelector(`div[data-node=${event.currentTarget.dataset.node}]`).classList.add('show');
        event.currentTarget.getAttribute('aria-expanded') === "true" ? event.currentTarget.classList.remove('show') : 
                                                                        event.currentTarget.classList.add('show');
        event.currentTarget.getAttribute('aria-expanded') === "true" ? event.currentTarget.setAttribute('aria-expanded', false) :  
                                                                        event.currentTarget.setAttribute('aria-expanded', true); 

    }

    processExistingList(){
        this.cartItemList.push(...this.existingList);
        this.firstTimeProcessExistingList = true;
        this.calculateCartTotalValue();
    }

    processUIForExistingList(){
        if(this.firstTimeProcessExistingList === false) return;
        this.cartItemList.forEach(dataRow=>{
            const currentButton = dataRow.SAC_ACCSTRADE__c === 'N' ? 'add' : 'deal';

            this.template.querySelectorAll(`button[data-itemid=${dataRow.Accessories_Master__c}]`).forEach(elem=>{
                elem.className.includes(currentButton) && elem.classList.add('active'); 
            })
        });
        
    
    }

    removePackageAddon(data){
        const masterList = [];
        data.forEach(elem=>{
            this.packageExistingList.find(packageElem=> packageElem.Accessories_Master__c === elem.Id) === undefined && masterList.push(elem);
        })
        return masterList;
    }

    processGroupSection(){
        this.additionAccessoriesGroup = this.accessoriesMasterList.filter(item => item.AccessoriesGroup__c === 'ADDITIONAL ACCESSORIES');
        this.mainAccessoriesGroup = this.accessoriesMasterList.filter(item => item.AccessoriesGroup__c === 'MAIN ACCESSORIES');
        this.insuranceGroup = this.accessoriesMasterList.filter(item => item.AccessoriesGroup__c === 'INSURANCE');
        this.warrantyGroup = this.accessoriesMasterList.filter(item => item.AccessoriesGroup__c === 'WARRANTY');
        this.promotionGroup = this.accessoriesMasterList.filter(item => item.AccessoriesGroup__c === 'PROMOTIONS & DISCOUNTS');
        this.returnFromGetAccessoriesMaster = true;
         //this.serviceGroup = this.accessoriesMasterList.filter(item => item.AccessoriesGroup__c === 'SERVICE');
        //this.setTradableInactive();
    }
    
    onCloseModel(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    onDoneAndSave(){

        processSAAccessories({
            accessorylist : this.cartItemList,
            accessorylistToBeDeleted : this.cartItemListToRemove
        }).then(result=>{
            const returnResult = {addonList : result,
                                 cartTotalValue : this.cartTotalValue};
            this.dispatchEvent(new CustomEvent('donesaving', {
                detail:  returnResult
            }));

        }).catch(error=>{
            this.error = error;
        })
    }
}