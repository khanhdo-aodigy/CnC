import { LightningElement,api, track } from 'lwc';
import sdpBootstrap from '@salesforce/resourceUrl/sdpBootstrap';

export default class ImgCmp extends LightningElement {
    @api urlToResource;
    @api styleWidth;

    @track currentSize = '';
    @track initialRender = true;

    renderedCallback() {
        if (this.initialRender) {
            this.initialiseStyle();
            this.initialRender = false;
        }
    }

    initialiseStyle(){
        if(this.styleWidth !== '' || this.styleWidth !== undefined){
            this.currentSize = 'width:' + this.styleWidth;
        }
    }

    get getSvgURL(){
        return `${sdpBootstrap}${this.urlToResource}`;
    }
}