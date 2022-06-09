@isTest
public with sharing class kycLookupLWCControllerV2Test {
    @isTest
    public static void testLoadData() {

        //Create a new file
        ContentVersion newFile = new ContentVersion();
        newFile.PathOnClient = 'TestFile';
        newFile.Title = 'TestFile';
        newFile.VersionData = Blob.valueOf('Tax Id, 198329382, 193882928,123456789');
        newFile.IsMajorVersion = true;
        insert newFile;

        //Query the contentDocumentId
        ContentVersion insertedFile = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :newFile.Id LIMIT 1];

        Test.startTest();
        Test.stopTest();
    }
}