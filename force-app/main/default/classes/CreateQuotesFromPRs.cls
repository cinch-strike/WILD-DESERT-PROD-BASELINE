public with sharing class CreateQuotesFromPRs {
    @InvocableMethod(label='Process PRs to Create Quotes' description='Process a list of PRs to create Quotes' category='Cinch+Strike')
    public static List<InvocableOutput> createQuotes(List<InvocableInput> inputList) {
        List<InvocableOutput> outputList = new List<InvocableOutput>();
        List<Purchase_Request__c> requestList = new List<Purchase_Request__c>();
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
        // 2. Create Quotes headers
        List<Quote__c> quList = new List<Quote__c>();
        for (Id supplierId : supplierIdPRListMap.keySet()){
            Quote__c qu = new Quote__c();
            qu.Status__c = 'Not Started';
            qu.Supplier__c = supplierId;
            quList.add(qu);
        }
        if (quList.size() > 0){
            insert quList;
        }
        //3. Create a map of Supplier and Quote Ids
        quList = [select Id, Supplier__c from Quote__c where Id in :quList];
        Map<Id, Id> supplierIdQuoteIdMap = new Map<Id,Id>();
        for (Quote__c qu : quList){
            supplierIdQuoteIdMap.put(qu.Supplier__c, qu.Id);
        }
        // now create the Quote Items
        List<Quote_Item__c> quItemList = new List<Quote_Item__c>();
        List<Purchase_Request__c> prList = new List<Purchase_Request__c>();
        for (Id supplierId : supplierIdQuoteIdMap.keySet()){
            Id QUId = supplierIdQuoteIdMap.get(supplierId);

            for (Purchase_Request__c pr : requestList){
 
                if (pr.Supplier__c == supplierId){
                    Quote_Item__c quItem = new Quote_Item__c();
                    quItem.Quote__c = QUId;
                    quItem.Item__c = pr.Item__c;
                    quItem.Quantity__c = pr.Quantity__c;
                    quItem.Item_Name__c = pr.Item_Name_Formula__c;
                    quItem.Purchase_Request_No__c = pr.Id;
                    quItemList.add(quItem);
                    
                    Purchase_Request__c prItem = new Purchase_Request__c();
                    prItem.Id = pr.Id;
                    prItem.Quoted_Created__c = QUId;
                    prList.add(prItem);
                }
            }
            
        }

        //Update Purchase Request
        if (prList.size() > 0){
            update prList;
        }

        if (quItemList.size() > 0){
            insert quItemList;
        }


        InvocableOutput output = new InvocableOutput();
        output.QuotesList = quList;
        outputList.add(output);
        return outputList;
    }
	
    public class InvocableInput {
		@InvocableVariable(label='List of Purchase Requests' required=true)
		public List<Purchase_Request__c> purchaseRequestList;
    }

    public class InvocableOutput {
		@InvocableVariable(label='List of Quotes')
		public List<Quote__c> QuotesList;
    }
}