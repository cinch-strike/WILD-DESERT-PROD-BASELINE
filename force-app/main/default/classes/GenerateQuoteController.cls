public class GenerateQuoteController {
    //Apex properties or variables
    public Id contractId {get; set;}
    public Id siteId { get; set; }
    public site__c site{get;set;}
    //constructor to get the Case record
    public GenerateQuoteController(ApexPages.StandardController controller) {
    site__c sites =  (site__c) controller.getRecord();
    Id siteId = sites.Id;
    site=[select id,Contract__c,Site_Status__c  from site__c where id=:siteId limit 1];
    contractId=site.Contract__c; 
    }
public PageReference quoteExecution() {
     
    if(this.site.Site_Status__c!='Closed'){
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Cannot Generate an Invoice for a Site that is not Closed.'));
      
    }
    else{
        try{
        GenerateInvoice.generateInvoiceRecord(contractId, siteId);
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'You have successfully generated an Invoice.'));
        } catch(exception ex){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
      
        }
    }
    return null; 
    }    

   
}