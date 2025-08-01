/**
 * @description       : 
 * @author            : Donnie Banez
 * @group             : 
 * @last modified on  : 06-09-2020
 * @last modified by  : Donnie Banez
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   06-09-2020   Donnie Banez   Initial Version
**/
public class SiteTrigger_Handler {
    
    public static Boolean SiteTriggerHandlerRecursion = false;
    
    //This method prevents Site Status Close if all Daily Reports are not submitted
    public static void preventSiteStatusClose(List<Site__c> triggernew, Map<Id, Site__c> triggerOldMap) {
        try {
            Set<Id> siteIdSet = new Set<Id>();
            
            for (Site__c sitedata : triggernew) {
                system.debug('sitedata: ' + sitedata);
                system.debug('sitedata.Site_Status__c: ' + sitedata.Site_Status__c);
                system.debug('sitedata.Site_Status__c previous: ' + triggerOldMap.get(sitedata.Id).Site_Status__c);
                if (sitedata.Contract__c != null && sitedata.Site_Status__c == 'Closed' && triggerOldMap.get(sitedata.Id).Site_Status__c != 'Closed') {
                    siteIdSet.add(sitedata.Id);
                }
            }
            system.debug('siteIdSet: ' + siteIdSet);
            /*List <Site__c> sitelist = [SELECT Id,(SELECT Id,Site__c,Status__c FROM Daily_Reports__r WHERE (Status__c = null OR Status__c = 'Open')) FROM Site__c WHERE Id IN: siteIdSet ]; */
            List <Site__c> sitelist = [SELECT Id, 
                            (SELECT Id FROM Daily_Summary_Reports__r WHERE Status__c != 'Approved'),
                            (select Id, Name, OwnerId, Owner.Name, Status__c, Job_Date__c, Site__c, Unit__c, Billable__c,
                                    Category__c from Transport_Jobs__r where Billable__c = true and
                                (Status__c = 'Assigned' or Status__c = 'In Progress' or Status__c = 'Completed'))
                            FROM Site__c WHERE Id IN:siteIdSet AND Contract__c != null];
           
            system.debug('sitelist: ' + sitelist);
            if (sitelist != null && !sitelist.isEmpty()) {
                for (Site__c sitedata : triggernew) {
                    for (Site__c site : sitelist) {
                        if (sitedata.Id == site.Id && site.Daily_Summary_Reports__r.size() > 0) {
                            sitedata.addError(' Site Status cannot be set to Closed since the all the Daily Summary Reports have not been Approved yet.');
                        }
                        if (sitedata.Id == site.Id && site.Transport_Jobs__r.size() > 0) {
                            sitedata.addError(' Site Status cannot be set to Closed since there are still open Transport Jobs.');
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('At ' + e.getLineNumber() + '. Cause: ' + e.getCause() + '. ErrorMessage: ' + e.getMessage());
        }
    }
    
    public static void preventActiveSite(List<Site__c> triggernew) {
        
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitions =
            new list<RollUpSummaryUtility.fieldDefinition>{
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'Id', 'Total_Active_Site__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitions, triggernew, 'Site__c', 'Contract__c', 'Contract__c', 'AND Site_Active__c = true');
        SiteTrigger_Handler.SiteTriggerHandlerRecursion = true;
        
    }
    
    public static void preventSiteDelete(Map<Id, Site__c> triggerOldMap) {
        
        try {
            Map<Id, Integer> siteIdRelatedRecordCount = new Map<Id, Integer>();
            for (Site__c site : triggerOldMap.values()) {
                if(site.Contract__c != null){
                    siteIdRelatedRecordCount.put(site.Id, 0);
                }
                
            }
            
            if(!siteIdRelatedRecordCount.keyset().isEmpty()){
                List<Daily_Report__c> dailyReportList = [Select Id,Site__c from Daily_Report__c where Site__c IN :triggerOldMap.keySet()];
                List<Daily_Summary_Report__c> dailySummaryReportList = [Select Id,Site__c from Daily_Summary_Report__c where Site__c IN :triggerOldMap.keySet()];
                //List<Invoice__c> invoiceList = [Select Id,Site__c from Invoice__c where Site__c IN :triggerOldMap.keySet()];
                
                if (!dailyReportList.isEmpty()) {
                    for (Daily_Report__c dailyReport : dailyReportList) {
                        Integer count = siteIdRelatedRecordCount.get(dailyReport.Site__c) + 1;
                        siteIdRelatedRecordCount.put(dailyReport.Site__c, count);
                    }
                }
                
                if (!dailySummaryReportList.isEmpty()) {
                    for (Daily_Summary_Report__c dailySummaryReport : dailySummaryReportList) {
                        Integer count = siteIdRelatedRecordCount.get(dailySummaryReport.Site__c) + 1;
                        siteIdRelatedRecordCount.put(dailySummaryReport.Site__c, count);
                    }
                }
                
                /*if (!invoiceList.isEmpty()) {
                    for (Invoice__c invoice : invoiceList) {
                    Integer count = siteIdRelatedRecordCount.get(invoice.Site__c) + 1;
                    siteIdRelatedRecordCount.put(invoice.Site__c, count);
                    }
                    }*/
                
                for (Site__c site : triggerOldMap.values()) {
                    if (siteIdRelatedRecordCount.get(site.Id) > 0) {
                        site.addError('You cannot delete a Site when there are records associated with it.');
                    }
                }
            }
            
            
        } catch (Exception e) {
            System.debug('In apex class: SiteTrigger_Handler . At line ' + e.getLineNumber() + '. Cause: ' + e.getCause() + '. ErrorMessage: ' + e.getMessage());
        }
        
        
    }
    
}