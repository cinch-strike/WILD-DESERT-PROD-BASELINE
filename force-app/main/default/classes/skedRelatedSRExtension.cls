public class skedRelatedSRExtension{

public List<ServicesReceived__c> SRList {get; set;}

  public skedRelatedSRExtension(ApexPages.StandardController controller) {
    
        WD_Report__c JO = (WD_Report__c)controller.getRecord(); 
        
        SRList = [Select Date__c, RecordTypeId, Item__c, Item__r.Name, Description_of_Operations__c, Start_time__c,
         Finish_Time__c, Item_total__c, Item_Rate__c, Total_Cost__c From ServicesReceived__c Where DR__c = :JO.Id
         ORDER BY Start_time__c ASC];   
        
       }
 }