trigger SiteTrigger on Site__c (before update, after insert, after update, before delete) {
    
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            SiteTrigger_Handler.preventSiteStatusClose(Trigger.new, Trigger.oldMap);
        }

        if(Trigger.isDelete){
            SiteTrigger_Handler.preventSiteDelete(Trigger.oldMap); 
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert && !SiteTrigger_Handler.SiteTriggerHandlerRecursion){
            SiteTrigger_Handler.preventActiveSite(Trigger.new);
        }
        
        if(Trigger.isUpdate && !SiteTrigger_Handler.SiteTriggerHandlerRecursion){
            SiteTrigger_Handler.preventActiveSite(Trigger.new);
        }
    }


    
    
}