public with sharing class kycLookupLWCControllerV2 {
    
    @AuraEnabled
    public static List<DataTableWrapper> loadData( Id contentDocumentId, String objAPIName, String  fieldAPIName) {

        String strMessage;
        List < objAPIName > objectQueryList = new List < objAPIName >();
        List < String > objectStringList = new List < String >();
        List<DataTableWrapper> wrapperResponse = new List<DataTableWrapper>();
        
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
                    System.debug('Row Value = ' + row);

                    objUniqueField = row[ 0 ];
                    objUniqueFieldCleaned = objUniqueField.replace('\r', '');
                    
                    objectStringList.add( objUniqueFieldCleaned );

                }

            }

            try {    

                if ( objectStringList.size() > 0 ) {

                    Database.DeleteResult deleteResult = Database.delete( contentDocumentId, true );
                    //Find object records
                    objectQueryList = [SELECT Id, Name, fieldAPIName FROM objAPIName WHERE fieldAPIName IN :objectStringList];
                    System.debug('objectQueryList = ' + objectQueryList);
                    for(objAPIName objRecord : objectQueryList){
                        DataTableWrapper obj = new DataTableWrapper();
                        obj.objId = objRecord.Id;
                        obj.name = objRecord.Name;
                        obj.nameUrl = '/'+objRecord.Id;
                        obj.uniqueField = objRecord.fieldAPIName;
                        wrapperResponse.add(obj);
                    }


                    strMessage = 'Querying ' +objAPIName;

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

        //return strMessage;
        return wrapperResponse;

    }

    private class DataTableWrapper {
        @AuraEnabled
        public Id objId {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String nameUrl {get;set;}
        @AuraEnabled
        public String uniqueField {get;set;}
    }

}