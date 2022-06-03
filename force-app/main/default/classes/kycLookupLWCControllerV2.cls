public with sharing class kycLookupLWCControllerV2 {
    
    @AuraEnabled
    public static List<DataTableWrapper> loadData( Id contentDocumentId ) {

        String strMessage;
        List < Account > accountsQueryList = new List < Account >();
        List < String > accountStringList = new List < String >();
        List<DataTableWrapper> wrapperResponse = new List<DataTableWrapper>();
        
        String accountTaxId;
        String accountTaxIdCleaned;

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

                    accountTaxId = row[ 0 ];
                    accountTaxIdCleaned = accountTaxId.replace('\r', '');
                    
                    accountStringList.add( accountTaxIdCleaned );

                }

            }

            try {    

                if ( accountStringList.size() > 0 ) {

                    Database.DeleteResult deleteResult = Database.delete( contentDocumentId, true );
                    //Find accounts
                    accountsQueryList = [SELECT Id, Name, Tax_Id__c FROM Account WHERE Tax_Id__c IN :accountStringList];
                    System.debug('accountsQueryList = ' + accountsQueryList);
                    for(Account acctRecord : accountsQueryList){
                        DataTableWrapper obj = new DataTableWrapper();
                        obj.acctId = acctRecord.Id;
                        obj.name = acctRecord.Name;
                        obj.nameUrl = '/'+acctRecord.Id;
                        obj.taxId = acctRecord.Tax_Id__c;
                        wrapperResponse.add(obj);
                    }


                    strMessage = 'Querying Accounts';

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
        public Id acctId {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String nameUrl {get;set;}
        @AuraEnabled
        public String taxId {get;set;}
    }

}