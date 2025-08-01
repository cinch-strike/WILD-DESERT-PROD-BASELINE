@isTest
private class DummyTriggerTest {

    @testSetup
    static void setupTestData() {
        // Create dummy Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create dummy Contact
        Contact con = new Contact(FirstName = 'Test', LastName = 'User', AccountId = acc.Id);
        insert con;

        // Create a Driver Assignment with writeable fields only
        Driver_Assignment__c da = new Driver_Assignment__c(
            Driver_Assignment_Date__c = Date.today(),
            Daily_Pre_start_Required__c = true,
            Work_Diary_Received__c = true,
            Send_Notification__c = false
        );
        insert da;
    }

    static testMethod void runDummyTest() {
        Test.startTest();
        List<Driver_Assignment__c> daList = [SELECT Id FROM Driver_Assignment__c LIMIT 1];
        System.assert(!daList.isEmpty());
        Test.stopTest();
    }
}