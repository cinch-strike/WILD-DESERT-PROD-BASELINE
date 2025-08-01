trigger UpdateMPDEmployeePosition on Mandatory_Professional_Development__c (after insert, after update, before delete) {

	if(trigger.isInsert)
	{
		map<id,list<Mandatory_Professional_Development__c>> map_Position_MPDs = new map<id,list<Mandatory_Professional_Development__c>>();
		map<id,set<id>> map_id_id = new map<id,set<id>>();
		list<id> idMPDs = new list<id>();
		
		// All the inserted MPD
		for(Mandatory_Professional_Development__c mpd:[select id,Position__c,Professional_Development__c, Professional_Development__r.Days_until_renewal_is_required__c from Mandatory_Professional_Development__c where id in:trigger.new]) // Get all inserted Mandatory_Professional_Development__c
		{
			if(mpd.Position__c != null)
			{
				idMPDs.add(mpd.id);
				list<Mandatory_Professional_Development__c> lstTempMPD = new list<Mandatory_Professional_Development__c>();
				set<id> tempSet = new set<id>();
				if(map_Position_MPDs.containskey(mpd.Position__c))
				{
					lstTempMPD = map_Position_MPDs.get(mpd.Position__c);
					tempSet = map_id_id.get(mpd.Position__c);
				}
				tempSet.add(mpd.Professional_Development__c);
				lstTempMPD.add(mpd);
				
				map_Position_MPDs.put(mpd.Position__c,lstTempMPD);
				map_id_id.put(mpd.Position__c,tempSet);
			}
		}
		
		//Check duplicate MPDs
		list<Mandatory_Professional_Development__c> lstMPDS = [select id, position__c,Professional_Development__c from Mandatory_Professional_Development__c where position__c in:map_id_id.keyset() and (not (id in:idMPDs))];
		
		for(Mandatory_Professional_Development__c mpd : lstMPDS)
		{
			set<id> setIDs = new set<id>();
			setIDs = map_id_id.get(mpd.position__c);
			
			if(setIds.contains(mpd.Professional_Development__c))
			{
				Trigger.new[0].addError('Please assign another value to  professional development :  field cannot be duplicated');
            	System.debug('----------------Else executede');
            	return;
			}
		}
		
		// get all employees belong to positon for new MPD
		list<Development_Records__c> tobeInsertDRS = new list<Development_Records__c>();
		if(map_Position_MPDs.size() > 0)
		{
			list<Employees__c> lstEmployees = [select id,PositionLookup__c from Employees__c where PositionLookup__c in: map_Position_MPDs.keyset()];
			
			for(Employees__c emp: lstEmployees)
			{
				for(Mandatory_Professional_Development__c mpd: map_Position_MPDs.get(emp.PositionLookup__c))
				{
					Development_Records__c dr = new Development_Records__c();
                	dr.Employee__c = emp.id;
                	dr.Professional_Development_Type__c= mpd.Professional_Development__c;
                	dr.Status__c ='Incomplete';
                	dr.Days_for_renewal_required__c = mpd.Professional_Development__r.Days_until_renewal_is_required__c;
                	tobeInsertDRS.add(dr);
				}
			}
			
		}
		
		if(tobeInsertDRS.size() > 0)
		{
			try{
		        database.insert(tobeInsertDRS);
		    }catch(DmlException dme){
		    
		    }
		}
		
	}
	
	if(trigger.isUpdate)
	{
		//For delete
		set<id> setPDS = new set<id>();
		set<id> setPositions = new set<id>();
		
		//for insert
		map<id,list<Mandatory_Professional_Development__c>> map_Position_MPDs = new map<id,list<Mandatory_Professional_Development__c>>();
		map<id,set<id>> map_id_id = new map<id,set<id>>();
		list<id> idMPDs = new list<id>();
		
		for(Mandatory_Professional_Development__c mpd: [select id,Position__c,Professional_Development__c,Professional_Development__r.Days_until_renewal_is_required__c from Mandatory_Professional_Development__c where id in:trigger.new])
		{
			if((mpd.Professional_Development__c != trigger.oldmap.get(mpd.id).Professional_Development__c) || (mpd.Position__c != trigger.oldmap.get(mpd.id).Position__c))
			{
				//For Delete
				setPositions.add(trigger.oldmap.get(mpd.id).Position__c);
				setPDS.add(trigger.oldmap.get(mpd.id).Professional_Development__c);
				
				//For Insert
				idMPDs.add(mpd.id);
				list<Mandatory_Professional_Development__c> lstTempMPD = new list<Mandatory_Professional_Development__c>();
				set<id> tempSet = new set<id>();
				if(map_Position_MPDs.containskey(mpd.Position__c))
				{
					lstTempMPD = map_Position_MPDs.get(mpd.Position__c);
					tempSet = map_id_id.get(mpd.Position__c);
				}
				tempSet.add(mpd.Professional_Development__c);
				lstTempMPD.add(mpd);
				
				map_Position_MPDs.put(mpd.Position__c,lstTempMPD);
				map_id_id.put(mpd.Position__c,tempSet);
			}
		}
		//For Insert New values
		//Check duplicate MPDs
		list<Mandatory_Professional_Development__c> lstMPDS = [select id, position__c,Professional_Development__c from Mandatory_Professional_Development__c where position__c in:map_id_id.keyset() and (not (id in:idMPDs))];
		
		for(Mandatory_Professional_Development__c mpd : lstMPDS)
		{
			set<id> setIDs = new set<id>();
			setIDs = map_id_id.get(mpd.position__c);
			
			if(setIds.contains(mpd.Professional_Development__c))
			{
				Trigger.new[0].addError('Please assign another value to  professional development :  field cannot be duplicated');
            	System.debug('----------------Else executede');
            	return;
			}
		}
		
		// get all employees belong to positon for new MPD
		list<Development_Records__c> tobeInsertDRS = new list<Development_Records__c>();
		if(map_Position_MPDs.size() > 0)
		{
			list<Employees__c> lstEmployees = [select id,PositionLookup__c from Employees__c where PositionLookup__c in: map_Position_MPDs.keyset()];
			
			for(Employees__c emp: lstEmployees)
			{
				for(Mandatory_Professional_Development__c mpd: map_Position_MPDs.get(emp.PositionLookup__c))
				{
					Development_Records__c dr = new Development_Records__c();
                	dr.Employee__c = emp.id;
                	dr.Professional_Development_Type__c= mpd.Professional_Development__c;
                	dr.Status__c ='Incomplete';
                	dr.Days_for_renewal_required__c = mpd.Professional_Development__r.Days_until_renewal_is_required__c;
                	tobeInsertDRS.add(dr);
				}
			}
			
		}
		
		if(tobeInsertDRS.size() > 0)
		{
			try{
		        database.insert(tobeInsertDRS);
		    }catch(DmlException dme){
		    
		    }
		}
		
		//Delete old values.
		map<id,Employees__c> mapId_Employees = new map<id,employees__c>([select id,PositionLookup__c from Employees__c where PositionLookup__c in: setPositions]);
		list<Development_Records__c> listDeleteDRs = [select id from Development_Records__c where Employee__c in:mapId_Employees.keyset() and Professional_Development_Type__c in:setPDS and Status__c = 'Incomplete'];
		
		if(listDeleteDRs.size() > 0)
		{
			try{
		        database.delete(listDeleteDRs);
		    }catch(DmlException dme){
		    
		    }
		}
		
		
		
	}
	
	if(trigger.isDelete)
	{
		// All the deleted MPD
		set<id> setPDS = new set<id>();
		set<id> setPositions = new set<id>();
		for(Mandatory_Professional_Development__c mpd:[select id,Position__c,Professional_Development__c from Mandatory_Professional_Development__c where id in:trigger.old]) // Get all inserted Mandatory_Professional_Development__c
		{
			if(mpd.Position__c != null)
			{
				setPositions.add(mpd.Position__c);
				setPDS.add(mpd.Professional_Development__c);
			}
		}
		
		map<id,Employees__c> mapId_Employees = new map<id,employees__c>([select id,PositionLookup__c from Employees__c where PositionLookup__c in: setPositions]);
		
		list<Development_Records__c> listDeleteDRs = [select id from Development_Records__c where Employee__c in:mapId_Employees.keyset() and Professional_Development_Type__c in:setPDS and Status__c = 'Incomplete'];
		
		if(listDeleteDRs.size() > 0)
		{
			try{
		        database.delete(listDeleteDRs);
		    }catch(DmlException dme){
		    
		    }
		}
			
	}
}