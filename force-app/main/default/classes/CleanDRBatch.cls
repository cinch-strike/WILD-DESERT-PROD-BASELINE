global class CleanDRBatch implements Database.Batchable<SObject>, database.stateful {
	string query = 'Select id,Status__c, Professional_Development_Type__c, Employee__c, Employee__r.PositionLookup__c From Development_Records__c where status__c = \'Incomplete\' and employee__r.Status__c = \'Active\'';
	list<id> delIds;
	Map<id,Position__c> map_id_Position;
	global CleanDRBatch()
	{
	 	delIds = new list<id>();
	 	map_id_Position = new map<id,Position__c>([Select Name, Id, (Select Id, Name, Professional_Development__c From Position__r) From Position__c]);
	}
	
	global Database.Querylocator start(database.batchableContext BC)
	{
		return database.getQueryLocator(query);
	}
	
	global void execute(database.batchableContext BC, list<Development_Records__c> scope)
	{
		set<id> posIDs = new set<id>();
		
		for(Development_Records__c Drs: scope)
		{
			if(Drs.employee__r.PositionLookup__c == null)
				delIds.add(Drs.id);
			
			Position__c p = map_id_Position.get(Drs.employee__r.PositionLookup__c );
			
			if(p == null)
			{
				delIds.add(Drs.id);
				continue;
			}
			boolean found = false;
			for(Mandatory_Professional_Development__c mpd: p.Position__r)
			{
				if(mpd.Professional_Development__c == drs.Professional_Development_Type__c)	
				{
					found = true;
					break;
				}
			}
			
			if(!found)
			{
				delIds.add(Drs.id);
			}
		}
		
		
		
		//Query Posiion
		 
		
	}
	
	global void finish(database.batchableContext BC)
	{
		if(delIds.size() == 0)
			return;
		
		list<Development_Records__c> lstDevRecs = [Select id From Development_Records__c where id in:delIds];
		
		delete lstDevRecs;
	}

}