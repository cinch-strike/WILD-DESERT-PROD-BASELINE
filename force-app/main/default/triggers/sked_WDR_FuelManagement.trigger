trigger sked_WDR_FuelManagement on WD_Report__c (before insert) {
       
    if(sked_CheckRecursive.runOnce())
    {   

        List <WD_Report__c> WDRList = trigger.new;
        
        Set<Id> joIds = new Set<Id>();
        Set<Id> unitIds = new Set<Id>();
        
    
            for (WD_Report__c wdr : WDRList){
               wdr.Fuel_on_hand__c = wdr.Fuel_on_hand__c + wdr.Fuel_delivered__c;
               wdr.Fuel_on_hand__c = wdr.Fuel_on_hand__c - wdr.Fuel_used__c;        
               joIds.add(wdr.Job_Order__c);
               unitIds.add(wdr.WD_Unit__c);
            }
                
            //if (WDRList.size() > 0){
            //  update WDRList;
            //}
        
        
        //Update the Fuel Management of the JO
        List<Job_Orders__c> JOs = [Select Fuel_on_hand__c, WD_Unit__r.Fuel_on_hand__c From Job_Orders__c Where Id in :joIds];       
        Map<Id, Job_Orders__c> mapJO = new Map<Id,Job_Orders__c>(JOs);
        
        
        List<Job_Orders__c> JOUpdate = new List<Job_Orders__c>();
         for (WD_Report__c wdr : WDRList){
            Job_Orders__c joRet = mapJO.get(wdr.Sales_Order__c);
            if (joRet != null){
            joRet.Fuel_on_hand__c = wdr.Fuel_on_hand__c;            
            JOUpdate.add(joRet);}
         }
         
         if (JOUpdate.size() > 0){
             update JOUpdate;
         }
         
         //Update the Fuel Management of the WD Unit
        List<Unit__c> Units = [Select Fuel_on_hand__c From Unit__c Where Id in :unitIds];       
        Map<Id, Unit__c> mapUnit = new Map<Id,Unit__c>(Units);
        
        
        List<Unit__c> UnitUpdate = new List<Unit__c>();
         for (WD_Report__c wdr : WDRList){
            Unit__c unitRet = mapUnit.get(wdr.WD_Unit__c);
            if (unitRet != null){
                unitRet.Fuel_on_hand__c = wdr.Fuel_on_hand__c;          
                UnitUpdate.add(unitRet);
            }
         }
         
         if (UnitUpdate.size() > 0){
             update UnitUpdate;
         }
        
        
    }
    
}