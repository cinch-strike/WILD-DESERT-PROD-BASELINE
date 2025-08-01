/****
 * Apex Class for Daily Site Job Trigger Handler; 
 * Author: Whiteshed, D Banez
 * Date: Jan 2019 
 * Test Class: DailySiteJobTriggerHandlerTest
*/
public with sharing class DailySiteJobTriggerHandler {
	public static TriggerAutomations__c automationEnabled  = TriggerAutomations__c.getInstance(); 
	public static Boolean dsjEnabled = automationEnabled.DailySiteJob__c;
	public static Boolean DailyReportTriggerRecursion = false;
    
	public static void mainEntry(Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate,Boolean isDelete, Boolean isUnDelete, 
                    List<SObject> newList, List<SObject> oldList, Map<ID, SObject> newmap, Map<ID, SObject> oldmap)
    {
    	// In a test context always set this to true        
        if (Test.isrunningTest())  {
            dsjEnabled = true;
        }
        // Perform business logic
        if(dsjEnabled){
        	try{
            	// INSERT TRIGGER
                if(isInsert){
                    // Before
                    if(isBefore){
                    	preventDuplicateReport(newList);
            			preventOpenReport(newList);
                    }            
                    // After
                    if(isAfter){
                        if(!DailyReportTriggerRecursion){
                            updateLTI(newList);
                        }
                    }
                }
                // Update TRIGGER
                if(isUpdate){
                    // Before
                    if(isBefore){
                    	
                    }            
                    // After
                    if(isAfter){
                   		
                    }
                }
                // Delete TRIGGER
                if(isDelete){
                    // Before
                    if(isBefore){
                        preventDeletionOfSubmittedReport (oldList);
                    }            
                    // After
                    if(isAfter){
                    	deleteParentDSJSIfStandAlone(oldList);
                    }
                }
                // UNDELETE Trigger
                if(isUnDelete){}  
            } catch (Exception ex){
            	//String errorString = ex.getStackTraceString()+'--'+ ex.getTypeName()+'--'+ ex.getMessage();
                newList[0].addError(ex.getStackTraceString()+'--'+ ex.getTypeName()+'--'+ ex.getMessage());
            }
        }
    }
    
    public static void updateLTI(List<Daily_Report__c> triggernew){
        
        Set<Id> unitIdSet = new Set<Id>();
        List<Unit__c> unitUpdateList = new List<Unit__c>();
        
        for(Daily_Report__c dr: triggernew){
            if(dr.Unit__c != null){
                unitIdSet.add(dr.Unit__c);
            }
        }
        
        if(!unitIdSet.isEmpty()){
            List<Unit__c> unitList = [Select Id,LTI__c,(Select Id,Report_Date__c from Daily_Reports__r where CreatedDate = Today LIMIT 2) from Unit__c where Id IN :unitIdSet];
            
            for(Unit__c unit: unitList){
                if(!unit.Daily_Reports__r.isEmpty() && unit.Daily_Reports__r.size() == 1){
                    unit.LTI__c = unit.LTI__c != null ? unit.LTI__c + 1 : 1;
                    unitUpdateList.add(unit);
                }
            }
            
            if(!unitUpdateList.isEmpty()){
                update unitUpdateList;
                DailyReportTriggerRecursion = true;
            }
            
        }
    }
    
    public static void preventDeletionOfSubmittedReport (List<Daily_Report__c> oldList){
        // 25 May - check if user has ability to delete DSJ and DSJS 
        User u = [select Id, AbilityToDeleteDSJAndDSJS__c, Profile.Name from User where Id = :UserInfo.getUserId() limit 1];
        
        for (Daily_Report__c rep : oldList){
            // 26 March: Revised rules on deletion
            if (u.Profile.Name != 'System Administrator'){
                if (rep.Status__c == 'Approved' || rep.Status__c == 'Invoiced'){
                    rep.addError('Daily Site Jobs that are approved or invoiced can no longer be deleted');
                }
                else if (!u.AbilityToDeleteDSJAndDSJS__c && rep.Status__c != 'Open' && rep.Status__c != 'Rejected'){
                    rep.addError('You can only delete Open or Rejected Daily Site Jobs.');
                }
            }
        }
    }
    
    public static void deleteParentDSJSIfStandAlone(List<Daily_Report__c> oldList){
        Set<Id> parentDSJSIdSet = new Set<Id>();
        
        for (Daily_Report__c rep : oldList){
            if (rep.UnitIsStandAlone__c && rep.Type__c == 'Camp'){
                parentDSJSIdSet.add(rep.Daily_Summary_Report__c);
            }
        }
        
        if (parentDSJSIdSet.size() > 0){
            List<Daily_Summary_Report__c> parentDSJSToDelete = [select Id from Daily_Summary_Report__c where Id in :parentDSJSIdSet];
            Database.delete(parentDSJSToDelete, false);
        }
    }
    
    public static void preventDuplicateReport(List<Daily_Report__c> triggernew){
        
        try{
            Set<Id> siteIdSet = new Set<Id>();
            Map<Id,List<Daily_Report__c>> mapSiteDailyReport = new Map<Id,List<Daily_Report__c>>();//Map<Site,List<DailyReport>>
            
            for(Daily_Report__c dr: triggernew){
                if(dr.Site__c != null && dr.Type__c != null && dr.Unit__c != null && dr.Report_Date__c != null){
                    siteIdSet.add(dr.Site__c);
                }
            }
            system.debug('siteIdSet: ' + siteIdSet);
            if(siteIdSet != null && !siteIdSet.isEmpty()){
                //06 Sept 2020: DB - Allow to create Transport Daily Site Job
                List<Daily_Report__c> dailyReportList = [Select Id,Name,Site__c,Type__c,Unit__c,Report_Date__c,Site__r.Name from Daily_Report__c
                                                         where (Type__c != null AND Type__c != 'Transport' AND Unit__c != null AND Report_Date__c != null) AND Site__c IN: siteIdSet];
                system.debug('dailyReportList: ' + dailyReportList);
                if(dailyReportList != null && !dailyReportList.isEmpty()){
                    for(Daily_Report__c dr: dailyReportList){
                        if(mapSiteDailyReport.containsKey(dr.Site__c) && mapSiteDailyReport.get(dr.Site__c) != null){
                            mapSiteDailyReport.get(dr.Site__c).add(dr);
                        }
                        else{
                            mapSiteDailyReport.put(dr.Site__c, new List<Daily_Report__c> {dr});
                        }
                    }
                }
                system.debug('mapSiteDailyReport: ' + mapSiteDailyReport);
                for(Daily_Report__c dr: triggernew){
                    if(mapSiteDailyReport.containsKey(dr.Site__c) && mapSiteDailyReport.get(dr.Site__c) != null){
                        for(Daily_Report__c dr2: mapSiteDailyReport.get(dr.Site__c)){
                            if((dr.Report_Date__c == dr2.Report_Date__c) && (dr.Type__c == dr2.Type__c) && (dr.Unit__c == dr2.Unit__c)){
                                dr.addError('Cannot create daily report. A Daily Report of the same type for this day has been already created for the Site: ' + dr2.Site__r.Name);
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e){System.debug('At '+e.getLineNumber()+'. Cause: '+e.getCause()+'. ErrorMessage: '+e.getMessage());}
    }
    
    public static void preventOpenReport(List<Daily_Report__c> triggernew){
        try{
            
            Set<Id> siteIdSet = new Set<Id>();
            Map<Id,List<Daily_Report__c>> mapSiteDailyReport = new Map<Id,List<Daily_Report__c>>();//Map<Site,List<DailyReport>>
            
            for(Daily_Report__c dr: triggernew){
                siteIdSet.add(dr.Site__c);
            }
            
            if(siteIdSet != null && !siteIdSet.isEmpty()){
                List<Daily_Report__c> dailyReportList = [Select Id,Name,Site__c,Type__c,Unit__c,Report_Date__c,Site__r.Name,Contract__c from Daily_Report__c
                                                         where Status__c = 'Open' AND Site__c IN: siteIdSet];
                
                if(dailyReportList != null && !dailyReportList.isEmpty()){
                    for(Daily_Report__c dr: dailyReportList){
                        if(mapSiteDailyReport.containsKey(dr.Site__c) && mapSiteDailyReport.get(dr.Site__c) != null){
                            mapSiteDailyReport.get(dr.Site__c).add(dr);
                        }
                        else{
                            mapSiteDailyReport.put(dr.Site__c, new List<Daily_Report__c> {dr});
                        }
                    }
                }
                
                for(Daily_Report__c dr: triggernew){
                
                    if(mapSiteDailyReport.containsKey(dr.Site__c) && mapSiteDailyReport.get(dr.Site__c) != null){
                        for(Daily_Report__c dr2: mapSiteDailyReport.get(dr.Site__c)){
                            if((dr.Contract__c == dr2.Contract__c) && (dr.Type__c == dr2.Type__c) && (dr.Unit__c == dr2.Unit__c) && ( (dr2.Report_Date__c < dr.Report_Date__c) || (dr2.Report_Date__c > dr.Report_Date__c))){
                                dr.addError('Daily Report cannot be created since a Daily Report '+dr2.Name+' of this type is open. Kindly, submit that report before creating a new one.');
                            }
                        }   
                    }
                }
            }
        }
        catch(Exception e){System.debug('At '+e.getLineNumber()+'. Cause: '+e.getCause()+'. ErrorMessage: '+e.getMessage());}
    }
}