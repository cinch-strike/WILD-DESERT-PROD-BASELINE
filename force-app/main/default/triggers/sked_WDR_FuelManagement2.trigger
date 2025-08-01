trigger sked_WDR_FuelManagement2 on WD_Report__c (before update) {

       //System.debug('**run2 '+sked_CheckRecursive.run2Once());
    if(sked_CheckRecursive.run2Once())
    {   
        List <WD_Report__c> WDRList = trigger.new;
        
        Set<Id> joIds = new Set<Id>();
        Set<Id> unitIds = new Set<Id>();
        
        for (WD_Report__c wdr : WDRList){
           WD_Report__c oldWDR = Trigger.oldMap.get(wdr.Id);
           
           if (wdr.Fuel_delivered__c != oldWDR.Fuel_delivered__c)
            wdr.Fuel_on_hand__c = wdr.Fuel_on_hand__c + wdr.Fuel_delivered__c;
           
           if (wdr.Fuel_used__c != oldWDR.Fuel_used__c)
            wdr.Fuel_on_hand__c = wdr.Fuel_on_hand__c - wdr.Fuel_used__c;  
           
           joIds.add(wdr.Sales_Order__c);
           unitIds.add(wdr.WD_Unit__c);
        }
            
        
        //Update the Fuel Management of the JO
        List<Job_Orders__c> JOs = [Select Fuel_on_hand__c, WD_Unit__r.Fuel_on_hand__c From Job_Orders__c Where Id in :joIds];       
        Map<Id, Job_Orders__c> mapJO = new Map<Id,Job_Orders__c>(JOs);
        
        
        List<Job_Orders__c> JOUpdate = new List<Job_Orders__c>();
         for (WD_Report__c wdr : WDRList){
            Job_Orders__c joRet = mapJO.get(wdr.Sales_Order__c);
            joRet.Fuel_on_hand__c = wdr.Fuel_on_hand__c;            
            JOUpdate.add(joRet);
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
            if(unitRet  != null){    
                unitRet.Fuel_on_hand__c = wdr.Fuel_on_hand__c == null ? 0 : wdr.Fuel_on_hand__c;          
                UnitUpdate.add(unitRet);
            }
         }
         
         if (UnitUpdate.size() > 0){
             update UnitUpdate;
         }
        
        
    }
    
}