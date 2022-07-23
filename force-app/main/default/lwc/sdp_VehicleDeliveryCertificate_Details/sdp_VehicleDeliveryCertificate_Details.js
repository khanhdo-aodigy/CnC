/*es-list-disable-no-console*/
import { LightningElement, track, api, wire } from 'lwc';
import getRecords from '@salesforce/apex/SDP_VehicleDeliveryCertificateController.getRecords';
import saveRecord from '@salesforce/apex/SDP_VehicleDeliveryCertificateController.saveRecord';
import saveCertificate from '@salesforce/apex/SDP_VehicleDeliveryCertificateController.saveCertificate';
import createAttachment from '@salesforce/apex/SDP_VehicleDeliveryCertificateController.createAttachment';
import sendEmail from '@salesforce/apex/SDP_VehicleDeliveryCertificateController.sendEmail';
import updateVSMS from '@salesforce/apex/VSMS_VDCUpdate.updateVSMS';
import CnC_App_Content from '@salesforce/resourceUrl/CnC_App_Content';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';



export default class Sdp_VehicleDeliveryCertificate_Details extends NavigationMixin(LightningElement) {
    @api recordId;

    @track displayDetail = false;
    @track isCollapse = false;
    @track availableTabs = ['vehicleInfo-tab', 'addnlAccs-tab'];
    @track isVehicleInfoTab = true;
    @track acknowledge = false;
    @track acknowledge_OBO = false;
    @track wiredRecords;
    @track franchiseCode;
    @track buttonDisable = false;
    @track showModal = false;
    @track previewLink = '';
    @track allHandoverItemsChecked = false;
    @track displayToast = false;
    @track toastMessage = 'Test Toast Message';
    toastVariants = ['no', 'success', 'info', 'warning', 'danger'];
    toastVariant = '';
    @track attachmentLink = '';
    @track comment_OBO = '';
    @track detailHide = false;
    isPreview = false;
    @track agreement;

    // VSMS callout prop
    @track VSMS_calling = false;
    @track VSMS_success = false;
    @track VSMS_fail = false;
    @track VSMS_successMsg = '';
    @track VSMS_failMsg = '';
    showAttachmentLink = false;

    @track showAppScreen = false;
    cncAppContent = CnC_App_Content;
    changes = {
        VDC_Additional_Accessories_Cart__c: '', // handle undefined
        VDC_Main_Accessories_Cart__c: '', // handle undefined
        VDC_OBO_Comment__c: '' // handle undefined
    };
    mainCart = [];
    additionalCart = [];
    outstandingCart = [];
    collapseHeight = 0; // store total collapsed amount

    @track ownerFullName;
    @track customerDetails = [
        {'row': '1', 
        'l_label': 'First Name', 'l_api': 'FirstName__c' ,'l_value': '', 
        'r_label': 'Surname', 'r_api': 'Surname__c', 'r_value': ''},
        {'row': '2', 
        'l_label': 'Mobile Number', 'l_api': 'MobileSA__c' ,'l_value': '', 
        'r_label': 'Email', 'r_api': 'emailaddress__c', 'r_value': ''},
    ];
    
    @track vehicleDetails = [
        {'row': '1', 
        'l_label': 'Model', 'l_api': 'Model__c', 'l_value': '', 
        'r_label': 'Vehicle Number', 'r_api': 'SOH_REGNO__c', 'r_value': ''},
        {'row': '2', 
        'l_label': 'Colour', 'l_api':'Color__c', 'l_value': '', 
        'r_label': 'IU Serial Number', 'r_api': 'SOH_IUD_IUDOCNO__c', 'r_value': ''},
        {'row': '3', 
        'l_label': 'Registration Date', 'l_api': 'Registration_Date__c', 'l_value': '', 
        'r_label': 'Delivery Date', 'r_api': 'Car_Collection_Date__c', 'r_value': ''},
    ];

    constructor() {
        super();
        this.template.addEventListener('handoveritem_selected', this.handoverItemsCheck.bind(this));
        this.template.addEventListener('signurl', this.onDataUrl.bind(this));
        this.template.addEventListener('cart_update', this.onCartUpdate.bind(this));
        this.template.addEventListener('outstanding_cart', this.onOutstandingCart.bind(this));
        this.template.addEventListener('modal_clicked', this.openAppScreen.bind(this));
        this.template.addEventListener('item_section_selected', this.handleSubTabSelected.bind(this));
        this.template.addEventListener('checklist_section_selected', this.handleSubTabSelected.bind(this));
        window.addEventListener('scroll', this.scrollHandler.bind(this), { passive: false });
    }

