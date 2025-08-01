public with sharing class ItemMasterListController {
    /**This is the list which will be passed to Visualforce Page and in turn passed to Flow from Visualforce**/
    public List <Inventory_Item__c> lstSelectedIMs {get;set;}
    public String finishURL {
        get{
            return Label.CreatePOFinishURL;
        }
        set;
    }
    public ItemMasterListController(ApexPages.StandardSetController listcontroller) {
      
        Set <Id> prSelectedIdSet = new Set <Id>();
        lstSelectedIMs = new List <Inventory_Item__c >();
            
        for (Inventory_Item__c pr : (List<Inventory_Item__c>) listcontroller.getSelected()) {
            prSelectedIdSet.add(pr.Id);
        }
        
        /**Querying on the Selected records and fetching fields which are required in Flow **/
        this.lstSelectedIMs = [select Id, Name, Supplier_Part_Number__c, Cost_Category__c, Cost_Price__c from Inventory_Item__c 
            where Id in: prSelectedIdSet order by Name asc];
    }
}