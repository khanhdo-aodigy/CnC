import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import getStock from '@salesforce/apex/MB_StockReservationCtrl.getStock';
import checkIndentable from '@salesforce/apex/MB_StockReservationCtrl.checkIndentable';
import MBSRMC from '@salesforce/messageChannel/MBSRMC__c';

export default class Mb_SRStockSummary extends LightningElement {

   model;                                          // selected model's ID
   variant;                                        // selected variant's Description
   colors = [];                                    // selected color codes
   trims = [];                                     // selected trim codes
   HLO = [];                                       // selected hightlight option IDs
   availableHLO = [];                              // available HLO options
   quantities = [];                                // number of stock aggregate by colors & trims and put into matrix format
   stock;                                          // store raw stock data that met search requirements
   selectedVariantId;                              // ADDED BY THIEU DANG VU - Mon 16th Nov 2020 - UAT LOG-0191 - Store variant Id
   promo;                                          // ADDED BY THIEU DANG VU - Mon 16th Nov 2020 - UAT LOG-0192 - selected Promo Id
   edd;                                            // ADDED BY THIEU DANG VU - Wed 2nd Dec 2020 - UAT LOG-0193 - selected EDD

   @api stockQuantity;                             // MB CR 25/03/2021 - Limit stock quantity based on variable

   @track ready = false;
   @track rowCSS = '';                             // dynamic CSS for table cells
   @track matrix = [];                             // matrix to render summary table
   @track spinner;

   // DISPLAY_LIMIT = 5;                              // limit displaying stock - MODIFIED BY THIEU DANG VU 26/11/2020 - MB UAT LOG-0221

   @wire (MessageContext)
   messageContext;

   subscription = null;

