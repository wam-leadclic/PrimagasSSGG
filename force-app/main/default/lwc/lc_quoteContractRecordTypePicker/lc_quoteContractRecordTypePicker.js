import { wire, LightningElement, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getValidRecordTypeIdsForQuoteContracts from "@salesforce/apex/NuevoContratoCPQController.getValidRecordTypeOptionsForQuoteContracts"

import OPPORTUNITY_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__c';

export default class Lc_quoteContractRecordTypePicker extends NavigationMixin(LightningElement) {

    @api recordId;

    @wire(getRecord, { recordId: "$recordId", fields: [OPPORTUNITY_FIELD]})
    quote;

    recordTypeId;

    @wire(getValidRecordTypeIdsForQuoteContracts, {})
    validRecordTypesOptions;

    get options(){
        return (this.validRecordTypesOptions != null && this.validRecordTypesOptions.data != null) ? this.validRecordTypesOptions.data : [];
    }

    get areOptionsLoaded(){
        return this.options.length > 0;
    }

    get isRecordTypeNotSelected(){
        return !this.recordTypeId;
    }

    get isAllloaded(){
        return this.areOptionsLoaded && this.quote != null && this.quote.data != null;
    }

    handlePickRecordType(e){
        this.recordTypeId = e.currentTarget.value;
    }
      
    navigateToNewContractWithDefaults() {

        let contract = {
            recordTypeId : this.recordTypeId,
            SBQQ__Quote__c : this.recordId
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/apex/NuevoContratoCPQ?cosacosa=123&contract=${JSON.stringify(contract)}`
            }
        });
    }


}