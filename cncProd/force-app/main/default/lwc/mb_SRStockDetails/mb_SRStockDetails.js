import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import MBSRMC from '@salesforce/messageChannel/MBSRMC__c';

export default class Mb_SRStockDetails extends LightningElement {

    /**
     * metadata for data table
     */
    headers = [
        {
            api : 'Vehicle_ID__c',
            label : 'Stock No',
            hidden : false,
        },
        {
            api : 'VariantDescription__c',
            label : 'Variant',
            hidden : false,
        },
        {
            api : '@Colour__c/Trim__c',
            label : 'Color/Trim',
            hidden : false,
        },
        {
            api : 'Estimated_Delivery_Date__c',
            label : 'EDD',
            hidden : false,
        },
        {
            api : 'Remarks__c',
            label : 'Remarks',
            hidden : false,
        },
        {
            api : '_HLOs_',
            label : 'Option List',
            hidden : false,
        },
        {
            api : '_Promotions_',
            label : 'Promotion',
            hidden : false,
        },
        {
            api : 'Id',
            label : 'Id',
            hidden : true,
        },
    ]

    @track ready = false;
    @track vehicles = [];           // processed data to show
    data;                           // raw stock data passed down by parent
    availableHLO = [];              // selected HLOs passed down by parent
    selectedStockID;

    @wire (MessageContext)
    messageContext;

    subscription = null;

    subscribeToMessageChannel() {
        if (this.subscription) return;
        
        this.subscription = subscribe(
            this.messageContext, 
            MBSRMC, 
            (message) => {
                this.handleMessage(message);
            }
        );
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel;
    }

    handleMessage(message) {
        
        let message_ = this.deepClone(message);
  
        let action = message_.action;
  
        switch(action) {
            case 'detail':
                this.data = message_.data.stock;
                this.availableHLO = this.filterDuplicateHLO(message_.data.availableHLO);
                this.selectedStockID = null;            // reset selected stock ID
                this.showDetail();
                break;
            case 'reset':
                this.reset();
            default:
                break;
        }
    }

    showDetail() {
        this.processData();
    }

    /**
     * process raw data to table showing format using header metadata
     */
    processData() {

        // safe check
        if (this.data == undefined || this.data == null || this.data.length == 0) {
            this.toast('WARNING', 'Stock data is unavailable', null, 'warning', 'sticky');
            this.ready = false;
            return;
        }

        this.vehicles = [];
        // console.log(JSON.stringify(this.data));

        for (let record of this.data) {
            let record_ = [];
            for (let metadata of this.headers) {
                
                // combine field
                if (metadata.api.startsWith('@')) {
                    let value = this.getCombinedValue(record, metadata.api, '/');
                    record_.push({
                        api : metadata.api,
                        value : value,
                        hidden : metadata.hidden,
                    });
                    continue;
                }
                
                // special fields
                if (metadata.api.startsWith('_')) {

                    if (metadata.api == '_Promotions_') {
                        let promotions = this.getPromotionValue(record);
                        record_.push({
                            api : metadata.api,
                            promotions : promotions,
                            hidden : metadata.hidden,
                            isPromo : true,
                        });
                        console.log('ALL PROMOS:: ' + JSON.stringify(promotions));
                        continue;
                    }

                    if (metadata.api == '_HLOs_') {
                        record_.push({
                            api : metadata.api,
                            // HLOs : this.availableHLO,
                            HLOs : this.getStockHLO(record.MB_SVM_Specs__r),
                            hidden : metadata.hidden,
                            isHLO : true,
                        });
                        continue;
                    }
                }
                
                record_.push({
                    api : metadata.api,
                    value : record[metadata.api],
                    hidden : metadata.hidden,
                })
            }
            this.vehicles.push({
                Id : record['Id'],
                props : this.deepClone(record_),
                specs : this.deepClone(record['MB_SVM_Specs__r']),
            });
        }
        this.ready = true;
        // console.log('vehicles :: ', JSON.stringify(this.vehicles));
    }

    /**
     * filter duplicate HLO
     * @param {*} availableHLO 
     */
    filterDuplicateHLO(availableHLO) {

        console.log('availableHLO ::', availableHLO);

        if (availableHLO == undefined || availableHLO == null || availableHLO.length == 0) return '';   // nothing to process

        let HLOs = [];
        let HLOcodes = [];

        for (let HLO of availableHLO) {
            !HLOcodes.includes(HLO.code) && HLOs.push(HLO) && HLOcodes.push(HLO.code);
        }

        return HLOs;
    }

