public with sharing class kycLookupLWCControllerV2 {
    
    @AuraEnabled
    public static List<DataTableWrapper> loadData( Id contentDocumentId, String objAPIName, String  fieldAPIName, String otherFieldAPIName, String iDFieldAPIName) {

        String strMessage;
        List < Sobject > objectQueryList = new List < Sobject >();
        List < String > objectStringList = new List < String >();
        List<DataTableWrapper> wrapperResponse = new List<DataTableWrapper>();
        String query;
        
        String objUniqueField;
        String objUniqueFieldCleaned;

        if ( contentDocumentId != null ) {
            
            ContentVersion contentVersionObj = [ SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId ];
            List < String > records = contentVersionObj.VersionData.toString().split( '\n' );
            //Removing the Header
            records.remove( 0 );

            //iterate over csv rows and adding row value to string list
            for ( String record : records ) {

                if ( record != null ) {


                    List < String > row = record.split( ',' );
                    //System.debug('Row Value = ' + row);

                    objUniqueField = row[ 0 ];
                    objUniqueFieldCleaned = objUniqueField.replace('\r', '');
                    
                    objectStringList.add( objUniqueFieldCleaned );

                }

            }

            try {    

                if ( objectStringList.size() > 0 ) {

                    Database.DeleteResult deleteResult = Database.delete( contentDocumentId, true );
                    query = 'SELECT '+ iDFieldAPIName + ', ' + otherFieldAPIName + ', ' + fieldAPIName + ' FROM ' + objAPIName + ' WHERE ' + fieldAPIName + ' IN :objectStringList';
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

                        varObjId = (Id)objRecord.get(iDFieldAPIName);
                        varObjName = (String)objRecord.get(otherFieldAPIName);
                        varURL = '/'+(Id)objRecord.get(iDFieldAPIName);
                        varObjUnique = (String)objRecord.get(fieldAPIName);

                        obj.objIdWrapper = varObjId;
                        System.debug('obj.objId = ' + obj.objIdWrapper);
                        obj.otherFieldWrapper = varObjName;
                        obj.uniqueFieldWrapper = varObjUnique;
                        obj.otherFieldUrlWrapper = varURL;

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
        //test
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
    }

}
