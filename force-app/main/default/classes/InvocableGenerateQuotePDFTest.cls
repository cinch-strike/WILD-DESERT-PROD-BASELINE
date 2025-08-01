@IsTest
public with sharing class InvocableGenerateQuotePDFTest {
    
    static testmethod void testInvocableGenerateQuotePDF() {
        
        List<Quote__c> quoList = [select Id from Quote__c];
        List<InvocableGenerateQuotePDF.InvocableInput> ligq = new List<InvocableGenerateQuotePDF.InvocableInput>();
        InvocableGenerateQuotePDF.InvocableInput igq = new InvocableGenerateQuotePDF.InvocableInput();
        system.debug('quoList[0].Id: ' + quoList[0].Id);
        igq.quoteId = quoList[0].Id;
        igq.fileName = 'Test Quote Invoice';
        ligq.add(igq);
        
        Test.startTest();
        List<InvocableGenerateQuotePDF.InvocableOutput> results = InvocableGenerateQuotePDF.generateQuotePDF(ligq);
        Test.stopTest();
        
        // Verify the output
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].isSuccess, 'Operation should be successful');
        System.assertEquals(null, results[0].errorMessage, 'Error message should be null on success');
        
        // Verify ContentVersion was created
        List<ContentVersion> cvList = [SELECT Id, Title FROM ContentVersion WHERE Title = 'Test Quote Invoice'];
        System.assertEquals(1, cvList.size(), 'ContentVersion should be created');
        
        // Verify ContentDocumentLink was created
        List<ContentDocumentLink> cdlList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :quoList[0].Id];
        System.assertEquals(1, cdlList.size(), 'ContentDocumentLink should be created');
    }
    
    static testmethod void testInvocableGenerateQuotePDFException() {
        List<InvocableGenerateQuotePDF.InvocableInput> ligq = new List<InvocableGenerateQuotePDF.InvocableInput>();
        InvocableGenerateQuotePDF.InvocableInput igq = new InvocableGenerateQuotePDF.InvocableInput();
        // Use invalid quote ID to trigger exception
        igq.quoteId = 'invalid_id';
        igq.fileName = 'Test Quote Invoice';
        ligq.add(igq);
        
        Test.startTest();
        List<InvocableGenerateQuotePDF.InvocableOutput> results = InvocableGenerateQuotePDF.generateQuotePDF(ligq);
        Test.stopTest();
        
        // Verify the error handling
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(false, results[0].isSuccess, 'Operation should fail');
        System.assertNotEquals(null, results[0].errorMessage, 'Error message should be populated');
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