@IsTest
public with sharing class PRCreationScreenControllerTest {
    static testmethod void testPRScreenController() {
        PRCreationScreenController.getFullItemMasterList('Test');
        PRCreationScreenController.getValidUnits();
        Inventory_Item__c itemMaster = [select Id from Inventory_Item__c limit 1];
        Unit__c unit = [select Id from Unit__c limit 1];
        PRCreationScreenController.checkItemData(itemMaster.Id, unit.Id);
        PRCreationScreenController.createPurchaseOrder(itemMaster.Id, null, true, false, unit.Id, 1, 'Test Staff', null, null, 'Operations','','',8.50, null);
        PRCreationScreenController.getDepartmentplist();
        //PRCreationScreenController.getSubDepartmentplist();
        List<Purchase_Request__c> draftPRList = PRCreationScreenController.fetchDraftPRs();
        PRCreationScreenController.submitForApproval(draftPRList);
        PRCreationScreenController.updatePRs(draftPRList);
        PRCreationScreenController.delPR(draftPRList[0]);
        PRCreationScreenController.setWorkOrderAssetId(null);
        List<ContentDocument> uploadedFiles = [select Id, CreatedById from ContentDocument limit 1];
        Purchase_Request__c selectedPR = [select Id from Purchase_Request__c limit 1];
        //String prRecordId = draftPRList[0].id;
        List<String> selectedDocument = new List<String>();
        selectedDocument.add(uploadedFiles[0].Id);
        PRCreationScreenController.linkUploadedFiles(selectedPR.Id, selectedDocument);
    }
    @TestSetup
    static void dataSetup(){
        Inventory_Item__c invItem1 = new Inventory_Item__c(Name = 'Test Inv Item 1', Active__c = true);
        Inventory_Item__c invItem2 = new Inventory_Item__c(Name = 'NON-INVENTORY ITEM', Active__c = true);
        
        insert invItem1;
        insert invItem2;
        Store_Item__c storeItem =new Store_Item__c(Inventory_Item__c = invItem2.Id);
        insert storeItem;
        List<Store_Item__c> inventoryItemList = [select Id from Store_Item__c where Inventory_Item__r.Name = 'NON-INVENTORY ITEM'];
        
        Id unitRTypeId = Schema.SObjectType.Unit__c.getRecordTypeInfosByDeveloperName().get('Location').getRecordTypeId();  
        //Unit__c unit = new Unit__c(Name = 'Test Unit', Status__c = 'Active', First_Approver__c = UserInfo.getUserId(), RecordTypeId = unitRTypeId);  01 DEC 2022: Code for new Cost Price
        Unit__c unit = new Unit__c(Name = 'Test Unit', Status__c = 'Active', Purchase_Request_Approver__c = UserInfo.getUserId(), RecordTypeId = unitRTypeId); //01 DEC 2022: Remove code for new Cost Price
        insert unit;

        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;

        Purchase_Request__c createPR = new Purchase_Request__c(
            New_Item_Name__c = 'Test Item',
            Quantity__c = 2,
            Source_Store_Item__c = storeItem.Id);
        insert createPR;
        
    }
}