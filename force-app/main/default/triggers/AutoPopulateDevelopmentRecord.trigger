//This trigger is written to set the required Non duplicate development records for employee according to their position and unit 
trigger AutoPopulateDevelopmentRecord on Employees__c (after insert,after update) {
    Map<Id,Id> mapUnitRelatedAccountId = new Map<Id,Id>();
    Map<Id,Id> mapEmployeeRelatedPositionId = new Map<Id,Id>();
    Map<Id,List<Mandatory_Professional_Development__c>> mapAccountIdRelatedMandDevelopmentRecord = new Map<Id,List<Mandatory_Professional_Development__c>>();
    Map<Id,List<Mandatory_Professional_Development__c>> mapPositionRelatedMandDevRecord = new Map<Id,List<Mandatory_Professional_Development__c>>();
    Map<Id,List<Development_Records__c>> mapOldEmpDevRecords = new Map<Id,List<Development_Records__c>>(); 
    
    List<Mandatory_Professional_Development__c> dumpMandDevRecordIdList;
    List<Mandatory_Professional_Development__c> dumpMandDevRecIdListInPositionList;
    List<Development_Records__c> oldDevRecList;
    //Preprocessing all the related accounts and position in map as employee id as key. 
    for(Employees__c e:[select id,Assigned_to_Unit__c,Assigned_to_Unit__r.Site__c,Assigned_to_Unit__r.Name,Assigned_to_Unit__r.Site__r.Account__r.Id,PositionLookup__c from Employees__c where id in:trigger.new]){
        if(e.Assigned_to_Unit__r.Site__c<>null ){
            System.debug('----------------Else not executede'+e.Assigned_to_Unit__r.Site__c);
            mapUnitRelatedAccountId.put(e.id,e.Assigned_to_Unit__r.Site__r.Account__r.Id);
            mapEmployeeRelatedPositionId.put(e.id,e.PositionLookup__c);
        }else{
            Trigger.new[0].addError('Please assign a value to  Site of  Assigned to Unit :  '+e.Assigned_to_Unit__r.Name+'. Field can not be blank');
            System.debug('----------------Else executede');
            return;
        }
    }
    //preprocessing all the related Mandatory development records under related accounts.
    for(Account a:[select id,(select id,Professional_Development__c from  Mandatory_Professional_Developments__r)from account where id in:mapUnitRelatedAccountId.values()]){
        dumpMandDevRecordIdList = new List<Mandatory_Professional_Development__c>();
        for(Mandatory_Professional_Development__c devId:a.Mandatory_Professional_Developments__r){
            dumpMandDevRecordIdList.add(devId);    
        } 
        mapAccountIdRelatedMandDevelopmentRecord.put(a.id,dumpMandDevRecordIdList);
    }
     //preprocessing all the related Mandatory development records under related positions.
    for(Position__c p:[select id,(select id,Professional_Development__c from   Position__r) from  Position__c where id in:mapEmployeeRelatedPositionId.values()]){
        dumpMandDevRecIdListInPositionList = new List<Mandatory_Professional_Development__c>();
        for(Mandatory_Professional_Development__c devIdPos:p.Position__r){
            dumpMandDevRecIdListInPositionList.add(devIdPos);
        } 
        mapPositionRelatedMandDevRecord.put(p.id,dumpMandDevRecIdListInPositionList);       
    }
    system.debug('---------------11111111111111111111111'+mapUnitRelatedAccountId);
    system.debug('--------------22222222222222222222222'+mapEmployeeRelatedPositionId);
    system.debug('-------------333333333333333333333333'+mapAccountIdRelatedMandDevelopmentRecord );
    system.debug('---------------444444444444444444444444444'+mapPositionRelatedMandDevRecord);
    //checking if the request is for new record insert.
    if(Trigger.isInsert){
        //call to a utility class method to handle all manipulations.
        AutoPopulateDevelopmentRecordsUtility.createDevRecordOnEmployeeInsert(trigger.new,mapUnitRelatedAccountId,
        mapAccountIdRelatedMandDevelopmentRecord,mapPositionRelatedMandDevRecord);
    }
    //checking if the request is coming for position or unit update.
    if(Trigger.isUpdate){
    	 //Checking if Employee change position only
    	 set<id> lstEmployee = new set<id>();
    	//set<id> PreviousPositions = new set<id>();
    	 
    	 //all updated employees with position changed
    	 for(Employees__c emp:trigger.new)
    	 {
    	 	if(emp.positionLookup__c != trigger.oldmap.get(emp.id).positionLookup__c)
    	 	{
    	 		lstEmployee.add(emp.id);
    	 		//PreviousPositions.add(trigger.oldmap.get(emp.id).positionLookup__c);
    	 	}
    	 }
    	 
    	 list<Development_Records__c> delOldIncomplete = [select id from  Development_Records__c where status__c='Incomplete' and Employee__c in:lstEmployee];
    	 
    	 if(delOldIncomplete.size() > 0)
    	 	delete delOldIncomplete;
    	 	
    	 // get PDS belong to a Potions
    	// map<id,set<id>> mapPos_PDs = new map<id,set<id>>();
    	 /*list<Mandatory_Professional_Development__c> lstPDS = [select id,Professional_Development__c,Position__c from Mandatory_Professional_Development__c where Position__c in:PreviousPositions];
    	
    	 for(Mandatory_Professional_Development__c pd:lstPDS)
    	 {
    	 	set<id> tempPds = new set<id>();
    	 	if(mapPos_PDs.containskey(pd.Position__c))
    	 	{
    	 		tempPds = mapPos_PDs.get(pd.Position__c);
    	 	}
    	 	tempPds.add(pd.Professional_Development__c);
    	 	mapPos_PDs.put(pd.Position__c,tempPds);
    	 }

    	 list<Development_Records__c> delOldIncomplete = new list<Development_Records__c> ();
    	 
    	 // Get all DRs for a employees who changed positions  and ready for delete
    	 for(Development_Records__c dr: [select id,Professional_Development_Type__c,Employee__c from  Development_Records__c where status__c='Incomplete' and Employee__c in:lstEmployee])
    	 {
    	 	set<id> setPDs = mapPos_PDs.get(trigger.oldmap.get(dr.Employee__c).positionLookup__c);
    	 	
    	 	if(setPDs != null)
	    	 	if(setPDs.contains(dr.Professional_Development_Type__c))
	    	 	{
	    	 		delOldIncomplete.add(dr);
	    	 	}
    	 }
    	 
    	 //Delete all Incomplete DRs
    	 if(delOldIncomplete.size() > 0)
    	 	delete delOldIncomplete;*/
    	 
         //preprocessing all the old development records sitting under employees.
         for(Employees__c e:[select id,(select id,Professional_Development_Type__c from  Training_Records__r /*where Expired__c=false*/) from Employees__c where id in:trigger.old]){
             oldDevRecList = new  List<Development_Records__c>();
             for(Development_Records__c oldDevRec:e.Training_Records__r){
                 oldDevRecList.add(oldDevRec);
             } 
             mapOldEmpDevRecords.put(e.id,oldDevRecList);   
         }
         system.debug('---------------------------Map Old Emp Dev------------'+mapOldEmpDevRecords);
        //call to a utility class method to handle all manipulations.
        AutoPopulateDevelopmentRecordsUtility.updateDevRecordsUnderEmployee(trigger.oldMap,trigger.new,trigger.old,mapUnitRelatedAccountId,
        mapAccountIdRelatedMandDevelopmentRecord,mapPositionRelatedMandDevRecord,mapOldEmpDevRecords); 
               
    }
    
}