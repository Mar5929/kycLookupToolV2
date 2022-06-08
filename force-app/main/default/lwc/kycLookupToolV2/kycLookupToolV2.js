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
            fieldName: 'otherFieldUrlWrapper',
            type: 'url',
            typeAttributes: {label: { fieldName: 'otherFieldWrapper'}, 
            target: '_blank'},
            sortable: true
        },
        {
            label: 'Tax Id',
            fieldName: 'uniqueFieldWrapper',
            type: 'text',
            sortable: true
        }

    ];

    error;
    isLoading = false;
    isLoadingFinished = false;
    isDataEmpty = false;
    isDataEmptyErrorMessage = '';
    dataNotEmpty = false;
    //@track columns = columns;
    @track data;
  
    

    get acceptedFormats() {
        return ['.csv'];
    }

    uploadFileHandler( event ) {
        
        this.isLoading = true;
        this.isDataEmpty = false;
        this.dataNotEmpty = false;
        const uploadedFiles = event.detail.files;

        loadData( { contentDocumentId : uploadedFiles[0].documentId , objAPIName : this.ObjectApiName , fieldAPIName : this.uniqueFieldAPIName , otherFieldAPIName : this.otherField , iDFieldAPIName : this.iDField} )
        .then( result => {

            this.isLoading = false;
            this.isLoadingFinished = true;
            window.console.log('result ===> '+result);
            
            this.data = result;
            window.console.log('Object.keys(this.data).length: ' + Object.keys(this.data).length);
            if (Object.keys(this.data).length === 0) {
                this.isDataEmpty = true;
                this.isDataEmptyErrorMessage = 'There are no results returned. Please double check the file and re-upload if needed.';
            } else {
                this.dataNotEmpty = true;
            }
            this.dispatchEvent(
                new ShowToastEvent( {
                    title: 'Success',
                    message: '',
                    variant: 'success'
                } ),
            );
            window.console.log('isDataEmpty = '+ this.isDataEmpty);
            window.console.log('dataNotEmpty = '+ this.dataNotEmpty);
            

        })
        .catch( error => {

            this.isLoading = false;
            this.isLoadingFinished = true;
            this.isDataEmpty = true;
            this.isDataEmptyErrorMessage = 'Something went wrong. Please contact your salesforce admin for help.';
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