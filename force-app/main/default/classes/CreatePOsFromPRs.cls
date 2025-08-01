public with sharing class CreatePOsFromPRs {
    @InvocableMethod(label='Process PRs to Create POs' description='Process a list of PRs to create POs' category='Cinch+Strike')
    public static List<InvocableOutput> createPOs(List<InvocableInput> inputList) {
        List<InvocableOutput> outputList = new List<InvocableOutput>();
        List<Purchase_Request__c> requestList = new List<Purchase_Request__c>();
        Id AccBrandId;
        for (InvocableInput input : inputList){
            requestList.addAll(input.purchaseRequestList);
        }
        // 1. Create a map of suppliers and PR items
        Map<Id, List<Purchase_Request__c>> supplierIdPRListMap = new Map<Id, List<Purchase_Request__c>>();
        
        for (Purchase_Request__c pr : requestList){
            if (!supplierIdPRListMap.containsKey(pr.Supplier__c)){
                List<Purchase_Request__c> prList = new List<Purchase_Request__c>();
                prList.add(pr);
                supplierIdPRListMap.put(pr.Supplier__c, prList);
            }
            else {
                List<Purchase_Request__c> tempList = supplierIdPRListMap.get(pr.Supplier__c);
                tempList.add(pr);
                supplierIdPRListMap.put(pr.Supplier__c, tempList);
            }
        }
           
        // 1.5 5/31/2023 : Associate Brand Name
        InvocableInput param = inputList[0];
        if(param.AccountId!=null){
        AccBrandId = param.AccountId;
        }
 
        // 2. Create PO headers
        List<Purchase_Order__c> poList = new List<Purchase_Order__c>();
        for (Id supplierId : supplierIdPRListMap.keySet()){
            Purchase_Order__c po = new Purchase_Order__c();
            po.Status__c = 'Draft';
            po.Supplier__c = supplierId;
            po.PO_Date__c = system.today();
            po.Account_Brand__c = AccBrandId;
            poList.add(po);
        }
        if (poList.size() > 0){
            insert poList;
        }
        //3. Create a map of Supplier and PO Ids
        poList = [select Id, Supplier__c from Purchase_Order__c where Id in :poList];
        Map<Id, Id> supplierIdPOIdMap = new Map<Id,Id>();
        for (Purchase_Order__c po : poList){
            supplierIdPOIdMap.put(po.Supplier__c, po.Id);
        }
        // now create the PO Items
        List<Purchase_Order_Item__c> poItemList = new List<Purchase_Order_Item__c>();
        List<Purchase_Request__c> prList = new List<Purchase_Request__c>();
        for (Id supplierId : supplierIdPRListMap.keySet()){
            Id POId = supplierIdPOIdMap.get(supplierId);
            Map<String,ItemAttribute> itemMap = new Map<String, ItemAttribute>();
            for (Purchase_Request__c pr : supplierIdPRListMap.get(supplierId)){
                String itemIndex = (pr.Item__c != null) ? String.valueOf(pr.Item__c) : pr.Item_Name_Formula__c;
                if (!itemMap.containsKey(itemIndex)){
                    ItemAttribute attr = new ItemAttribute();
                    attr.prCount = 1;
                    attr.quantity = pr.Quantity__c;
                    attr.itemName = pr.Item_Name_Formula__c;
                    attr.itemId = pr.Item__c;
                    itemMap.put(itemIndex, attr);
                }
                else {
                    ItemAttribute temp = itemMap.get(itemIndex);
                    temp.itemName = pr.Item_Name_Formula__c;
                    temp.itemId = pr.Item__c;
                    temp.prCount = temp.prCount + 1;
                    temp.quantity = temp.quantity + pr.Quantity__c;
                    itemMap.put(itemIndex, temp);
                }
                pr.Purchase_Order__c = POId;
                prList.add(pr);
            }
            for (String itemRef : itemMap.keySet()){
                ItemAttribute attr = itemMap.get(itemRef);
                Purchase_Order_Item__c poItem = new Purchase_Order_Item__c();
                poItem.Purchase_Order__c = POId;
                poItem.Inventory_Item__c = attr.itemId;
                poItem.No_of_PR_Items__c = attr.prCount;
                poItem.No_of_Items_Still_Pending__c = attr.quantity;
                poItem.Quantity__c = attr.quantity;
                poItem.Name = attr.itemName;
                poItem.PO_Item_Status__c = 'Draft';
                poItemList.add(poItem);
            }
            
        }

        if (prList.size() > 0){
            update prList; // update to link to PO
        }
        if (poItemList.size() > 0){
            insert poItemList;
        }
        // associate the PR to the PO Item
        prList = [select Id, Purchase_Order__c, Item__c, Item_Name_Formula__c from Purchase_Request__c where Id in :prList];
        poItemList = [select Id, Name, Purchase_Order__c, Inventory_Item__c from Purchase_Order_Item__c where Id in: poItemList];
        for (Purchase_Order_Item__c poItem : poItemList){
            for (Purchase_Request__c pr : prList){
                if (poItem.Purchase_Order__c == pr.Purchase_Order__c && ((poItem.Inventory_Item__c == pr.Item__c && pr.Item__c != null) || (pr.Item__c == null && pr.Item_Name_Formula__c == poItem.Name))){
                    pr.Purchase_Order_Item__c = poItem.Id;
                }
            }
        }
        
        update prList;

        InvocableOutput output = new InvocableOutput();
        output.purchaseOrderList = poList;
        outputList.add(output);
        return outputList;
    }
	
    public class ItemAttribute {
        public Decimal prCount {get;set;}
        public String itemId {get;set;}
        public String itemName {get;set;}
        public Decimal quantity {get;set;}
        public ItemAttribute(){}
    }
    public class InvocableInput {
		@InvocableVariable(label='List of Purchase Requests' required=true)
		public List<Purchase_Request__c> purchaseRequestList;
        
        //5/31/2023 : Added new variable to accept AccountId
        @InvocableVariable(label='Account Brand associated with Purchase Requests')
        public String AccountId;
    }

    public class InvocableOutput {
		@InvocableVariable(label='List of Purchase Orders')
		public List<Purchase_Order__c> purchaseOrderList;
    }
}