    disconnectedCallback() {
        this.template.removeEventListener('handoveritem_selected');
        this.template.removeEventListener('signurl');
        this.template.removeEventListener('cart_update');
        this.template.removeEventListener('outstanding_cart');
        this.template.removeEventListener('modal_clicked');
        this.template.removeEventListener('item_section_selected');
        this.template.removeEventListener('checklist_section_selected');
        window.removeEventListener('scroll');
    }
    

    @wire(getRecords, {
        objectName: 'Sales_Agreement__c',
        filter: 'Id',
        value: '$recordId',
        moreConditions: ''
    }) streaming(result) {
        this.wiredRecords = result;
        if (result.data && result.data.length === 1) {
            console.log('Wiring Success');
            let record = result.data[0]; // potentially error
            this.agreement = result.data[0];
            this.franchiseCode = record.FranchiseCode__c;
            this.ownerFullName = record.Sales_Consultant__c;
            this.acknowledge = record.Acknowledgement_Vehicle_Delivery__c;
            this.acknowledge_OBO = record.Acknowledgement_Vehicle_Collection_OBO__c;
            this.comment_OBO = record.VDC_OBO_Comment__c || '';
            this.buttonDisable = !(this.allHandoverItemsChecked && this.acknowledge);

            this.customerDetails.forEach(detail => {
                detail.l_value = record[detail.l_api];
                detail.r_value = record[detail.r_api];
            });
            this.vehicleDetails.forEach(detail => {
                detail.l_value = record[detail.l_api];
                detail.r_value = record[detail.r_api];
            });
            this.displayDetail = true;
            // apply blue border line of acknowledge clause if uncheck
            // set time out to make sure the element is rendered
            if(!this.acknowledge || this.acknowledge == null || this.acknowledge == undefined)
            window.setTimeout(this.applyBlueBorderLine.bind(this), 200);
        }

        if(!result.data) {
            this.toast('danger', 'No record found', 0);
            // TODO: process when failed
            this.displayDetail = false;
        }
    }

    /**
     * Handle when user click on customer acknowdledge checkbox
     */
    handleAcknowledge() {
        this.acknowledge = !this.acknowledge;
        this.buttonDisable = !(this.allHandoverItemsChecked && this.acknowledge);
        this.changes = Object.assign(this.changes, {Acknowledgement_Vehicle_Delivery__c : this.acknowledge})

        // change the style of the clause
        if(!this.acknowledge) this.applyBlueBorderLine();
        if(this.acknowledge) this.removeBlueBorderLine();
    }

    /**
     * Apply border line to acknowledge section
     * This method is not critical function so we allow them to fail silent
     */
    applyBlueBorderLine() {
        try {
            this.template.querySelector(`[data-id="acknowledgement-section"]`).classList.add('blue-borderline');
        } catch(e){console.log(e)}
    }

    /**
     * Remove border line to acknowledge section
     * This method is not critical function so we allow them to fail silent
     */
    removeBlueBorderLine() {
        try {
            this.template.querySelector(`[data-id="acknowledgement-section"]`).classList.remove('blue-borderline');
        } catch(e){console.log(e)} // fail silent
    }

    /**
     * Handle when user click on OBO acknowledge checkbox
     */
    handleAcknowledge_OBO() {
        this.acknowledge_OBO = !this.acknowledge_OBO;
        this.changes = Object.assign(this.changes, {Acknowledgement_Vehicle_Collection_OBO__c : this.acknowledge_OBO})
    }

    /**
     * Handle event receive by Handover Items component when item clicked
     * @param {any} payload : true when all items is selected
     */
    handoverItemsCheck(payload) {
        this.allHandoverItemsChecked = payload.detail;
        this.buttonDisable = !(this.allHandoverItemsChecked && this.acknowledge);
    }

    commentChange(e) {
        this.comment_OBO = e.target.value;
        this.changes = Object.assign(this.changes, {VDC_OBO_Comment__c : this.comment_OBO});
    }

    /**
     * Handle when user click on Preview Certificate button
     */
    previewPDF() {
        this.hideToast();
        this.buttonDisable = true;
        this.isPreview = true; // preview or save flag
        this.getSignatureData();
    }

