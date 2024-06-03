import { api, LightningElement } from 'lwc';
import defaultTemplate from './default.html'

export default class Illustration extends LightningElement {
    @api size='small'; //values: small, large.
    @api title ='no content';
    @api subtitle;
    @api template = 'nodata';

    get className() {
        return `slds-illustration slds-illustration_${this.size}`;
    }

    render() {
        return defaultTemplate;
    }
}