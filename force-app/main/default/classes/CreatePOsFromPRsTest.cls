@isTest
public class CreatePOsFromPRsTest {

    @isTest
    public static void POsFromPRsTest(){
        TestDataFactory testData = new TestDataFactory();
        Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        
        Account Supplier1 = new Account(Name = 'Test Supplier 1', Email__c = 'Test1@suplier.com', RecordTypeId = supplierRecordTypeId, Regions_LG_Area__c = 'Asia');
        Account Supplier2 = new Account(Name = 'Test Supplier 2', Email__c = 'Test2@suplier.com', RecordTypeId = supplierRecordTypeId, Regions_LG_Area__c = 'Asia');
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
        
        Unit__c unit = new Unit__c(Name = 'Test Unit');
        insert unit;
        Unit__c unit2 = new Unit__c(Name = 'Test Unit2');
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
        List<Purchase_Request__c> purchaseReqList = new List<Purchase_Request__c>();
        purchaseReqList.add(pr1);
        purchaseReqList.add(pr2);
        System.debug('Purchase requisitions Created : 1st - ' + pr1 + ' , 2nd - '+ pr2);
        
        List<CreatePOsFromPRs.InvocableInput> InvInputobjList = new List<CreatePOsFromPRs.InvocableInput>();
        
        CreatePOsFromPRs.InvocableInput obj = new CreatePOsFromPRs.InvocableInput();
        system.debug('!!'+purchaseReqList);
        obj.purchaseRequestList = new List<Purchase_Request__c>();
        obj.purchaseRequestList.addAll(purchaseReqList);
        System.debug('Invocable Object : '+ obj);
        System.debug('PR List Invocable : '+ obj.purchaseRequestList);
        
        InvInputobjList.add(obj);
        System.debug('Invocable Input List : '+ InvInputobjList);
        CreatePOsFromPRs.createPOs(InvInputobjList); 
        

        List<CreatePOsFromPRs.InvocableOutput> InvOutput = CreatePOsFromPRs.createPOs(InvInputobjList);
        System.debug('!!!!' + InvOutput);
        List<Purchase_Order__c> poList = new List<Purchase_Order__c>();
        for(CreatePOsFromPRs.InvocableOutput obj1 : InvOutput){
            System.debug('in loop : ' +obj1);
            poList = obj1.purchaseOrderList;
        }
        System.debug('PO Lists : ' + poList);
		List<Purchase_Order_Item__c> poListTest = [SELECT Purchase_Order__r.Supplier__c ,Inventory_Item__c , No_of_PR_Items__c, No_of_Items_Still_Pending__c, Quantity__c,Name from Purchase_Order_Item__c WHERE Purchase_Order__c in :poList];
        for(Purchase_Order_Item__c poItems : poListTest){
            if(poItems.Purchase_Order__r.Supplier__c == Supplier1.Id){
                System.assertEquals(pr1.Quantity__c, poItems.Quantity__c, 'Quantity Mismatch for PO of Supplier 1');
                System.assertEquals(1, poItems.No_of_PR_Items__c, 'No of PRs mismatch for PO of Supplier 1');
                System.assertEquals(pr1.Quantity__c, poItems.No_of_Items_Still_Pending__c,'No of pending items mismatch for PO of Supplier 1');
            }
            else if(poItems.Purchase_Order__r.Supplier__c == Supplier2.Id){
                System.assertEquals(pr2.Quantity__c, poItems.Quantity__c, 'Quantity Mismatch for PO of Supplier 2');
                System.assertEquals(1, poItems.No_of_PR_Items__c, 'No of PRs mismatch for PO of Supplier 2');
                System.assertEquals(pr2.Quantity__c, poItems.No_of_Items_Still_Pending__c,'No of pending items mismatch for PO of Supplier 2');
            }
        }
    }