   subscribeToMessageChannel() {
      if (this.subscription) return;
      
      this.subscription = subscribe(this.messageContext, MBSRMC, (message) => {
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

   renderedCallback() {
      console.log('Stock quantity:: ' + this.stockQuantity);
   }

   handleMessage(message) {

      console.log('message :: ', message);

      let message_ = this.deepClone(message);

      let action = message_.action;

      switch(action) {
         case 'search':
            this.colors = message_.data.colours.sort();                             // MB CR 25/03/2021 - Display color and trim in sequential order
            this.trims = message_.data.trims.sort();                                // MB CR 25/03/2021 - Display color and trim in sequential order
            this.model = message_.data.modelId;
            // this.variant = message_.data.variantId;
            this.variant = message_.data.variant;                                   // ADDED BY THIEU DANG VU - Mon 16th Nov 2020 - UAT LOG-0191
            this.HLO = message_.data.highlightOptions;
            this.availableHLO = message_.data.availableHLO;
            this.selectedVariantId = message_.data.selectedVariantId;               // ADDED BY THIEU DANG VU - Mon 16th Nov 2020 - UAT LOG-0191
            this.promo = message_.data.promo;
            this.edd = message_.data.edd;                                           // ADDED BY THIEU DANG VU - Wed 2nd Dec 2020 - UAT LOG-0193
            this.showSummary();
            break;
         case 'reset':
            this.reset();
         default:
            break;
      }
   }

   /**
    * Process & show stock summary
    */
   showSummary() {
      
      if (!this.searchParamsValidate()) {
         this.ready = false;
         return;
      }
      this.spinner = true;
      getStock({
         // variantID : this.variant,
         variantDesc : this.variant,
         colors : this.colors,
         trims : this.trims,
         HLO : this.HLO,
         promoId : this.promo,
         edd : this.edd
      })
      .then(result => {
         console.log('RETURNED STOCKS:: ' + JSON.stringify(result));
         this.stock = this.deepClone(result);

         // this.quantities = this.getAggregateQuantity(this.colors, this.trims, 'Colour__c', 'Trim__c', this.stock);

         this.quantities = this.getAggregateQuantity(this.trims, this.colors, 'Trim__c', 'Colour__c', this.stock);

         // this.matrix = this.getMatrix(this.colors, this.trims, this.quantities);

         this.matrix = this.getMatrix(this.trims, this.colors, this.quantities);

         this.spinner = false;

         if (this.matrix != undefined && this.matrix != null && this.matrix.length != 0) {
            // this.rowCSS = 'slds-col slds-size_1-of-' + ++this.colors.length;
            this.rowCSS = 'slds-col slds-size_1-of-' + ++this.trims.length;
            this.ready = true;
         } else {
            this.toast('WARNING', 'The quantity matrix is undefined', null, 'warning', 'sticky');
            this.ready = false;
            return;
         }
      })
      .catch(error => {
         this.toastApexErrorMessage(error);
      });
   }

   /**
    * validate searching parameters
    */
   searchParamsValidate() {

      // must select model
      if (this.model == null || this.model == undefined) {
         this.toast('WARNING', 'Please select Model', null, 'warning', 'sticky');
         return false;
      }

      // must select variant
      if (this.variant == null || this.variant == undefined) {
         this.toast('WARNING', 'Please select Variant', null, 'warning', 'sticky');
         return false;
      }

      // must select at least 1 color
      if (this.colors == undefined || this.colors == null || this.colors.length == 0) {
         this.toast('WARNING', 'No stocks available', null, 'warning', 'sticky');
         return false;
      }

      // must select at least 1 trim
      if (this.trims == undefined || this.trims == null || this.trims.length == 0) {
         this.toast('WARNING', 'No stocks available', null, 'warning', 'sticky');
         return false;
      }

      // too many colors break the flex layout
      // if (this.colors.length > 11) {
      //    this.toast('WARNING', 'Maximum of 11 colors can be selected', null, 'warning', 'sticky');
      //    return false;
      // }

      return true;
   }

   /**
    * from @rawData agrregate stock quantity by @rowHeader & @colHeader and put into matrix format
    * @param {List} rowHeader : values of row header
    * @param {List} colHeader : values of column header
    * @param {String} rowField : API name of row field
    * @param {String} colField : API name of column field
    * @param {List} rawData : data to be aggregated
    */
   getAggregateQuantity(rowHeader, colHeader, rowField, colField, rawData) {
      
      let matrix = [];

      for (let ch of colHeader) {
         let row = [];
         
         for (let rh of rowHeader) {
            let quantity = 0;
            
            for (let rd of rawData) {
               if (rd[rowField].startsWith(rh) && rd[colField].startsWith(ch)) quantity++;
            }
            // quantity = (quantity > this.DISPLAY_LIMIT)? this.DISPLAY_LIMIT : quantity; // cap shown amount
            quantity = (quantity > this.stockQuantity)? this.stockQuantity : quantity;                            // MB CR 25/03/2021 - Limit stock quantity based on variable
            row.push(quantity);
         }
         
         matrix.push(this.deepClone(row));
      }
      
      console.log('quantity :: ', matrix);
      return matrix;
   }

   /**
    * wrap the @data matrix with @headers_ & @vheaders_ to display
    * @param {*} headers_ : label for header
    * @param {*} vheaders_ : label for vertical header 
    * @param {*} data 
    */
   getMatrix(headers_, vheaders_, data) {

      let ID_ = 0;                  // ad-hoc ID for refenrence
      let matrix = [];              // output matrix
      let headers = [];             // 1st row of @matrix

      if (!this.checkMatrixDimension(headers_, vheaders_, data)) {
         this.ready = false;
         return matrix;
      }

      // most top left cell
      headers.push({
         role : 'header',
         isHeader : true,
         isVHeader : false,
         isData : false,
         text : 'Color / Trim',
         ID : ID_++,
      })

      // horizontal headers
      for (let header_ of headers_) {
         headers.push({
            role : 'header',
            isHeader : true,
            isVHeader : false,
            isData : false,
            text : header_,
            ID : ID_++,
         });
      }

      matrix.push(headers);

      for (let i = 0; i < data.length; i++) {
         let row_ = [];                   // row of matrix
         let color = vheaders_[i];
         let quantities = data[i];

         // vertical header
         row_.push({
            role : 'vheader',
            isHeader : false,
            isVHeader : true,
            isData : false,
            text : color,
            ID : ID_++,
         });

         // data cell
         for (let j = 0; j < quantities.length; j++) {
            let quantity = quantities[j];
            // MODIFIED BY THIEU DANG VU - 27/11/2020 - Change background of button when quantity is not 0
            let isZero = quantity <= 0;
            let trim = headers_[j];
            row_.push({
               role : 'data',
               isHeader : false,
               isVHeader : false,
               isData : true,
               text : quantity,
               ID : ID_++,
               color : color,
               trim : trim,
               isZero : isZero
            });
         }
         matrix.push(row_);
      }

      console.log('matrix :: ', matrix);
      return matrix;
   }

   /**
    * check @data dimension against @colHeader & @rowHeader dimensions
    * @param {*} colHeader 
    * @param {*} rowHeader 
    * @param {*} data 
    */
   checkMatrixDimension(colHeader, rowHeader, data) {
      let dataRows = data.length || 0;
      let dataCols = data[0].length || 0;

      if (colHeader.length != dataCols) {
         this.toast('WARNING', 'Column header\'s length does not equal data rows', null, 'warning', 'sticky');
         return false;
      }

      if (rowHeader.length != dataRows) {
         this.toast('WARNING', 'Row header\'s length does not equal data columns', null, 'warning', 'sticky');
         return false;
      }

      return true;
   }

   stockSelect(event) {
      let color = event.currentTarget.dataset.color;
      let trim = event.currentTarget.dataset.trim;
      console.log('Color: ' + color + '. Trim: ' + trim);

      if (color == undefined || color == null) {
         this.toast('WARNING', 'Color undefined', null, 'warning', 'sticky');
         return;
      }

      if (trim == undefined || trim == null) {
         this.toast('WARNING', 'Trim undefined', null, 'warning', 'sticky');
         return;
      }

      console.log('AAAAAa:: ' + JSON.stringify(this.stock));
      if (this.stock == undefined || this.stock == null) {
         this.toast('WARNING', 'Stock undefined', null, 'warning', 'sticky');
         return;
      }

      let stock_ = [];                                               // stock to pass down to detail component
      let count_ = 0;

      for (let record of this.stock) {
         // record['Colour__c'].startsWith(color) && record['Trim__c'].startsWith(trim) && (count_++ < this.DISPLAY_LIMIT) && stock_.push(this.deepClone(record));
         record['Colour__c'].startsWith(color) && record['Trim__c'].startsWith(trim) && (count_++ < this.stockQuantity) && stock_.push(this.deepClone(record));      // MB CR 25/03/2021 - Limit stock quantity based on variable
      }

      // check if stock quantity is 0. Ask user to indent if OOS
      if (stock_.length == 0) {
         let confirm = window.confirm('This vehicle is currently out of stock. Would you like to indent?');
         
         if (!confirm) return;

         checkIndentable({
            // variantID : this.variant,
            variantID : this.selectedVariantId              // ADDED BY THIEU DANG VU - Mon 16th Nov 2020 - UAT LOG-0191
         })
         .then (result => {
            
            if (result == false) {
               this.toast('WARNING', 'This variant is not indentable', null, 'warning', 'sticky');
               return;
            }

            if (result == true) {
               const payload = {
                  action : 'indent',
                  data : {
                     modelId : this.model,
                     // variantId : this.variant,
                     variantId : this.selectedVariantId,    // ADDED BY THIEU DANG VU - Mon 16th Nov 2020 - UAT LOG-0191
                     color : color,
                     trim : trim,
                  }
               };
               publish(this.messageContext, MBSRMC, payload);
            }
         })
         .catch (error => {
            this.toastApexErrorMessage(error);
         })
      } else {
         // fire LSM event
         const payload = {
            action : 'detail',
            data : {
               stock : stock_,
               availableHLO : this.availableHLO,
            }
         };
         publish(this.messageContext, MBSRMC, payload);
      }
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

   toastApexErrorMessage(error) {
      let errMsg = 'unknow error';
      if (error != undefined && error != null) errMsg = error.message || error[0].message || JSON.stringify(error);
      this.toast('ERROR', errMsg, null, 'error', 'sticky');
   }

   reset() {
      this.variant = null;
      this.model = null;
      this.stock = null;
      this.colors = [];
      this.trims = [];
      this.availableHLO = [];
      this.HLO = [];
      this.data = [];
      this.matrix = [];
      this.ready = false;
      this.selectedVariantId = null;             // ADDED BY THIEU DANG VU - Mon 16th Nov 2020 - UAT LOG-0191
   }

   deepClone(data) {
      return JSON.parse(JSON.stringify(data));
   }
}