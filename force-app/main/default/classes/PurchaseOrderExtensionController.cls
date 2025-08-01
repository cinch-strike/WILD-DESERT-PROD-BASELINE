public with sharing class PurchaseOrderExtensionController {

    private biz3__Purchase_Order__c currentPO;
    private List<biz3__PO_Item__c> currentPOItems;
    private ApexPages.StandardController stdController;
    
    // Constructor
    public PurchaseOrderExtensionController(ApexPages.StandardController controller) {
        currentPO = (biz3__Purchase_Order__c)controller.getRecord();
        this.stdController = controller;
        this.currentPO = [SELECT Id, Name, biz3__Account__c, biz3__Contact__c FROM biz3__Purchase_Order__c WHERE id =: currentPO.Id ];
        
      
    }
    
    // Property
    public List<biz3__PO_Item__c> POItems {
        get { 
                  If   (currentPOItems == null) {                              
                        List <biz3__PO_Item__c> tempPOItems = new List <biz3__PO_Item__c>();
                        currentPOItems = [SELECT Id, 
                                                                                        Name, 
                                                                                        biz3__Item__c, 
                                                                                        biz3__Item__r.Name,
                                                                                        biz3__Line_Description__c, 
                                                                                        WD_Asset__c,
                                                                                        Non_Asset_Location__c,
                                                                                        Recharge__c,
                                                                                        Requested_by__c,
                                                                                        biz3__Order_Name__c, 
                                                                                        biz3__Quantity__c, 
                                                                                        biz3__Display_Name__c
                                                                FROM biz3__PO_Item__c
                                                WHERE biz3__PO_Item__c.biz3__Master__c = :currentPO.Id ];
                  }                                       
                       
                 
                return currentPOItems;
        }
        set;  
    }
    
    // Action method for saving
    public PageReference saveAllAndExit()
    {
        saveAll();
        PageReference result=ApexPages.currentPage();
        result.setRedirect(true);
        if ( ApexPages.getMessages().size() == 0 ){
            return new ApexPages.StandardController(currentPO).view();
        }
        return null;
    }
    
    public PageReference saveAll()
    {
         try{
             update currentPOItems;          
             
             if ( !Test.isRunningTest() )
                 stdController.reset();
         }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
         }          
         return null;
    }
    
    
}