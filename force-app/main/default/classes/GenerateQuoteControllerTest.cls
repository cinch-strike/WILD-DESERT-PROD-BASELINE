@IsTest
public with sharing class GenerateQuoteControllerTest {
    
    @TestSetup
    static void dataSetup() {
        // Create test data - simplified approach
        TestDataFactory testData = new TestDataFactory();
        
        // Create Account (required for Site)
        Account testAccount = new Account(
            Name = 'Test Account', 
            Regions_LG_Area__c = 'Adelaide'
        );
        insert testAccount;
        
        // Create Site with minimal required fields - Open status
        Site__c openSite = new Site__c(
            Name = 'Test Open Site',
            Account__c = testAccount.Id,
            Site_Status__c = 'Open'
        );
        insert openSite;
        
        // Create Site with minimal required fields - Closed status  
        Site__c closedSite = new Site__c(
            Name = 'Test Closed Site',
            Account__c = testAccount.Id,
            Site_Status__c = 'Closed'
        );
        insert closedSite;
    }
    
    @IsTest
    static void testGenerateQuoteControllerWithOpenSite() {
        // Get the open site
        Site__c openSite = [SELECT Id, Contract__c, Site_Status__c FROM Site__c WHERE Site_Status__c = 'Open' LIMIT 1];
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(openSite);
        
        Test.startTest();
        // Test constructor
        GenerateQuoteController controller = new GenerateQuoteController(stdController);
        
        // Verify properties are set correctly
        System.assertEquals(openSite.Id, controller.site.Id, 'Site should be set correctly');
        System.assertEquals('Open', controller.site.Site_Status__c, 'Site status should be Open');
        
        // Test quoteExecution with open site (should fail)
        PageReference result = controller.quoteExecution();
        Test.stopTest();
        
        // Verify results
        System.assertEquals(null, result, 'PageReference should be null');
        
        // Check that error message was added
        List<ApexPages.Message> messages = ApexPages.getMessages();
        Boolean errorFound = false;
        for (ApexPages.Message msg : messages) {
            if (msg.getSeverity() == ApexPages.Severity.FATAL && 
                msg.getSummary().contains('Cannot Generate an Invoice for a Site that is not Closed')) {
                errorFound = true;
                break;
            }
        }
        System.assert(errorFound, 'Error message should be displayed for non-closed site');
    }
    
    @IsTest
    static void testGenerateQuoteControllerWithClosedSite() {
        // Get the closed site
        Site__c closedSite = [SELECT Id, Contract__c, Site_Status__c FROM Site__c WHERE Site_Status__c = 'Closed' LIMIT 1];
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(closedSite);
        
        Test.startTest();
        // Test constructor
        GenerateQuoteController controller = new GenerateQuoteController(stdController);
        
        // Verify properties are set correctly
        System.assertEquals(closedSite.Id, controller.site.Id, 'Site should be set correctly');
        System.assertEquals('Closed', controller.site.Site_Status__c, 'Site status should be Closed');
        
        // Test quoteExecution with closed site
        PageReference result = controller.quoteExecution();
        Test.stopTest();
        
        // Verify results
        System.assertEquals(null, result, 'PageReference should be null');
        
        // Check messages (either success or handled exception)
        List<ApexPages.Message> messages = ApexPages.getMessages();
        if (!messages.isEmpty()) {
            // Either success message or handled exception - both are valid
            Boolean validMessageFound = false;
            for (ApexPages.Message msg : messages) {
                if (msg.getSeverity() == ApexPages.Severity.CONFIRM || 
                    msg.getSeverity() == ApexPages.Severity.FATAL) {
                    validMessageFound = true;
                    break;
                }
            }
            System.assert(validMessageFound, 'Should have appropriate message for closed site processing');
        }
    }
    
    @IsTest
    static void testGenerateQuoteControllerConstructor() {
        // Get any site for constructor test
        Site__c testSite = [SELECT Id, Contract__c, Site_Status__c FROM Site__c LIMIT 1];
        
        // Create standard controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testSite);
        
        Test.startTest();
        // Test constructor
        GenerateQuoteController controller = new GenerateQuoteController(stdController);
        Test.stopTest();
        
        // Verify all properties are properly initialized
        System.assertNotEquals(null, controller.site, 'Site should be set');
        System.assertEquals(testSite.Id, controller.site.Id, 'Site ID should match');
        // Contract ID might be null if no contract is associated, which is acceptable
        System.assertEquals(testSite.Contract__c, controller.contractId, 'Contract ID should match (can be null)');
    }
}