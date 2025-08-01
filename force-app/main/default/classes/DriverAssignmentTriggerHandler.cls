/****
 * Apex Class for Driver Assignment Tigger Handler; 
 * Author: D Banez
 * Date: Sept 2020 
 * Test Class: DriverAssignmentTriggerHandlerTest
*/
public with sharing class DriverAssignmentTriggerHandler {
	public static TriggerAutomations__c automationEnabled  = TriggerAutomations__c.getInstance(); 
	public static Boolean daEnabled = automationEnabled.Driver_Assignment__c;
    
	public static void mainEntry(Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate,Boolean isDelete, Boolean isUnDelete, 
                    List<SObject> newList, List<SObject> oldList, Map<ID, SObject> newmap, Map<ID, SObject> oldmap)
    {
    	// In a test context always set this to true        
        if (Test.isrunningTest())  {
            daEnabled = true;
        }
        // Perform business logic
        if(daEnabled){
        	try{
            	// INSERT TRIGGER
                if(isInsert){
                    // Before
                    if(isBefore){

                    }            
                    // After
                    if(isAfter){

                    }
                }
                // Update TRIGGER
                if(isUpdate){
                    // Before
                    if(isBefore){
                    	updateStartEndTime(newList);
                    }            
                    // After
                    if(isAfter){
                   		
                    }
                }
                // Delete TRIGGER
                if(isDelete){
                    // Before
                    if(isBefore){

                    }            
                    // After
                    if(isAfter){
						//processTransportJobsAndPreStarts((Map<Id, Driver_Assignment__c>) oldMap);
                    }
                }
                // UNDELETE Trigger
                if(isUnDelete){}  
            } catch (Exception ex){
                newList[0].addError(ex.getStackTraceString()+'--'+ ex.getTypeName()+'--'+ ex.getMessage());
            }
        }
    }
    
    //Using this method to format time on text
    public static void updateStartEndTime(List<Driver_Assignment__c> newList){
        for(Driver_Assignment__c da: newList) {
            if(da.Start_Date_Time__c != null){
                da.Start_Time__c = da.Start_Date_Time__c.format('hh:mm a');
            } else {
                da.Start_Time__c = '';
            }

            if(da.End_Date_Time__c != null){
            	da.End_Time__c = da.End_Date_Time__c.format('hh:mm a');
            } else {
                da.End_Time__c = '';
            }
                
        }
        
    }
    
    //deletion of related daily pre-starts
    /*public static void processTransportJobsAndPreStarts(Map<Id, Driver_Assignment__c> oldMap){
        List<Daily_Pre_Start__c> preStartsToDelete = new List<Daily_Pre_Start__c>();
        List<Driver_Assignment__c> daList = [select Id, Transport_Job__c,
                                             (select Id from Daily_Pre_Starts__r) from Driver_Assignment__c where Id in :oldMap.keySet()];
        Set<Id> transportJobIdSet = new Set<Id>();
        for (Driver_Assignment__c da : daList){
            if (da.Daily_Pre_Starts__r.size() > 0){
                preStartsToDelete.addAll(da.Daily_Pre_Starts__r);
            }
            transportJobIdSet.add(da.Transport_Job__c);
        }

        List<Transport_Job__c> parentJobList = [select Id, Status__c, (select Id, Driver_Status__c from Driver_Assignments__r)
            from Transport_Job__c where Id in : transportJobIdSet];
        List<Transport_Job__c> jobsToUpdateList = new List<Transport_Job__c>();
        for (Transport_Job__c job : parentJobList){
            Integer draftCount = 0;
            Integer assignedCount = 0;
            Integer inProgressCount = 0;
            Integer completedCount = 0;
            Integer totalCount = job.Driver_Assignments__r.size();
            for (Driver_Assignment__c da : job.Driver_Assignments__r){
                draftCount += (da.Driver_Status__c == 'Draft') ? 1 : 0;
                assignedCount += (da.Driver_Status__c == 'Assigned') ? 1 : 0;
                inProgressCount += (da.Driver_Status__c == 'In Progress') ? 1 : 0;
                completedCount += (da.Driver_Status__c == 'Completed') ? 1 : 0;
            }
            if (draftCount == totalCount){ // all  Remaining is Draft
                job.Status__c = 'Draft'; // reset to Draft
            } 
            else if (assignedCount == totalCount){
                job.Status__c = 'Assigned';  // set to assigned
            }
            else if (inProgressCount == totalCount){
                job.Status__c = 'In Progress';  // set to In progress
            }
            else if (completedCount == totalCount){
                job.Status__c = 'Completed';  // set to Completed
            }
            jobsToUpdateList.add(job); 
        }

        if (preStartsToDelete.size() > 0){
            try {
                delete preStartsToDelete;
            }
            catch (DmlException e){
                System.debug('There is an error deleting Driver Assignments: ' + e.getMessage());
            }
        }

        if (jobsToUpdateList.size() > 0){
            try {
                //delete jobsToUpdateList;
                update jobsToUpdateList;
            }
            catch (DmlException e){
                //System.debug('There is an error deleting Driver Assignments: ' + e.getMessage());
                System.debug('There is an error updating Transport job: ' + e.getMessage());
            }
        }
    }*/
}