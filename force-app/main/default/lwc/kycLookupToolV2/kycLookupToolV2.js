import { LightningElement, api, wire, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import loadData from '@salesforce/apex/kycLookupLWCControllerV2.loadData';


export default class KycLookupToolV2 extends LightningElement {
    @api ObjectApiName = '';
    @api uniqueFieldAPIName = '';
    @api otherField = '';
    @api iDField = '';
    @api column3Field = '';
    @api column4Field = '';

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
        },
        {
            label: 'Date of Birth',
            fieldName: 'column3FieldWrapper',
            type: 'text',
            sortable: true
        },
        {
            label: 'KYC Complete?',
            fieldName: 'isKYCCompleteWrapper',
            cellAttributes : {class: { fieldName: 'format'}},
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

        loadData( { contentDocumentId : uploadedFiles[0].documentId , objAPIName : this.ObjectApiName ,
                 fieldAPIName : this.uniqueFieldAPIName , otherFieldAPIName : this.otherField , 
                 iDFieldAPIName : this.iDField , column3Field : this.column3Field , column4Field : this.column4Field } )
        .then( result => {

            this.isLoading = false;
            this.isLoadingFinished = true;
            window.console.log('result ===> '+result);
            //process resulting data in DataTableWrapper
            this.data = result;
            window.console.log('Object.keys(this.data).length: ' + Object.keys(this.data).length);
            if (Object.keys(this.data).length === 0) {
                this.isDataEmpty = true;
                this.isDataEmptyErrorMessage = 'There are no results returned. Please double check the file and re-upload if needed.';
            } else {
                this.dataNotEmpty = true;
                this.data.forEach(rec => {
                    rec.format = rec.isKYCCompleteWrapper == 'KYC Complete' ? 'slds-theme_success' : 'slds-theme_warning';
                })
                
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
    // this method validates the data and creates the csv file to download
    downloadCSVFile() {   
        this.isLoading = true;
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // getting keys from data
        this.data.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
            window.console.log('rowData ===> '+rowData);
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;
        
        csvString = csvString.replace("otherFieldUrlWrapper,", "");
        csvString = csvString.replace(",format", "");
        window.console.log('csvString = '+ csvString);

        // main for loop to get the data based on key value
        for(let i=0; i < this.data.length; i++){
            let colValue = 0;

            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    window.console.log('rowKey ===> '+ rowKey);
                    if(colValue > 0 && rowKey !== 'otherFieldUrlWrapper'){
                        csvString += ',';
                    }

                    if (rowKey === 'format') {
                        // let value = '';
                        // csvString += value;
                        colValue++;
                    }
                    else if (rowKey === 'otherFieldUrlWrapper') {
                        // let value = '';
                        // csvString += value;
                        colValue++;
                    }
                    else {
                        let value = this.data[i][rowKey] === undefined ? '' : this.data[i][rowKey];
                        window.console.log('value ===> '+ value);
                        csvString += '"'+ value +'"';
                        colValue++;
                    }
                }
            }
            
            csvString += rowEnd;
            csvString = csvString.replace("column3FieldWrapper", "Date of Birth");
            csvString = csvString.replace("isKYCCompleteWrapper", "Is KYC Complete");
            csvString = csvString.replace("objIdWrapper", "Relationship ID in FSC");
            csvString = csvString.replace("otherFieldWrapper", "Name");
            csvString = csvString.replace("uniqueFieldWrapper", "Tax Id");

        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'KYCLookupData.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
        this.isLoading = false;
    
    }
}