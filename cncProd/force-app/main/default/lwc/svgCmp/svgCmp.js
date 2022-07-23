import {
    LightningElement,
    api
} from 'lwc';
import sdpBootstrap from '@salesforce/resourceUrl/sdpBootstrap';

export default class SvgCmp extends LightningElement {
    @api urlToResource;
    @api svgClass = "icon";
    @api svgRole = "img";
    @api svgAriaHidden = false;

    get getSvgURL(){
        return `${sdpBootstrap}${this.urlToResource}`;
    }
}