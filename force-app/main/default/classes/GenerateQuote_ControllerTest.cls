@IsTest
public with sharing class GenerateQuote_ControllerTest {
    static testmethod void testGenerateQuoteController() {
        List<Quote__c> quoList = [select Id from Quote__c LIMIT 1];
        ApexPages.StandardController stdController = new ApexPages.StandardController(quoList[0]);
        
        Test.startTest();
        GenerateQuote_Controller gq = new GenerateQuote_Controller(stdController);
        Test.stopTest();
        
        // Verify the controller properties are set
        System.assertNotEquals(null, gq.quoteName, 'Quote name should be populated');
        System.assertNotEquals(null, gq.supplierName, 'Supplier name should be populated');
        
        // Test with additional properties - using actual values from database
        System.assertEquals('Test Supplier 1', gq.supplierName);
    } 

    @TestSetup
    static void dataSetup(){
        TestDataFactory testData = new TestDataFactory();
        Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        
        Account Supplier1 = new Account(Name = 'Test Supplier 1', Email__c = 'Test1@suplier.com', RecordTypeId = supplierRecordTypeId, Regions_LG_Area__c  ='Adelaide');
        insert Supplier1;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(LastName = 'Dhoni',
                           FirstName='MS',
                           Alias = 'msd',
                           Email = 'ms@dhoni.com.prod',
                           Username = 'ms@dhoni.com.prod',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert testUser;
        System.debug('User Created : '+testUser.Id);
        
        Quote__c quoteRec = new Quote__c(Status__c = 'Not Started',  Supplier__c = Supplier1.Id, OwnerId = testUser.Id, Quote_Item_Table__c = '');
        insert quoteRec;
        
        
    }
      
}