    @IsTest
    public static void noSNumberItem(){
        TestDataFactory testData = new TestDataFactory();
        Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        
        Account Supplier1 = new Account(Name = 'Test Supplier 1', Email__c = 'Test1@suplier.com', RecordTypeId = supplierRecordTypeId, Regions_LG_Area__c = 'Asia');
        Account Supplier2 = new Account(Name = 'Test Supplier 2', Email__c = 'Test2@suplier.com', RecordTypeId = supplierRecordTypeId, Regions_LG_Area__c = 'Asia');
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
        
        Unit__c unit = new Unit__c(Name = 'Test Unit');
        insert unit;
        Unit__c unit2 = new Unit__c(Name = 'Test Unit2');
        insert unit2;
        System.debug('Unit Created : '+unit2.Id);

        Inventory_Item__c invItem1 = new Inventory_Item__c(Name = 'Test Inv Item 1', OwnerId = testUser.Id, Active__c = true);
        Inventory_Item__c invItem2 = new Inventory_Item__c(Name = 'Test Inv Item 2', OwnerId = testUser.Id, Active__c = true);
        insert invItem1;
        insert invItem2;

        Store_Item__c storeItem1 = new Store_Item__c(Inventory_Item__c = invItem1.Id, Store_Unit__c = unit.Id, Minimum_Quantity_for_Restocking__c = 15, Default_ReOder_Quantity__c = 15);
        Store_Item__c storeItem2 = new Store_Item__c(Inventory_Item__c = invItem2.Id, Store_Unit__c = unit2.Id, Minimum_Quantity_for_Restocking__c = 15, Default_ReOder_Quantity__c = 15);
        insert storeItem1;
        insert storeItem2;
        System.debug('Store Items Created : 1st - '+storeItem1.Id +' , 2nd - '+ storeItem2.Id);

        
        Purchase_Request__c pr1 = new Purchase_Request__c(Status__c = 'Pick List', New_Item_Name__c = 'same item', Source_Store_Item__c = storeItem1.Id, Category__c = 'Inventory', Quantity__c = 30, Supplier__c = Supplier1.Id);
        Purchase_Request__c pr2 = new Purchase_Request__c(Status__c = 'Pick List', New_Item_Name__c = 'same item', Source_Store_Item__c = storeItem2.Id, Category__c = 'Inventory', Quantity__c = 20, Supplier__c = Supplier2.Id);
        insert pr1;
        insert pr2;
        List<Purchase_Request__c> purchaseReqList = new List<Purchase_Request__c>();
        purchaseReqList.add(pr1);
        purchaseReqList.add(pr2);
        System.debug('Purchase requisitions Created : 1st - ' + pr1 + ' , 2nd - '+ pr2);
        
        List<CreatePOsFromPRs.InvocableInput> InvInputobjList = new List<CreatePOsFromPRs.InvocableInput>();
        
        CreatePOsFromPRs.InvocableInput obj = new CreatePOsFromPRs.InvocableInput();
        system.debug('!!'+purchaseReqList);
        obj.purchaseRequestList = new List<Purchase_Request__c>();
        obj.purchaseRequestList.addAll(purchaseReqList);
        System.debug('Invocable Object : '+ obj);
        System.debug('PR List Invocable : '+ obj.purchaseRequestList);
        
        InvInputobjList.add(obj);
        System.debug('Invocable Input List : '+ InvInputobjList);
        CreatePOsFromPRs.createPOs(InvInputobjList); 
        

        List<CreatePOsFromPRs.InvocableOutput> InvOutput = CreatePOsFromPRs.createPOs(InvInputobjList);
        System.debug('!!!!' + InvOutput);
        List<Purchase_Order__c> poList = new List<Purchase_Order__c>();
        for(CreatePOsFromPRs.InvocableOutput obj1 : InvOutput){
            System.debug('in loop : ' +obj1);
            poList = obj1.purchaseOrderList;
        }
        System.debug('PO Lists : ' + poList);
		List<Purchase_Order_Item__c> poListTest = [SELECT Purchase_Order__r.Supplier__c ,Inventory_Item__c , No_of_PR_Items__c, No_of_Items_Still_Pending__c, Quantity__c,Name from Purchase_Order_Item__c WHERE Purchase_Order__c in :poList];
        for(Purchase_Order_Item__c poItems : poListTest){
            if(poItems.Purchase_Order__r.Supplier__c == Supplier1.Id){
                System.assertEquals(pr1.Quantity__c, poItems.Quantity__c, 'Quantity Mismatch for PO of Supplier 1');
                System.assertEquals(1, poItems.No_of_PR_Items__c, 'No of PRs mismatch for PO of Supplier 1');
                System.assertEquals(pr1.Quantity__c, poItems.No_of_Items_Still_Pending__c,'No of pending items mismatch for PO of Supplier 1');
            }
            else if(poItems.Purchase_Order__r.Supplier__c == Supplier2.Id){
                System.assertEquals(pr2.Quantity__c, poItems.Quantity__c, 'Quantity Mismatch for PO of Supplier 2');
                System.assertEquals(1, poItems.No_of_PR_Items__c, 'No of PRs mismatch for PO of Supplier 2');
                System.assertEquals(pr2.Quantity__c, poItems.No_of_Items_Still_Pending__c,'No of pending items mismatch for PO of Supplier 2');
            }
        }
    }
}