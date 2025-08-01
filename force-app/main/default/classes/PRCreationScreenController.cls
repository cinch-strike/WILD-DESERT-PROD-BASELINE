public with sharing class PRCreationScreenController {
    public PRCreationScreenController() {}
     

    @AuraEnabled
    public static List<sObject> getFullItemMasterList(String value) {

        /*
        String query = 'Select Id, Store_Item_Code__c, Supplier_Part_Number__c, Name FROM Inventory_Item__c WHERE Active__c = TRUE AND Non_Searchable_Item__c = FALSE ';
        query += 'AND (Name LIKE \'%' + String.escapeSingleQuotes(value) + '%\' OR Store_Item_Code__c LIKE \'%' + String.escapeSingleQuotes(value) + '%\'';
        query += ' OR Supplier_Part_Number__c LIKE \'%' + String.escapeSingleQuotes(value) + '%\') WITH SECURITY_ENFORCED';
        List<SObject> returnList = Database.Query(query);
        return returnList;*/
        
        List<Inventory_Item__c> inventoryItemsToBeReturned = new List<Inventory_Item__c>();
        List<sObject> sObjectsList = new List<sObject>();
        
        //BUILD SOSL STRING AND PERFORM SOSL ON INVENTORY ITEM OBJECT
        String soslQuery = 'FIND \'' + String.escapeSingleQuotes(value) + '\' IN ALL FIELDS RETURNING Inventory_Item__c (Id, Name, Store_Item_Code__c, Supplier_Part_Number__c, Active__c, Cost_Price__c, Cost_Price_formula__c, Non_Searchable_Item__c,PR_Price_Override__c WHERE Active__c = TRUE AND Non_Searchable_Item__c = FALSE)';
        sObjectsList = Search.query(soslQuery).get(0);
                                                 
        return sObjectsList;
    }

    @AuraEnabled
    public static List<Unit__c> getValidUnits(){
        List<Unit__c> returnedUnitList = new List<Unit__c>();
        String UserId = UserInfo.getUserId();
        /* 20 April 2023: Using the Unit Assignment Object
        List<User> returnedUserInfo = [select Id, Name FROM User WHERE Id =: UserId and Limit_to_Units_I_am_PR_Approver__c = TRUE WITH SECURITY_ENFORCED];
        List<Unit__c> assignedUnitList = [select Id, Name FROM Unit__c WHERE Unit_Manager__c =: UserId and Purchase_Request_Approver__c != '' WITH SECURITY_ENFORCED];
        if(returnedUserInfo.isEmpty()){    
            if(assignedUnitList.isEmpty()){
                returnedUnitList = [Select Id, Name FROM Unit__c WHERE RecordType.Name = 'Location' and Status__c = 'Active' and Destination_Unit__c = true and Purchase_Request_Approver__c != '' WITH SECURITY_ENFORCED ORDER BY Name ];
            }
            else{
                returnedUnitList = assignedUnitList;
            }   
        }
        else{
            returnedUnitList = [Select Id, Name FROM Unit__c WHERE Purchase_Request_Approver__c =: UserId and RecordType.Name = 'Location' and Status__c = 'Active' and Destination_Unit__c = true WITH SECURITY_ENFORCED ORDER BY Name ];
        }*/
        List<Unit_Assignment__c> assignmentList  = [SELECT Id, User__c, Unit__c FROM Unit_Assignment__c WHERE Active__c = TRUE AND User__c = : UserId];
        system.debug('## assignmentList: ' + assignmentList);
        Set<Id> unitIdSet = new Set<Id>();
        for (Unit_Assignment__c ua : assignmentList){
            unitIdSet.add(ua.Unit__c);
        }
        returnedUnitList = [select Id, Name FROM Unit__c WHERE Id IN :unitIdSet WITH SECURITY_ENFORCED];
        system.debug('## returnedUnitList: ' + returnedUnitList);

        return returnedUnitList;
    }

    @AuraEnabled
    public static List<String> getDepartmentplist(){
        List<String> picklistDepartment = new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Purchase_Request__c').getDescribe().fields.getMap().get('Department__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistDepartment.add(pickListVal.getLabel());
        }     
        return picklistDepartment;
    }

    /*@AuraEnabled
    public static Map<Object,List<String>> getSubDepartmentplist()
    {
        Schema.DescribeFieldResult depend = Schema.getGlobalDescribe().get('Purchase_Request__c').getDescribe().fields.getMap().get('Sub_Department__c').getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
        (   control.getType() == Schema.DisplayType.Boolean
        ?   null
        :   control.getPicklistValues()
        );
    
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                (   controlEntries == null
                ?   (Object) (index == 1)
                :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (   controlValue == null
                    ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                    ) continue;
                if ( !dependentPicklistValues.containsKey( controlValue ) )
                {
                    dependentPicklistValues.put( controlValue, new List<String>() );
                }
                dependentPicklistValues.get( controlValue ).add( entry.getLabel() );
            }
        }
        return dependentPicklistValues;
    }
    */

    @AuraEnabled
    public static ItemWrapper checkItemData(Id itemMasterId, Id destinationUnitId){
        ItemWrapper item = new ItemWrapper();
        List<Store_Item__c> inventoryItemList = [select Id, Inventory_Item__c, Store_Unit__r.Name, Store_Unit__c, Stock_Available_formula__c,
                                                Base_Store__c, Base_Store__r.Name from Store_Item__c 
                                                where Inventory_Item__c = :itemMasterId 
                                                AND Store_Unit__c = :destinationUnitId
                                                WITH SECURITY_ENFORCED];
        if (inventoryItemList.size() > 0){
            item.inventoryItem = inventoryItemList[0];
        }
        else {
            item.inventoryItem = null;
        }
        // check if there is any open PR's for same Item
        List<Purchase_Request__c> openPRList = [select Id from Purchase_Request__c where Item__c = :itemMasterId 
                                                and Destination_Store__c = :destinationUnitId AND Status__c != 'Completed' WITH SECURITY_ENFORCED];
        item.hasOpenPRsForSameItem = (openPRList.size() > 0);
        return item;
    }

    @AuraEnabled
    public static Purchase_Request__c createPurchaseOrder(String itemMasterId, String newItemName, Boolean nonInventoryItem, Boolean newItem, Id destinationUnitId, Decimal quantity, String staffName, Id assetId, Id workOrderId, String department, String notes, String detailsforsupplier, Decimal prCostPrice, Id costAllocationId){
    
        Purchase_Request__c pr = new Purchase_Request__c();
        pr.Status__c = 'Draft';
        pr.Quantity__c = quantity;
        pr.PR_Cost_Price_GST_exc__c = prCostPrice;  //01 DEC 2022: Code for new Cost Price
        pr.Staff_Name__c = staffName;
        pr.Asset__c = assetId;
        pr.Work_Order__c = workOrderId;
        pr.Cost_Allocation_Unit__c = costAllocationId;
        pr.New_Item_Name__c = newItemName;
        pr.Item__c = (newItem) ? null : itemMasterId;
        pr.Destination_Store__c = destinationUnitId;
        pr.Department__c = department;
        pr.Notes__c = notes;
        pr.Details_for_Supplier__c = detailsforsupplier;
        List<Store_Item__c> inventoryItemList = new List<Store_Item__c>();
        if (nonInventoryItem){
            inventoryItemList = [select Id from Store_Item__c where Inventory_Item__r.Name = 'NON-INVENTORY ITEM' WITH SECURITY_ENFORCED limit 1];
            pr.Source_Store_Item__c = (inventoryItemList.size() > 0) ? inventoryItemList[0].Id : null;
            pr.Creation_Type__c = 'Non-Inventory Item';
        }
        else if (!newItem){
            inventoryItemList = [select Id, Base_Store__c, Store_Unit__c, Stock_Available_formula__c from Store_Item__c where Store_Unit__c = :destinationUnitId and Inventory_Item__c = :itemMasterId WITH SECURITY_ENFORCED limit 1];
            if (inventoryItemList.size() > 0){
                if (quantity <= inventoryItemList[0].Stock_Available_formula__c){ // take from existing
                    pr.Source_Store_Item__c = inventoryItemList[0].Id;
                    pr.Source_Store__c = inventoryItemList[0].Store_Unit__c;
                    pr.Creation_Type__c = 'Inventory Item - Taken from Local Unit';
                }
                else { // if more than the available stocks
                    List<Store_Item__c> baseStoreItemList = [select Id from Store_Item__c where Store_Unit__c = :inventoryItemList[0].Base_Store__c and Inventory_Item__c = :itemMasterId WITH SECURITY_ENFORCED limit 1];
                    pr.Source_Store_Item__c = (baseStoreItemList.size() > 0) ? baseStoreItemList[0].Id : null;
                    pr.Source_Store__c = (baseStoreItemList.size() > 0) ? baseStoreItemList[0].Base_Store__c : null;
                    pr.Creation_Type__c = 'Inventory Item - Ordered from Base Store';
                }
            }
        }
        else { // new item
            inventoryItemList = [select Id from Store_Item__c where Inventory_Item__r.Name = 'ASSORTED ITEMS' WITH SECURITY_ENFORCED limit 1];
            pr.Source_Store_Item__c = (inventoryItemList.size() > 0) ? inventoryItemList[0].Id : null;
            pr.Creation_Type__c = 'New Item';
        }

        try {
            insert pr;
            
            pr = [select Id, Status__c,Quantity__c,Name,Item__c,Item_Name_Formula__c, Item__r.Name,New_Item_Name__c, PR_Cost_Price_GST_exc__c, Total_Cost_Price_GST_exc__c from Purchase_Request__c where Id = :pr.Id LIMIT 1];
        }
        catch (DmlException e){
            system.debug('## Error: ' + e.getMessage());
            pr = new Purchase_Request__c();
        }
        return pr;
    }
    
    @AuraEnabled
    public static void submitForApproval(List<Purchase_Request__c> prsToSubmit){
        List<Purchase_Request__c> prListToUpdate = new List<Purchase_Request__c>();
        for (Purchase_Request__c eachPR : prsToSubmit){
                Purchase_Request__c tempPr = new Purchase_Request__c();
                tempPr.id = eachPr.id;
                tempPr.Status__c=Label.PR_Submitted;
                //tempPr.Status__c = 'For Approval';
                prListToUpdate.add(tempPr);
                
        }
        if(prListToUpdate.size()>0)
            update prListToUpdate;
    }

    @AuraEnabled
    public static void linkUploadedFiles(String createdPR, List<String> uploadedFiles){
        List<ContentDocumentLink> listContentDocLink = new List<ContentDocumentLink>();
        for(String eachCD : uploadedFiles){
            ContentDocumentLink tempCDLink = new ContentDocumentLink();
            tempCDLink.ContentDocumentId = eachCD;
            tempCDLink.LinkedEntityId = createdPR;
            tempCDLink.ShareType = 'I';
            tempCDLink.Visibility = 'AllUsers';
            listContentDocLink.add(tempCDLink);
        }

        insert listContentDocLink;
    }

    @AuraEnabled
    public static List<Purchase_Request__c> fetchDraftPRs(){
        //UPDATED BY JOAL - INCLUDED FIELDS WHEN QUERYING
        List<Purchase_Request__c> prList = [SELECT Id, Name, Item_Name_Formula__c, Source_Store__r.Name, Destination_Store__r.Name, Status__c, Quantity__c, 
                         Item__r.Name, New_Item_Name__c, Item__c, Cost_Price_GST_exc__c, PR_Cost_Price_GST_exc__c, Total_Cost_Price_GST_exc__c 
                    FROM Purchase_Request__c 
                    WHERE CreatedById = :UserInfo.getUserId()
                    AND Status__c = 'Draft'
                    ];
        return prList;
    }

    @AuraEnabled
    public static void delPR(Purchase_Request__c purchaseRequestRec){
        delete purchaseRequestRec;
    }

    @AuraEnabled
    public static void updatePRs(List<Purchase_Request__c> prList){
        update prList;
    }

    @AuraEnabled
    public static Job_Cards__c setWorkOrderAssetId(Id woId){
        List<Job_Cards__c> woList = [select Id, WD_Asset__c from Job_Cards__c where Id = : woId WITH SECURITY_ENFORCED LIMIT 1]; 
        if (woList.size() > 0){
            return woList[0];
        }
        else {
            return null;
        }
    }

    
    public class ItemWrapper{
        @AuraEnabled
        public Store_Item__c inventoryItem;
        @AuraEnabled
        public Boolean hasOpenPRsForSameItem;
        
        public ItemWrapper() {
            this.hasOpenPRsForSameItem = false;
            this.inventoryItem = new Store_Item__c();
        }
    }
    

}