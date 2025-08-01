//This trigger is written to handle the development records manipulations after expiry.
trigger cloneExpiredDevRecords on Development_Records__c (after update) {
   
    Map<Id,Id> devIdAndPosId = new Map<Id,Id>();
    Map<Id,Id> devIdAndAccId = new Map<Id,Id>();
    Map<Id,Set<String>> posIdAndUniquePd = new Map<Id,Set<String>>();
    Set<string> dumpPdSet;
    
    Map<Id,Set<String>> accIdAndUniquePd = new Map<Id,Set<String>>();
    //Preprocessing all the related position and accounts on related development records.
    for(Development_Records__c dr:[select id,Employee__r.PositionLookup__c,Employee__r.Assigned_to_Unit__r.Site__r.Account__r.Id from Development_Records__c where Expired__c=true and id in:trigger.new]){
        devIdAndPosId.put(dr.Id,dr.Employee__r.PositionLookup__c);     
        devIdAndAccId.put(dr.Id,dr.Employee__r.Assigned_to_Unit__r.Site__r.Account__r.Id);
    }
    system.debug('---------------------------------Position Id---------------'+devIdAndPosId);
    system.debug('---------------------------------Unit Account Id---------------'+devIdAndAccId);
    
    //Preprocessing all the required development records for all related position.
    for(Position__c  p:[select id,(select id,Professional_Development__c from Position__r) from Position__c where id in:devIdAndPosId.values()]){
        dumpPdSet = new Set<string>();
        for(Mandatory_Professional_Development__c dc:p.Position__r){
        	if(dc.Professional_Development__c != null) //check null if this do not have professional development
            	dumpPdSet.add(dc.Professional_Development__c);
        }
        posIdAndUniquePd.put(p.Id,dumpPdSet);
    }
    //Preprocessing all the reruired development records for all related accounts.
    for(Account a:[select id,(select id,Professional_Development__c from Mandatory_Professional_Developments__r)from account where id in:devIdAndAccId.values()]){
         dumpPdSet = new Set<string>(); 
         for(Mandatory_Professional_Development__c dd:a.Mandatory_Professional_Developments__r){
         	if (dd.Professional_Development__c != null)
             	dumpPdSet.add(dd.Professional_Development__c);    
         }
         accIdAndUniquePd.put(a.Id,dumpPdSet);   
    }
    
    system.debug('---------------------------------Position PD Type SET---------------'+posIdAndUniquePd);
    system.debug('---------------------------------Position PD Type SET---------------'+accIdAndUniquePd);
    
    List<Development_Records__c> toBeClonedDevRecordsAfterExpiry = new List<Development_Records__c>();
    List<Id> toBeStatusUpdate = new List<Id>();
    for(Development_Records__c exDev:trigger.new){
        //checking for development record expiry.
        if((exDev.Expired__c ==true)&& (exDev.Expired__c != trigger.oldMap.get(exDev.Id).Expired__c )){
            Integer flag =0;
                 if(posIdAndUniquePd.size()>0){
                 	if(devIdAndPosId.containskey(exDev.Id))
                 	{
                 		 id devidpos = devIdAndPosId.get(exDev.Id);
                 		 if(devidpos != null)
                 		 {
                 		 	 if(posIdAndUniquePd.get(devidpos) != null)
		                     for(Id pdId:posIdAndUniquePd.get(devIdAndPosId.get(exDev.Id))){
		                         if(exDev.Professional_Development_Type__c ==pdId){
		                             flag++;
		                         }    
		                     }
                 		 }
                 	}
                 }
                 if(accIdAndUniquePd.size()>0){
                 	if(devIdAndAccId.containskey(exDev.Id))
                 	{
                 	  id devidacc = devIdAndAccId.get(exDev.Id);
                 	  if(devidacc != null)
                 	  {
                 	  	  if(accIdAndUniquePd.get(devidacc) != null)
	                      for(Id pdId:accIdAndUniquePd.get(devIdAndAccId.get(exDev.Id))){
	                        if(exDev.Professional_Development_Type__c ==pdId){
	                            flag++;
	                        }    
	                     }
                 	  }
                 	}
                 }
                 
                 
            
            
            if(flag>0){
                system.debug('---------------------------------Expiry triggered to initiate clone logic------------------------------------------------'+flag);
                //exDev.Status__c ='Expired';
                toBeStatusUpdate.add(exDev.Id);
                Development_Records__c d = new  Development_Records__c();
               
                d.Employee__c = exDev.Employee__c;
                d.Professional_Development_Type__c= exDev.Professional_Development_Type__c;
                d.Status__c ='Incomplete';
                d.Days_for_renewal_required__c = exDev.Professional_Development_Type__r.Days_until_renewal_is_required__c;
                d.Required_By_Unit__c = exDev.Professional_Development_Type__r.Required_By_Unit__c;
                
                toBeClonedDevRecordsAfterExpiry.add(d); 
            }       
        }    
    }
    List<Development_Records__c> toUpdateDevRecords = new List<Development_Records__c>();
    for(Development_Records__c dd:[select id,Status__c from Development_Records__c where id in:toBeStatusUpdate]){
        dd.Status__c = 'Expired';
        toUpdateDevRecords.add(dd);
    }
    try{
        database.update(toUpdateDevRecords);
    }catch(DmlException dme){
    
    }
    
    try{
        system.debug(LoggingLevel.DEBUG, '---------------------------------Inserting---------------------------------'+toBeClonedDevRecordsAfterExpiry);
        database.insert(toBeClonedDevRecordsAfterExpiry);
    }catch(DmlException dme){
        system.debug(LoggingLevel.DEBUG, '---------------------------------Exception in Inserting---------------------------------'+dme.getStackTraceString());
    }
    
    

}