    /**
     * Handle when user click on Save Certificate button
     */
    savePDF() {
        // check collection date & save
        if (this.agreement.Car_Collection_Date__c == null || this.agreement.Car_Collection_Date__c == undefined) {
            this.changes = Object.assign(this.changes, {Car_Collection_Date__c : '_insert'});
        }
        
        this.hideToast(); // reset toast setting
        this.toast('info', '... Saving Certificate as attachment ...', 0);
        this.buttonDisable = true;
        this.isPreview = false; // preview or save flag
        this.getSignatureData();
    }

    /**
     * Invoke api method on sign pad component to get image data
     */
    getSignatureData() {
        let signingPad = this.template.querySelector(`[data-id="sign_pad"]`);
        signingPad.toDataUrl();
    }

    /**
     * Handle when receive data URL from sign pad component
     * @param {any} payload : data URL
     */
    onDataUrl(payload) {
        let dataUrlAsImage = '<img src="'+ payload.detail + '">';
        this.changes = Object.assign(this.changes, {VDC_Customer_Signature__c : dataUrlAsImage});
        if (this.isPreview) this.preview();
        if (!this.isPreview) this.submit();
    }

    /**
     * Handle certificate preview
     */
    preview() {
        this.attachmentLink = null; // hide the link for default
        saveRecord({
            recordId: this.recordId,
            changes: this.changes
        })
        .then(result => {
            this.buttonDisable = false;
            this.toast('success','Preview opened in new tab. Please be noted that this is just a preview not an actual attachment. Click on Save Certificate button to save this certificate as attachment of Sales Agreement.', 0);
            this.openPreview();
        })
        .catch(error => {
            this.buttonDisable = false;
            this.toast('danger', JSON.stringify(error), 0);
        })
    }

    /**
     * Handle certificate submit, side affect is create outstanding accessories records for item not selected
     */
    submit() {
        this.attachmentLink = null; // hide the link for default
        saveCertificate({
            recordId: this.recordId,
            changes: this.changes
        }).then(result => {
            window.setTimeout(this.createAttachment.bind(this), 3000); // wait 3 secs for DB update to take effect
        }).catch(error => {
            this.buttonDisable = false;
            this.toast('danger', JSON.stringify(error), 0);
        })
    }

    /**
     * Create attachment for generated VDC and attach to related SA
     */
    createAttachment() {
        createAttachment({
            recordId: this.recordId,
        }).then(result => {
            this.attachmentLink = this.getAttachmentPreviewLink(result);
            this.sendEmail(this.recordId);
        }).catch(error => {
            this.buttonDisable = false;
            this.toast('danger', JSON.stringify(error), 0);
        })
    }

    /**
     * Email to customer regarding the VDC
     */
    sendEmail() {
        sendEmail({
            recordId: this.recordId,
        }).then(result => {
            this.showAttachmentLink = true;
            this.buttonDisable = false;
            this.toast('success','Certificate has been saved as an attachment and email to ' + this.agreement.emailaddress__c + '. ', 0);
            this.syncToVSMS();
        }).catch(error => {
            this.buttonDisable = false;
            this.toast('danger', JSON.stringify(error), 0);
        })
    }

    /**
     * Callout to update VSMS about the delivery date
     */
    syncToVSMS() {
        this.VSMS_calling = true;
        updateVSMS({
            agreementID: this.recordId,
        }).then(result => {
            let response = JSON.parse(result);
            this.VSMS_calling = false;
            if (response["status"] == 'success') {
                this.VSMS_success = true;
                this.VSMS_successMsg = response["message"];
            } else {
                // handle error from VSMS
                this.VSMS_fail = true;
                this.VSMS_failMsg = response["message"];
            }
        }).catch(error => {
            // handle error from SFDC
            this.VSMS_calling = false;
            this.VSMS_fail = true;
            this.VSMS_failMsg = JSON.stringify(error);
        })
    }

    getAttachmentPreviewLink(attachmentID) {
        return "/lightning/r/ContentDocument/" + attachmentID + '/view';
    }

    openGeneratedAttachment() {
        window.open(this.attachmentLink, '_blank');
    }

