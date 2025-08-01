trigger DailySummaryReportTrigger on Daily_Summary_Report__c (before insert, before update, before delete) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DailySummaryReportTriggerHandler.preventDuplicateSummaryReport(Trigger.new);
            //DailySummaryReportTriggerHandler.preventSubmittedStatus(Trigger.new,Trigger.OldMap);
            //DailySummaryReportTriggerHandler.checkAllDailyReportCreated(Trigger.new);
        }
        if(Trigger.isDelete){
            system.debug('Is Delete');
            DailySummaryReportTriggerHandler.preventDailySiteJobSummaryDeletion(Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            DailySummaryReportTriggerHandler.preventDuplicateSummaryReport(Trigger.new);
            //DailySummaryReportTriggerHandler.preventSubmittedStatus(Trigger.new,Trigger.OldMap);
            //DailySummaryReportTriggerHandler.checkAllDailyReportCreated(Trigger.new);
        }
    }
    
}