import { LightningElement,api, track, wire } from 'lwc';
import getReads from '@salesforce/apex/LecturasContadorPageController.getReads';
import { refreshApex } from '@salesforce/apex';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import ADDRESS_TYPE_FIELD from '@salesforce/schema/Direcci_n_de_entrega__c.Tipo_de_direccion_de_envio__c';
import NAVISION_ACCOUNT_ID_FIELD from '@salesforce/schema/Direcci_n_de_entrega__c.cuenta__r.Id_Navision__c';
import NAVISION_ID_FIELD from '@salesforce/schema/Direcci_n_de_entrega__c.Id_Navision__c';
import { sortBy } from 'c/utils';
const COLUMNS = [
    { label: 'Fecha', fieldName: 'Fecha__c', type: "date-local",
        typeAttributes:{
            month: "2-digit",
            day: "2-digit"
        },
        sortable: true
    },
    { label: 'Lectura', fieldName: 'Lectura__c',cellAttributes: { alignment: 'left' },sortable: true },
    { label: 'Origen', fieldName: 'Origen__c',sortable: true },
];
const NO_RECORDS_MESSAGE = 'No hay lecturas de contador asociadas a esta dirección de entrega.';
const NO_TYPE_MESSAGE ='Esta dirección de entrega no tiene un tipo asignado';
const INVALID_ADDRESS_MESSAGE = 'Este tipo de dirección de entrega no puede tener lecturas asociadas.';
const NO_EXTERNAL_ID_MESSAGE = 'Falta el siguiente id de Navision: ';
const LOADING_MESSAGE = 'Solicitando datos...';
const VALID_ADDRESS = ['BULK METERED','METERED'];
export default class MeterReadings extends LightningElement {
    @api recordId
    defaultSortDirection = 'asc';
    sortDirection = 'desc';
    sortedBy;
    @track data;
    dataWired;
    columns = COLUMNS;
    @track message = LOADING_MESSAGE;
    _isLoading = false;
    @track record;

    get isLoading() {
        return (!this.record.data && !this.record.error) || this._isLoading;
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    handleRefresh(event) {
        const self = this;
        const oldMessage = self.message;
        self.message = LOADING_MESSAGE;
        self._isLoading = true;
        refreshApex(this.record).finally(()=> {
            if (self.isValid) {
                self.callApex();
            } else {
                self.message = oldMessage;
                self._isLoading = false;
                self.data = [];
            }
        });
    }

    get isEmpty() {
        return !this.data || this.data.length === 0
    }

    @wire(getRecord, {recordId:'$recordId', fields: [NAVISION_ACCOUNT_ID_FIELD,NAVISION_ID_FIELD,ADDRESS_TYPE_FIELD]})
    wireRecord(data) {
        const self = this;
        self.record = data;
        if(data.error) {
        } 
        else if(data.data) {
            if (!self.addressType) {
                self.message = NO_TYPE_MESSAGE;
            } else if (self.addressType && VALID_ADDRESS.indexOf(self.addressType) == -1) {
                self.message = INVALID_ADDRESS_MESSAGE;
            } else if (!self.navId) {
                self.message = NO_EXTERNAL_ID_MESSAGE + 'Dirección de entrega';
            } else if (!self.accountNavId) {
                self.message = NO_EXTERNAL_ID_MESSAGE + 'Cuenta';
            }
            else {
                self.callApex();
            }
        } 
    }

    callApex() {
        this._isLoading = true;
        getReads({recordId : this.recordId}).then(result => {
            if (result.hasError) {
                this.message = result.message;
            } else {
                this.data = JSON.parse(result.data);
                if (this.isEmpty) {
                    this.message = NO_RECORDS_MESSAGE;
                } else {
                    this.onHandleSort({detail : {fieldName : 'Fecha__c',sortDirection : self.sortDirection}});
                }
            }
        }).catch(error => {
            this.message ='Ocurrió un error del lado del servidor: ' + JSON.stringify(error);
        }).finally(() => {
            this._isLoading = false;
        })
    }

    get isValid() {
        return (this.accountNavId != null && this.navId != null && this.addressType != null && VALID_ADDRESS.indexOf(this.addressType) > -1);
    }

    get accountNavId() {
        return getFieldValue(this.record.data, NAVISION_ACCOUNT_ID_FIELD);
    }

    get navId() {
        return getFieldValue(this.record.data, NAVISION_ID_FIELD);
    }

    get addressType() {
        return getFieldValue(this.record.data, ADDRESS_TYPE_FIELD);
    }
}