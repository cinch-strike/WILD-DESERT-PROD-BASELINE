public class WDSRWrapper{
         public ServicesReceived__c SR {get; set;}
         public string RecordTypeName {
                 get{
                     return getRecordTypeName(SR.RecordTypeId);
                 }
        }
         public string ItemName {get{
                Services_Received__c item = skedWDServicesReceive.getSRItem(SR.Item__c);  
                return  item.Name;
         }}     
        
    
          //Helper method
        public string getRecordTypeName(String recordTypeId) {
        try {    
                return ServicesReceived__c.SObjectType
                       .getDescribe()
                       .getRecordTypeInfosById()
                       .get(recordTypeId)
                       .getName();
            } catch(Exception e) {
                return null;
            }
        }
        
     }