    /**
     * Handle when receive checkout cart from Accessories component
     * @param {any} payload : check out cart
     */
    onCartUpdate(payload) {
        this.mainCart = payload.detail.main;
        this.additionalCart = payload.detail.additional;
        this.changes = Object.assign(this.changes, {VDC_Additional_Accessories_Cart__c : this.additionalCart.join(',')});
        this.changes = Object.assign(this.changes, {VDC_Main_Accessories_Cart__c : this.mainCart.join(',')});
    }

    /**
     * Handle when receive outstanding accessories from Accessories component
     * @param {any} payload : outstanding accessories
     */
    onOutstandingCart(payload) {
        this.outstandingCart = payload.detail;
    }

    /**
     * Open pdf preview in new tab
     */
    openPreview() {
        window.open("/apex/VehicleDeliveryCertificate_pdf?id=" + this.recordId,'_blank');
    }

    /**
     * Close this page
     */
    closePage() {
        window.close();
    }

    /**
     * @depreciated close modal
     */
    modalCancel() {
        this.showModal = false;
        // TODO: call the method on signpad component to rebuild signature
    }

    /**
     * @depreciated submit certificate from inside modal
     */
    certificateSubmit() {
        this.showModal = false;
    }

    /**
     * Exposed method to toast
     * @param {string} variant : toast brand
     * @param {string} message : toast message
     * @param {integer} dismiss : time before dismiss, if no dismiss put 0
     */
    toast(variant, message, dismiss) {
        try {
            this.handleToast(variant, message);
            if (dismiss > 0) window.setTimeout(this.handleToast.bind(this), dismiss);
        } catch(e) {}
        
    }

    /**
     * Hide the toast panel
     */
    hideToast() {
        let toastContainer = this.template.querySelector(`[data-id="toast-panel"]`);
        toastContainer.classList.add('invisible-element');
        toastContainer.classList.remove('visible-element');
        this.showAttachmentLink = false;
        this.VSMS_calling = false;
        this.VSMS_fail = false;
        this.VSMS_success = false;
        this.VSMS_failMsg = '';
        this.VSMS_successMsg = '';
    }

    /**
     * Show the toast panel
     */
    showToast() {
        let toastContainer = this.template.querySelector(`[data-id="toast-panel"]`);
        toastContainer.classList.add('visible-element');
        toastContainer.classList.remove('invisible-element');
    }

    /**
     * Work horse of toasting
     * @param {string} variant : toast brand
     * @param {string} message : toast message
     */
    handleToast(variant = 'no', message = '') {
        // check variant in list
        if (!this.toastVariants.includes(variant)) return;

        // show/hide toast panel
        if (variant === 'no') {this.hideToast(); return}
        if (variant !== 'no') this.showToast();

        // change toast panel attribute
        let toastPanel = this.template.querySelector(`[data-id="toast-panel"]`);
        let attrList = toastPanel.classList;
        let removeAttr = '';
        for (let i = 0; i < attrList.length; i++) {
            if (attrList[i].includes('alert-') && attrList[i] !== 'alert-dismissible') {removeAttr = attrList[i]; break;}
        }
        this.toastMessage = message;
        this.toastVariant = variant.toUpperCase();
        toastPanel.classList.remove(removeAttr);
        toastPanel.classList.add('alert-' + variant);
    }

    /**
     * Handle to collapse the detail panel when user click on header arrow
     */
    handleCollapse() {
        this.detailHide = !this.detailHide; // change the arrow
        let detailPanel = this.template.querySelector(`[data-id="detail-panel"]`);
        
        if (!this.detailHide) {
            detailPanel.classList.add('visible-element');
            detailPanel.classList.remove('invisible-element');
        }
        
        if (this.detailHide) {
            detailPanel.classList.add('invisible-element');
            detailPanel.classList.remove('visible-element');
        }
    }

