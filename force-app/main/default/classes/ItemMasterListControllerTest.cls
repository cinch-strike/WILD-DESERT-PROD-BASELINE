@IsTest
public with sharing class ItemMasterListControllerTest {
    static testmethod void testItemMasterListController() {
        List<Inventory_Item__c> imList = [select Id from Inventory_Item__c];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(imList);
        
        // Test with no selected records
        ItemMasterListController controller1 = new ItemMasterListController(stdSetController);
        System.assertEquals(0, controller1.lstSelectedIMs.size(), 'Should have no selected items');
        String finUrl = controller1.finishURL;
        System.assertNotEquals(null, finUrl, 'Finish URL should not be null');
        
        // Test with selected records
        stdSetController.setSelected(imList);
        ItemMasterListController controller2 = new ItemMasterListController(stdSetController);
        System.assertEquals(imList.size(), controller2.lstSelectedIMs.size(), 'Should have selected items');
        
        // Verify the fields are properly queried
        if (!controller2.lstSelectedIMs.isEmpty()) {
            Inventory_Item__c item = controller2.lstSelectedIMs[0];
            System.assertNotEquals(null, item.Name, 'Name should be populated');
            // Other fields might be null if not set in test data
        }
    } 

    @TestSetup
    static void dataSetup(){
        TestDataFactory testData = new TestDataFactory();
        Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        
        Account Supplier1 = new Account(Name = 'Test Supplier 1', Email__c = 'Test1@suplier.com', RecordTypeId = supplierRecordTypeId, Regions_LG_Area__c  ='Adelaide');
        Account Supplier2 = new Account(Name = 'Test Supplier 2', Email__c = 'Test2@suplier.com', RecordTypeId = supplierRecordTypeId, Regions_LG_Area__c  ='Adelaide');
        insert Supplier1;
        insert Supplier2;
        System.debug('Suppliers Created : 1st - '+Supplier1.Id +' , 2nd - '+ Supplier2.Id);
        
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
        
        Inventory_Item__c invItem1 = new Inventory_Item__c(Name = 'Test Inv Item 1', OwnerId = testUser.Id, Active__c = true);
        Inventory_Item__c invItem2 = new Inventory_Item__c(Name = 'Test Inv Item 2', OwnerId = testUser.Id, Active__c = true);
        insert invItem1;
        insert invItem2;
        System.debug('Inventory Items Created : 1st - '+invItem1.Id +' , 2nd - '+ invItem2.Id);
        
        Unit__c unit = new Unit__c(Name = 'Test Unit', First_Approver__c = testUser.Id);
        insert unit;
        Unit__c unit2 = new Unit__c(Name = 'Test Unit2', First_Approver__c = testUser.Id);
        insert unit2;
        System.debug('Unit Created : '+unit2.Id);
        
        Store_Item__c storeItem1 = new Store_Item__c(Inventory_Item__c = invItem1.Id, Store_Unit__c = unit.Id, Minimum_Quantity_for_Restocking__c = 15, Default_ReOder_Quantity__c = 15);
        Store_Item__c storeItem2 = new Store_Item__c(Inventory_Item__c = invItem2.Id, Store_Unit__c = unit2.Id, Minimum_Quantity_for_Restocking__c = 15, Default_ReOder_Quantity__c = 15);
        insert storeItem1;
        insert storeItem2;
        System.debug('Store Items Created : 1st - '+storeItem1.Id +' , 2nd - '+ storeItem2.Id);
        
        Inventory_Item__c invobj = new Inventory_Item__c(Name ='Test Item');
		insert invobj;
        
        Purchase_Request__c pr1 = new Purchase_Request__c(Status__c = 'Pick List',Item__c = invobj.id, Category__c = 'Inventory', Source_Store_Item__c = storeItem1.Id, Quantity__c = 30, Supplier__c = Supplier1.Id);
        Purchase_Request__c pr2 = new Purchase_Request__c(Status__c = 'Pick List',Item__c = invobj.id, Category__c = 'Inventory', Source_Store_Item__c = storeItem2.Id, Quantity__c = 20, Supplier__c = Supplier2.Id);
        insert pr1;
        insert pr2;
        
    }
      
}