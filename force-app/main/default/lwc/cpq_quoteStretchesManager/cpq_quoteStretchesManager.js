import { api, wire, track, LightningElement } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getFieldValue, getRecord } from 'lightning/uiRecordApi';

import QUOTE_STATUS_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Status__c';
import STRETCH_OBJECT from '@salesforce/schema/Stretch__c';

import getStretchesForQuote from '@salesforce/apex/CPQ_QuoteStretchesManagerCtrl.getStretchesForQuote';
import toggleStretchesForQuote from '@salesforce/apex/CPQ_QuoteStretchesManagerCtrl.toggleStretchesForQuote';
import generateNewStretch from '@salesforce/apex/CPQ_QuoteStretchesManagerCtrl.generateNewStretch';
import saveStretches from '@salesforce/apex/CPQ_QuoteStretchesManagerCtrl.save';
import fillDiscountInputForStretch from '@salesforce/apex/CPQ_QuoteStretchesManagerCtrl.fillDiscountInputForStretch';

import CPQ_MinimumStretchesNumberError from '@salesforce/label/c.CPQ_MinimumStretchesNumberError'
import CPQ_SaveSuccess from '@salesforce/label/c.CPQ_SaveSuccess'
import CPQ_ErrorOccurred from '@salesforce/label/c.CPQ_ErrorOccurred'
import CPQ_NoRate from '@salesforce/label/c.CPQ_NoRate'
import CPQ_UseStretches from '@salesforce/label/c.CPQ_UseStretches'
import CPQ_KgYear from '@salesforce/label/c.CPQ_KgYear'
import CPQ_EuroKg from '@salesforce/label/c.CPQ_EuroKg'
import CPQ_NoDiscountDurationSet from '@salesforce/label/c.CPQ_NoDiscountDurationSet'
import CPQ_SuggestDiscount from '@salesforce/label/c.CPQ_SuggestDiscount'
import CPQ_StretchesCLVHeader from '@salesforce/label/c.CPQ_StretchesCLVHeader'

const STATUS_DRAFT = 'Draft';
const MIN_STRETCHES = 3;

// eslint-disable-next-line @lwc/lwc/no-leading-uppercase-api-name
export default class Cpq_quoteStretchesManager extends LightningElement {

    Labels = {
        CPQ_MinimumStretchesNumberError : CPQ_MinimumStretchesNumberError.replace('{0}', MIN_STRETCHES),
        CPQ_SaveSuccess : CPQ_SaveSuccess,
        CPQ_ErrorOccurred : CPQ_ErrorOccurred,
        CPQ_NoRate : CPQ_NoRate,
        CPQ_UseStretches : CPQ_UseStretches,
        CPQ_KgYear : CPQ_KgYear,
        CPQ_EuroKg : CPQ_EuroKg,
        CPQ_NoDiscountDurationSet : CPQ_NoDiscountDurationSet,
        CPQ_SuggestDiscount : CPQ_SuggestDiscount,
        CPQ_StretchesCLVHeader : CPQ_StretchesCLVHeader
    }

    @api
    _recordId;

    @track
    stretchesList = [];

    isRequestLoading;
    isDiscountDurationSet;

    error;
    stretchesToggleChecked;

    @wire(getRecord, { recordId: '$_recordId', fields: [QUOTE_STATUS_FIELD] })
    quote;

    @wire(getObjectInfo, {objectApiName: STRETCH_OBJECT})
    stretchInfo;
    
    @api set recordId(value) {
        this._recordId = value;
        this.refreshStretches(true);
    }

    get areQuoteStretchesNotEditable(){
        return this.quote && this.quote.data && getFieldValue(this.quote.data, QUOTE_STATUS_FIELD) != STATUS_DRAFT;
    }
    
    get recordId() {
        return this._recordId;
    }
    get areStretchesCreated(){
        return this.stretchesList.length > 0;
    }

    get isBasicDataLoaded(){
        return this.stretchInfo && this.stretchInfo.data;
    }

    get areInputsDisabled(){
        return this.isRequestLoading || this.areQuoteStretchesNotEditable;
    }

    get areInputsEnabled(){
        return !this.areInputsDisabled;
    }

