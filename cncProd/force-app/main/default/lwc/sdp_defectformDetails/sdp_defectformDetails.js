import { LightningElement, api, track, wire } from 'lwc';

export default class Sdp_defectformDetails extends LightningElement {
    @api salesAgreementObj;
    @api deviceType;
    @api recordId;
    @track editMode = true;
    @track availableTabs = ['defects-tab', 'accessories-tab'];
    @track availableTabContents = ['Defects', 'OutstandingAccessories'];
    @track DefectTrueOutstandingFalse = true;
    @track isCollapse = false;
    @track HeaderTitle = 'Customer Details';

    connectedCallback() {
        window.addEventListener('scroll', this.scrollHandler.bind(this));
    }

    scrollHandler() {
        if (window.pageYOffset > 350) {
            this.CollapseStatusOn();
        } 
    }

    ChangeCollapseStatus() {
        this.isCollapse = !this.isCollapse;
        if (this.isCollapse === true) {
            this.template.querySelector(`[data-id="MainContainer"]`).classList.add('ApplyNonScrollable');
            this.HeaderTitle = 'Customer & Vehicle Details';
        } else {
            this.template.querySelector(`[data-id="MainContainer"]`).classList.remove('ApplyNonScrollable');
            this.HeaderTitle = 'Customer Details';
        }
    }

    CollapseStatusOn() {
        this.isCollapse = true;
        this.template.querySelector(`[data-id="MainContainer"]`).classList.add('ApplyNonScrollable');
        this.HeaderTitle = 'Customer & Vehicle Details';
    }

    CancelCommit() {
        window.close()
    }

    SwitchWindow(event) {
        //This is for the tab contents
        let targetId = event.target.dataset.targetId;
        if (targetId === 'Defects') {
            this.DefectTrueOutstandingFalse = true;
        } else {
            this.DefectTrueOutstandingFalse = false;
        }

        //This is for the tab
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

    MoveServiceCentrePage(data) {
        //this.template.querySelector('c-sdp_defectform-outstanding-accessories').refreshComponentRecords();
        this.dispatchEvent(new CustomEvent('activitychanged', {
            detail: { stage: 'SelectServiceCenter' }
        }));
    }
}