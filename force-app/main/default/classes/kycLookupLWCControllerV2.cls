public with sharing class kycLookupLWCControllerV2 {
    
    @AuraEnabled
    public static List<DataTableWrapper> loadData( Id contentDocumentId, String objAPIName, String  fieldAPIName, String otherFieldAPIName, String iDFieldAPIName, String column3Field, String column4Field) {

        String strMessage;
        List < Sobject > objectQueryList = new List < Sobject >();
        List < String > objectStringList = new List < String >();
        List<DataTableWrapper> wrapperResponse = new List<DataTableWrapper>();
        String query;
        
        String objUniqueField;
        String objUniqueFieldCleaned;
        String isKYCComplete;

        if ( contentDocumentId != null ) {
            
            ContentVersion contentVersionObj = [ SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId ];
            List < String > records = contentVersionObj.VersionData.toString().split( '\n' );
            //Removing the Header
            records.remove( 0 );

            //iterate over csv rows and adding row value to string list
            for ( String record : records ) {

                if ( record != null && String.isNotBlank(record) ) {
                    System.debug('In String record : records Loop');

                    List < String > row = record.split( ',' );
                    //System.debug('Row Value = ' + row);

                    objUniqueField = row[ 0 ];
                    objUniqueFieldCleaned = objUniqueField.replace('\r', '');
                    
                    objectStringList.add( objUniqueFieldCleaned );
                    System.debug('objectStringList' + objectStringList);

                }

            }
            
            Database.DeleteResult deleteResult = Database.delete( contentDocumentId, true );

            try {    

                if ( objectStringList.size() > 0 ) {

                    
                    query = 'SELECT '+ iDFieldAPIName + ', ' + otherFieldAPIName + ', ' + fieldAPIName + ', ' + column3Field + ', ' + column4Field
                            + ' FROM ' + objAPIName + ' WHERE ' + fieldAPIName + ' != \'\' AND ' + fieldAPIName + ' IN :objectStringList';
                    System.debug('Built Query = ' + query);
                    //Find object records
                    objectQueryList = Database.query(query);
                    System.debug('objectQueryList = ' + objectQueryList);

                    for(sObject objRecord : objectQueryList){
                        DataTableWrapper obj = new DataTableWrapper();
                        Id varObjId = obj.objIdWrapper;
                        String varObjName = obj.otherFieldWrapper;
                        String varObjUnique = obj.uniqueFieldWrapper;
                        String varURL = obj.otherFieldUrlWrapper;
                        String varcolumn3 = obj.column3FieldWrapper;
                        String varcolumn4 = '';
                        String varKYCcomplete = obj.isKYCCompleteWrapper;

                        varObjId = (Id)objRecord.get(iDFieldAPIName);
                        varObjName = (String)objRecord.get(otherFieldAPIName);
                        varURL = '/'+(Id)objRecord.get(iDFieldAPIName);
                        varObjUnique = (String)objRecord.get(fieldAPIName);
                        varcolumn3 = String.valueOf((Date)objRecord.get(column3Field));
                        varcolumn4 =  String.valueOf((Decimal)objRecord.get(column4Field));
                        if (varcolumn4 == '1') {
                            varKYCcomplete = 'KYC Complete';
                        }else {
                            varKYCcomplete = 'KYC Incomplete';
                        }

                        obj.objIdWrapper = varObjId;
                        System.debug('obj.objId = ' + obj.objIdWrapper);
                        obj.otherFieldWrapper = varObjName;
                        obj.uniqueFieldWrapper = varObjUnique;
                        obj.otherFieldUrlWrapper = varURL;
                        obj.column3FieldWrapper = varcolumn3;
                        obj.isKYCCompleteWrapper = varKYCcomplete;

                        wrapperResponse.add(obj);
                    }
                    


                    //strMessage = 'Querying ' +objAPIName;

                }

            }
            catch ( Exception e ) {

                strMessage = 'Some error occured. Please reach out to your System Admin';
                system.debug( e.getMessage() );
                Database.DeleteResult deleteResult = Database.delete( contentDocumentId, true );
                
            }

        } else {
            Database.DeleteResult deleteResult = Database.delete( contentDocumentId, true );

        }
        
        //returns the DataTableWrapper object with data for datatable and hyperlink in the name field
        return wrapperResponse;

    }

    private class DataTableWrapper {
        @AuraEnabled
        public Id objIdWrapper {get;set;}
        @AuraEnabled
        public String otherFieldWrapper {get;set;}
        @AuraEnabled
        public String otherFieldUrlWrapper {get;set;}
        @AuraEnabled
        public String uniqueFieldWrapper {get;set;}
        @AuraEnabled
        public String column3FieldWrapper {get;set;}
        @AuraEnabled
        public String isKYCCompleteWrapper {get;set;}
    }

}