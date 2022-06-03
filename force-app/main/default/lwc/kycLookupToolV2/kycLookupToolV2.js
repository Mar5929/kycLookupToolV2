import { LightningElement, api, wire, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import loadData from '@salesforce/apex/kycLookupLWCControllerV2.loadData';


export default class KycLookupToolV2 extends LightningElement {
    @api ObjectApiName = '';
    @api uniqueFieldAPIName = '';
    @api otherField = '';
    @api iDField = '';

    @track columns = [
        {
            label: 'Name',
            fieldName: 'otherFieldURL',
            type: 'url',
            typeAttributes: {label: { fieldName: 'otherField'}, 
            target: '_blank'},
            sortable: true
        },
        {
            label: 'Tax Id',
            fieldName: 'uniqueField',
            type: 'text',
            sortable: true
        }

    ];

    error;
    isLoaded = false;
    //@track columns = columns;
    @track data;
  
    

    get acceptedFormats() {
        return ['.csv'];
    }

    uploadFileHandler( event ) {
        
        this.isLoaded = true;
        const uploadedFiles = event.detail.files;

        loadData( { contentDocumentId : uploadedFiles[0].documentId , objAPIName : this.ObjectApiName , fieldAPIName : this.uniqueFieldAPIName , otherFieldAPIName : this.otherField , iDFieldAPIName : this.iDField} )
        .then( result => {

            this.isLoaded = false;
            window.console.log('result ===> '+result);
            this.data = result;
            this.dispatchEvent(
                new ShowToastEvent( {
                    title: 'Success',
                    message: '',
                    variant: 'success'
                } ),
            );

        })
        .catch( error => {

            this.isLoaded = false;
            this.error = error;
            window.console.log('error ===> '+error);

            this.dispatchEvent(
                new ShowToastEvent( {
                    title: 'Error!!',
                    message: JSON.stringify( error ),
                    variant: 'error'
                } ),
            );     

        } ) 

    }
}