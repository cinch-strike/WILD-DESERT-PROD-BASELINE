public with sharing class PurchaseRequestListController {

    /**This is the list which will be passed to Visualforce Page and in turn passed to Flow from Visualforce**/
    public List <Purchase_Request__c> lstSelectedPRs {get;set;}
    public String finishURL {
        get{
            return Label.CreatePOFinishURL;
        }
        set;
    }
    public PurchaseRequestListController(ApexPages.StandardSetController listcontroller) {
      
        Set <Id> prSelectedIdSet = new Set <Id>();
        lstSelectedPRs = new List <Purchase_Request__c >();
            
        for (Purchase_Request__c pr : (List<Purchase_Request__c>) listcontroller.getSelected()) {
            prSelectedIdSet.add(pr.Id);
        }
        
        /**Querying on the Selected records and fetching fields which are required in Flow **/
        // 5/31/2023 : Added additional fields for querying
        this.lstSelectedPRs = [select Id, Item__c, Item_Name_Formula__c, PO_Creation_Checker__c , Part_Number__c,  Quantity__c, Item_Master_Cost_Category__c, PR_Cost_Price_GST_exc__c, Total_Cost_Price_GST_exc__c, Details_for_Supplier__c,
            Supplier__c, Destination_Store__c  from Purchase_Request__c 
            where Id in: prSelectedIdSet order by Supplier__c, Item__c asc];
        system.debug(lstSelectedPRs);
    }
    
}