    toggleStretches(hasStretches){
        console.log("createStretches");
        this.isRequestLoading = true;
        toggleStretchesForQuote({quoteId : this.recordId, hasStretches : hasStretches})
            .then(result => {
                this.assignIndexesToStretches(result);
                this.stretchesList = result;
                console.log("StretchesList", JSON.parse(JSON.stringify(this.stretchesList)));
                this.stretchesToggleChecked = this.areStretchesCreated;
                this.isRequestLoading = false;
            })
            .catch(error => {
                this.displayError(error);
                this.isRequestLoading = false;
            });
    }

    handleSave(event){
        if(this.stretchesList.length < MIN_STRETCHES){
            this.showToast(this.Labels.CPQ_MinimumStretchesNumberError, null, 'error');
        }else{
            this.isRequestLoading = true;
    
            console.log("SAVE", JSON.parse(JSON.stringify(this.stretchesList)));

            saveStretches({stretchesListJSON : JSON.stringify(this.stretchesList), quoteId : this.recordId})
                .then(result => {
                    this.assignIndexesToStretches(result);
                    this.stretchesList = result;
                    this.isRequestLoading = false;
                    this.showToast(this.Labels.CPQ_SaveSuccess, null, 'success');
                })
                .catch(error => {
                    this.displayError(error);
                    this.isRequestLoading = false;
                });
        }
    }

    handleInsertNewStretch(event){
        let quoteId = event.currentTarget.dataset.quoteId;

        this.isRequestLoading = true;
        generateNewStretch({quoteId : quoteId})
            .then(result => {
                result.index = this.stretchesList.length + 1;
                this.stretchesList.push(result);
                this.isRequestLoading = false;
            })
            .catch(error => {
                this.displayError(error);
                this.isRequestLoading = false;
            });
    }

    handleFillDiscountForStretch(event){
        let index = event.currentTarget.dataset.index;

        this.isRequestLoading = true;
        fillDiscountInputForStretch({quoteId : this._recordId, stretchJSON : JSON.stringify(this.stretchesList[index])})
            .then(result => {
                this.stretchesList[index] = result;
                this.assignIndexesToStretches(this.stretchesList);
                this.isRequestLoading = false;
            })
            .catch(error => {
                this.displayError(error);
                this.isRequestLoading = false;
            });
    }
    
    assignIndexesToStretches(stretches){
        for(let i=0;i<stretches.length;i++){
            stretches[i].index = i;
        }
        console.log("REEEEEEEESULT", JSON.parse(JSON.stringify(this.stretchesList)));
    }

    handleDeleteStretch(event){
        if(this.stretchesList.length <= MIN_STRETCHES){
            this.showToast(this.Labels.CPQ_MinimumStretchesNumberError, null, 'error');
        }else{
            this.stretchesList.splice(event.currentTarget.dataset.index, 1);
        }
    }

    handleStretchesToggle(event){
        this.stretchesToggleChecked = event.currentTarget.checked;
        
        this.toggleStretches(this.stretchesToggleChecked);
    }

    handleInputChange(event){
        for(let component of this.template.querySelectorAll('lightning-input')){
            component.reportValidity();
            if(!component.checkValidity()){
                return;
            }
        }
        this.stretchesList[event.currentTarget.dataset.index][event.currentTarget.dataset.field] = event.currentTarget.value;
        console.log("StretchesList Changed", JSON.parse(JSON.stringify(this.stretchesList[event.currentTarget.dataset.index])));
        this.refreshStretches(false);
    }

    refreshStretches(suggestDiscount){
        this.isRequestLoading = true;
        
        getStretchesForQuote({quoteId : this.recordId, stretchesListJSON : JSON.stringify(this.stretchesList), suggestDiscount : suggestDiscount, firstOpening : suggestDiscount})
            .then(result => {
                this.assignIndexesToStretches(result);
                this.stretchesList = result;
                console.log("StretchesList", JSON.parse(JSON.stringify(this.stretchesList)));
                this.stretchesToggleChecked = result.length > 0;
                this.isRequestLoading = false;
                if(result.length > 0){
                    this.isDiscountDurationMissing = !result[0].isDiscountDurationSet;
                }
            })
            .catch(error => {
                this.displayError(error);
                this.isRequestLoading = false;
            });
    }

    displayError(error){
        console.error(error);
        if(error?.body?.message){
            this.error = error.body.message;
        }
        this.showToast(this.Labels.CPQ_ErrorOccurred, null, 'error');
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

}