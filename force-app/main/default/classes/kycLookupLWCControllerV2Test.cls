@isTest
public with sharing class kycLookupLWCControllerV2Test {
    @isTest
    public static void testLoadData() {

        //CREATING TEST CONTENTDOCUMENTID==============================================================================

        //Create a new file
        ContentVersion newFile = new ContentVersion();
        newFile.PathOnClient = 'TestFile.csv';
        newFile.Title = 'TestFile';
        newFile.VersionData = Blob.valueOf('Tax Id, \n' + '198329382, \n' + '198329392, \n' + '198319382, \n' + '238329382, \n');
        newFile.IsMajorVersion = true;
        insert newFile;

        //Query to get the contentDocumentId
        ContentVersion record_contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :newFile.Id LIMIT 1];
        String var_contentDocumentId = record_contentVersion.ContentDocumentId;

        System.debug('var_contentDocumentId = ' + var_contentDocumentId);

        ContentDocument record_ContentDocument = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :var_contentDocumentId LIMIT 1];
        
        //END CREATING TEST CONTENTDOCUMENTID==============================================================================

        String var_objAPIName = 'Account';
        String var_fieldAPIName = 'Tax_Id__c';
        String var_otherFieldAPIName = 'Name';
        String var_iDFieldAPIName = 'Id';
        String var_column3Field = 'Birthdate__c';
        String var_column4Field = 'Number_of_KYC_Records__c';

        List<Account> list_Acct = new List<Account>();

        Account recordAcct = new Account();
        recordAcct.Name = 'Test Acct';
        recordAcct.Tax_Id__c = '198329382';
        recordAcct.Birthdate__c = Date.newInstance(2013, 11, 2);
        list_Acct.add(recordAcct);

        Account recordAcct1 = new Account();
        recordAcct1.Name = 'Test Acct 2';
        recordAcct1.Tax_Id__c = '198319382';
        recordAcct1.Birthdate__c = Date.newInstance(2016, 12, 9);
        list_Acct.add(recordAcct1);

        insert list_Acct;

        Test.startTest();
        
        kycLookupLWCControllerV2.loadData(record_ContentDocument.Id, var_objAPIName,var_fieldAPIName, 
                                            var_otherFieldAPIName,var_iDFieldAPIName,var_column3Field,var_column4Field);  
        Test.stopTest();
    }
}