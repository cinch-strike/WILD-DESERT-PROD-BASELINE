public class DailySummaryReportTriggerHandler {
    
     
    public static void preventDuplicateSummaryReport(List<Daily_Summary_Report__c> triggernew) {
        
        try{
            Set<Id> siteIdSet = new Set<Id>();
            Map<Id, List<Daily_Summary_Report__c>> siteDailySummariesMap = new Map<Id, List<Daily_Summary_Report__c>>();
            
            for (Daily_Summary_Report__c dsr: triggernew) {
                if (dsr.Site__c != null) {
                    siteIdSet.add(dsr.Site__c);
                }
            }
            
            if (!siteIdSet.isEmpty()) {
                List<Daily_Summary_Report__c> dailySummaryList = [SELECT Id,Name,Site__c,Summary_Report_Date__c FROM Daily_Summary_Report__c
                    WHERE Site__c IN :siteIdSet]; // 13 MAY 2023: Making it more bulk proof; we only need to get the DSJs related to site
                
                if (dailySummaryList != null && !dailySummaryList.isEmpty()) {
                    for (Daily_Summary_Report__c dsr: dailySummaryList) {
                        if (siteDailySummariesMap.containsKey(dsr.Site__c) && siteDailySummariesMap.get(dsr.Site__c) != null) {
                            siteDailySummariesMap.get(dsr.Site__c).add(dsr);
                        } else {
                            siteDailySummariesMap.put(dsr.Site__c, new List<Daily_Summary_Report__c>{dsr});
                        }
                    }
                }
                
                for (Daily_Summary_Report__c dsr: triggernew) {
                    if (siteDailySummariesMap.containsKey(dsr.Site__c) && siteDailySummariesMap.get(dsr.Site__c) != null) {
                        for (Daily_Summary_Report__c dsr2: siteDailySummariesMap.get(dsr.Site__c)) {
                            if (dsr.Id != dsr2.Id && dsr.Site__c == dsr2.Site__c && dsr.Summary_Report_Date__c == dsr2.Summary_Report_Date__c) {
                                
                                //06 Sept 2020: DB: Create Daily Site Job Summary for Transport Daily Site Job 
                                /*List<Daily_Report__c> dailySiteJobList = [Select Id from Daily_Report__c WHERE Daily_Summary_Report__c = null
                                                                         AND Type__c = 'Transport' and Report_Date__c = :dsr.Summary_Report_Date__c];*/
                                
                                if (dailySummaryList == null && dailySummaryList.isEmpty()) {
                                	dsr.addError('A Daily Site Job Summary of this type has already been created: ' + dsr2.Name);
                                }
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e){
            System.debug('At '+e.getLineNumber()+'. Cause: '+e.getCause()+'. ErrorMessage: '+e.getMessage());
        }
        
        
    }

    public static void preventDailySiteJobSummaryDeletion(Map<Id,Daily_Summary_Report__c> triggerOldMap){
        system.debug('preventDailySiteJobSummaryDeletion called');
        try{
            List<Daily_Summary_Report__c> dailySummaryReportList = [Select Id,(Select Id from Daily_Reports__r) from Daily_Summary_Report__c WHERE ID IN: triggerOldMap.keySet()];

            for(Daily_Summary_Report__c dailySummaryReport: dailySummaryReportList){
                if(!dailySummaryReport.Daily_Reports__r.isEmpty()){
                    system.debug(triggerOldMap.containsKey(dailySummaryReport.Id));
                    triggerOldMap.get(dailySummaryReport.Id).addError('You cannot delete a Daily Site Job Summary if it has Daily Site Jobs Attached to it.');
                }
            }

        } catch(Exception e){
            System.debug('At '+e.getLineNumber()+'. Cause: '+e.getCause()+'. ErrorMessage: '+e.getMessage());
        }

    }
    
     /******************************************************************************************
    * Code commented by: Kunal Jain
    * Reason: There might be a case wherein there might be one camp report and three rig reports
    * for the day. To handle that case, we are not using this logic anymore.
    ********************************************************************************************/
    /*public static void checkAllDailyReportCreated(List<Daily_Summary_Report__c> triggernew) {
        
        Set<Id> dsrIdSet = new Set<Id>();
        Set<Id> contractIdSet = new Set<Id>();
        Map<Id, List<Contract_Assignment__c>> mapContractWithAssignments = new Map<Id, List<Contract_Assignment__c>>();
        Map<Id, List<Daily_Report__c>> mapDailySummaryReportWithDailyReport = new Map<Id, List<Daily_Report__c>>();
        
        for (Daily_Summary_Report__c dsr: triggernew) {
            if (dsr.Status__c == 'Submitted') {
                dsrIdSet.add(dsr.Id);
                contractIdSet.add(dsr.Contract__c);
            }
        }
        
        if (!dsrIdSet.isEmpty() && !contractIdSet.isEmpty()) {
            List<Contract_Assignment__c> contractAssignmentList = [Select Id,Contract__c from Contract_Assignment__c where Contract__c = :contractIdSet AND Active__c = true];
            
            if (contractAssignmentList != null && !contractAssignmentList.isEmpty()) {
                for (Contract_Assignment__c contractAssignment: contractAssignmentList) {
                    if (mapContractWithAssignments.containsKey(contractAssignment.Contract__c) && mapContractWithAssignments.get(contractAssignment.Contract__c) != null) {
                        mapContractWithAssignments.get(contractAssignment.Contract__c).add(contractAssignment);
                    } else {
                        mapContractWithAssignments.put(contractAssignment.Contract__c, new List<Contract_Assignment__c>{contractAssignment});
                    }
                }
                
                
                if (!mapContractWithAssignments.keySet().isEmpty()) {
                    List<Daily_Report__c> dailyReportList = [select Id,Daily_Summary_Report__c from Daily_Report__c where Daily_Summary_Report__c = :dsrIdSet];
                    
                    if (dailyReportList != null && !dailyReportList.isEmpty()) {
                        for (Daily_Report__c dailyReport: dailyReportList) {
                            if (mapDailySummaryReportWithDailyReport.containsKey(dailyReport.Daily_Summary_Report__c) && mapDailySummaryReportWithDailyReport.get(dailyReport.Daily_Summary_Report__c) != null) {
                                mapDailySummaryReportWithDailyReport.get(dailyReport.Daily_Summary_Report__c).add(dailyReport);
                            } else {
                                mapDailySummaryReportWithDailyReport.put(dailyReport.Daily_Summary_Report__c, new List<Daily_Report__c>{dailyReport});
                            }
                        }
                    }
                }
                
                for (Daily_Summary_Report__c dailySummaryReport: triggernew) {
                    if (dsrIdSet.contains(dailySummaryReport.Id) && mapContractWithAssignments.containsKey(dailySummaryReport.Contract__c) &&
                        mapDailySummaryReportWithDailyReport.containsKey(dailySummaryReport.Id)) {
                            if (mapDailySummaryReportWithDailyReport.get(dailySummaryReport.Id).size() < mapContractWithAssignments.get(dailySummaryReport.Contract__c).size()) {
                                dailySummaryReport.addError('All Daily Reports must be created and submitted before this Daily Summary Report can be submitted for approval');
                            }
                        }
                }
                
            }
        }
    }*/
    
}