    getStockHLO(svmSpecs) {
        let stockHLOs = [];
        if (svmSpecs == undefined || svmSpecs == null || svmSpecs.length == 0) return stockHLOs;   // nothing to process

        for (let svmSpec of svmSpecs) {
            // let desc = svmSpec.Description__c || '';
            for (let HLO of this.availableHLO) {
                HLO.code == svmSpec.Product__c && stockHLOs.push(HLO);
            }
        }

        return stockHLOs;
    }

    getPromotionValue(record) {
        let promotions = [];

        let promotionStocks = record['MB_Promotions__r'];

        // safe check
        if (promotionStocks == undefined || promotionStocks == null || promotionStocks.length == 0) return '';

        for (let promoStock of promotionStocks) {
            promotions.push({
                id : promoStock['MB_Promotion__r']['Id'],
                name : promoStock['MB_Promotion__r']['Name'],
                tooltip : this.getPromotionTooltip(promoStock),
            })

            // promotions.push(promoStock['MB_Promotion__r']['Name']);
        }

        // return promotions;
        // return promos.filter((promo, index, tmpPromo) => )
        return this.removeDuplicates(promotions, 'id');
        // return promotions.join('; ');
    }

    getPromotionTooltip(promoStock) {
        let tooltip = '';
        tooltip += '[Effective Date] ' + promoStock['MB_Promotion__r']['Start_Date__c'] + ' to ' + promoStock['MB_Promotion__r']['End_Date__c'] + ' ';
        tooltip += '[Description] ' + promoStock['MB_Promotion__r']['Description__c'];
        return tooltip;
    }

    getCombinedValue(record, c_api, separator) {

        c_api = c_api.replace('@','');

        let apis = c_api.split(separator);

        for (let api of apis) {
            let value = record[api] || '';
            c_api = c_api.replace(api, value);
        }

        return c_api;
    }

    reserveStock(event) {
        // window.alert('Stock Reserve');
        let vid = event.currentTarget.dataset.vid;
        // console.log('Reserve stock :: ' + vid);

        // safe check
        if (vid == undefined || vid == null) {
            this.toast('WARNING', 'Unale to get stock ID. Contact your admin.', null, 'warning', 'sticky');
            return;
        }

        this.selectedStockID = vid;                     // store selected stock ID
        let stockNo;
        let color;
        let trim;
        let description;
        let isExist = false;

        for (let record of this.data) {
            if (record.Id == vid) {
                stockNo = record.Vehicle_ID__c;
                color = record.Colour__c;
                trim = record.Trim__c;
                description = record.VariantDescription__c;
                isExist = true;
                break;
            }
        }

        // safe check
        if (!isExist) {
            this.toast('WARNING', 'Unale to find the stock with this ID: ' + vid + '. Contact your admin.', null, 'warning', 'sticky');
            return;
        }
        
        // fire event to customer component
        const payload = {
            action : 'customer',
            data : {
                stockNo, color, trim, description, vid
            }
        }

        publish(this.messageContext, MBSRMC, payload);
    }

    toast(title, message, msgData, variant, mode) {
        const toastEvent = new ShowToastEvent({
           'title' : title,
           'message' : message,
           'messageData' : msgData,
           'variant' : variant,
           'mode' : mode
        });
        this.dispatchEvent(toastEvent);
    }

    reset() {
        this.vehicles = [];
        this.data = null;
        this.selectedStockID = null;
        this.ready = false;
    }

    showSpecs(event) {
        let vid = event.currentTarget.dataset.vid;
        
        let table = this.template.querySelector(`[data-subid="${vid}"]`);

        if (table.style.display == 'initial') {
            event.currentTarget.label = 'Show Specs';
            table.style.display = 'none';
        } else {
            event.currentTarget.label = 'Hide Specs';
            table.style.display = 'initial';
        }
    }

    deepClone(data) {
        return JSON.parse(JSON.stringify(data));
    }

    removeDuplicates(array, key) {
        let objToCheck = {};
        return array.filter(obj => !objToCheck[obj[key]] && (objToCheck[obj[key]] = true));
    }
}