    /**
     * Handle when user click on tabs
     * @param {any} event 
     */
    switchTab(event) {
        //Handling for displaying Tab Content
        let targetId = event.target.dataset.targetId;
        if (targetId === 'vehicleInfo') {
            
            // show vehicle tab
            this.template.querySelector(`[data-id="vehicle-tab"]`).classList.add('visible-element');
            this.template.querySelector(`[data-id="vehicle-tab"]`).classList.remove('invisible-element');

            // hide accessories tab
            this.template.querySelector(`[data-id="accessories-tab"]`).classList.add('invisible-element');
            this.template.querySelector(`[data-id="accessories-tab"]`).classList.remove('visible-element');
        } else {
            // hide vehicle tab
            this.template.querySelector(`[data-id="vehicle-tab"]`).classList.add('invisible-element');
            this.template.querySelector(`[data-id="vehicle-tab"]`).classList.remove('visible-element');

            // show accessories tab
            this.template.querySelector(`[data-id="accessories-tab"]`).classList.add('visible-element');
            this.template.querySelector(`[data-id="accessories-tab"]`).classList.remove('invisible-element');
        }

        // tab headers styling
        let targetTab = event.target.getAttribute("data-id");
        this.availableTabs.forEach(tabs => {
            if (tabs === targetTab) {
                this.template.querySelector(`[data-id="${tabs}"]`).classList.add('active');
                this.template.querySelector(`[data-id="${tabs}"]`).classList.add('chosenTabs');
                this.template.querySelector(`[data-id="${tabs}"]`).classList.remove('notchosenTabs');
            } else {
                this.template.querySelector(`[data-id="${tabs}"]`).classList.remove('active');
                this.template.querySelector(`[data-id="${tabs}"]`).classList.add('notchosenTabs');
                this.template.querySelector(`[data-id="${tabs}"]`).classList.remove('chosenTabs');
            }
        });
    }

    /**
     -- when sub tab selected, scroll to tab header
     -- setTimeout to avoid conflict with Boostrap motion
     */
    handleSubTabSelected(e) {
        e.detail && window.setTimeout(this.scrollToTabsHeader.bind(this), 200);
    }

    /**
     -- scroll to a tab header
     */
    scrollToTabsHeader() {
        let el = this.template.querySelector(`[data-id="tab-headers"]`);
        let y = el.getBoundingClientRect().top + window.scrollY - 75;
        window.scroll({
            top: y,
            behavior: 'smooth'
        });
    }

    /**
     -- Handle when user scrolling, the purpose is to auto collapse detail panel when scroll down
     */
    scrollHandler() {
        
        /**
         -- dynamic calculate the collapse point's height
         -- default value is 900px
         -- wrap in try catch to prevent error when element is not rendered yet
         */
        let collapsePoint = 900;
        try {
            let collapsePointElement = this.template.querySelector(`[data-id="collapse-point"]`);
            collapsePoint = window.pageYOffset + collapsePointElement.getBoundingClientRect().top;
        } catch(e) {}
        
        /**
         -- when user scroll down past collapse point: collapse detail section
         -- iOS Safari user will experience a recoil due to shorten in document's height
         -- to compensate for this: move document down an amount equal to collapsed amount to have smooth UX
         -- another side effect: a white padding space in top of document
         -- to compensate for this: see below
         */
        if (window.pageYOffset >= collapsePoint) {
            if (this.detailHide) return; // if detail already collapsed do nothing
            let detailPanel = this.template.querySelector(`[data-id="detail-panel"]`);
            this.collapseHeight = this.collapseHeight + detailPanel.getBoundingClientRect().bottom - detailPanel.getBoundingClientRect().top;
            this.y_ElementMove('overlord-container', this.collapseHeight, true);
            this.handleCollapse();
        }

        /**
         -- when user scroll up past collapse point after detail collapsed:
         -- move element along the scrolling to prevent user seeing the white padding space from translating above
         -- also updating new collapse height equal scrollY for later
         */
        if (window.pageYOffset < collapsePoint) {

            if (this.collapseHeight <= 0) return; // prevent unpredictable behaviour

            if (window.scrollY < this.collapseHeight) {
                this.collapseHeight = window.scrollY < 0? 0 : window.scrollY;
                this.y_ElementMove('overlord-container', this.collapseHeight, true);
            }
        }
    }

    /**
     -- open C&C App modal
     */
    openAppScreen(payload) {
        this.showAppScreen = true;
    }

    /**
     -- close C&C App modal
     */
    closeAppScreen(e) {
        this.showAppScreen = false;
    }

    /**
     * Move element up or down
     */
    y_ElementMove(elemDataId, translateAmount, moveDown) {
        if (moveDown) this.template.querySelector(`[data-id="${elemDataId}"]`).style.transform = "translate(0, " + translateAmount + "px)";
        if (!moveDown) this.template.querySelector(`[data-id="${elemDataId}"]`).style.transform = "translate(0, -" + translateAmount + "px)";
    }
}