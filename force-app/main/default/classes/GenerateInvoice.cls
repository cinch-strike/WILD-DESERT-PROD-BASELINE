global with sharing class GenerateInvoice {

    public Static String stringResult;

    webservice static String generateInvoiceRecord(Id contId, Id siteId) {

        Id sitId = siteId;
        Id contractId = contId;
        Set<Id> dailySummaryReportIdSet = new Set<Id>();
        Set<Id> dailyReportIdSet = new Set<Id>();
        Map<Id, SiteWrapper> siteWrapperMap = new Map<Id, SiteWrapper>();
        SiteWrapper swrap;
        Decimal totalCost = 0;
        Invoice__c inv;
        Invoice_Line_Item__c invLtm;
        List<Invoice_Line_Item__c> invLtmInsertList;
        List<Daily_Report__c> dailyReportUpdateList;
        List<Daily_Summary_Report__c> dailySummaryReportList;
        String siteDescription;

        try {

            List<Invoice__c> invoiceList = [Select Id,Site__c from Invoice__c where Site__c = :sitId LIMIT 1];
            if(!invoiceList.isEmpty()){
                stringResult = 'An Invoice for this Site has been already been generated. You cannot generate a new Invoice.';
                return stringResult;
            }

            if (sitId != null && contractId != null) {
                Site__c site = [Select Id,Job_Description__c from Site__c where Id = :sitId];
                siteDescription = String.isNotBlank(site.Job_Description__c) ? site.Job_Description__c : '';
                dailySummaryReportList = [Select Id,Contract__c,Status__c,Invoice__c,Summary_Report_Date__c from Daily_Summary_Report__c where Contract__c = :contractId AND Status__c = 'Approved' AND Site__c = :sitId ORDER BY Summary_Report_Date__c];
            } else if (contractId != null) {
                dailySummaryReportList = [Select Id,Contract__c,Status__c,Invoice__c,Summary_Report_Date__c from Daily_Summary_Report__c where Contract__c = :contractId AND Status__c = 'Approved' ORDER BY Summary_Report_Date__c];
            }


            if (dailySummaryReportList != null && !dailySummaryReportList.isEmpty()) {
                for (Daily_Summary_Report__c dsr: dailySummaryReportList) {
                    dailySummaryReportIdSet.add(dsr.Id);
                }
                
                if (dailySummaryReportIdSet != null && !dailySummaryReportIdSet.isEmpty()) {
                    List<Daily_Report__c> dailyReportsList = [Select Id,Status__c, (Select Id,Item_Name__c,Quantity__c,Number_of_Hours__c,Rate__c,Total_Cost_Hour__c,Total_Cost_Quantity__c,Contract_Job_Item__r.UOM__c from Daily_Report_Items__r) from Daily_Report__c where Daily_Summary_Report__c IN:dailySummaryReportIdSet AND Status__c = 'Approved'];
                    
                    if (dailyReportsList != null && !dailyReportsList.isEmpty()) {
                        for (Daily_Report__c dr: dailyReportsList) {
                            dailyReportIdSet.add(dr.Id);
                        }
                        
                        if (dailyReportIdSet != null && !dailyReportIdSet.isEmpty()) {

                            List<Daily_Report_Item__c> driListItemName = [
                                    Select Id,Contract_Job_Item__r.UOM__c,Item_Name__c,Quantity__c,Number_of_Hours__c,Rate__c,Total_Cost_Hour__c,Total_Cost_Quantity__c,Contract_Job_Item__c,Daily_Report__r.Name,Group__c,Contract_Job_Item__r.Service_Type__c
                                    from Daily_Report_Item__c
                                    where Daily_Report__c IN:dailyReportIdSet
                            ];
                            
                            if (driListItemName != null && !driListItemName.isEmpty()) {
                                for (Daily_Report_Item__c dri: driListItemName) {
                                    if (siteWrapperMap.containsKey(dri.Contract_Job_Item__c) && siteWrapperMap.get(dri.Contract_Job_Item__c) != null) {
                                        
                                        if (dri.Quantity__c != null && dri.Quantity__c != 0) {
                                            siteWrapperMap.get(dri.Contract_Job_Item__c).totalQuantity = siteWrapperMap.get(dri.Contract_Job_Item__c).totalQuantity + dri.Quantity__c;
                                        } else if (dri.Number_of_Hours__c != null) {
                                            siteWrapperMap.get(dri.Contract_Job_Item__c).totalQuantity = siteWrapperMap.get(dri.Contract_Job_Item__c).totalQuantity + dri.Number_of_Hours__c;
                                        }
                                        if (dri.Total_Cost_Quantity__c != null) {
                                            siteWrapperMap.get(dri.Contract_Job_Item__c).totalCost = siteWrapperMap.get(dri.Contract_Job_Item__c).totalCost + dri.Total_Cost_Quantity__c;
                                        } else if (dri.Total_Cost_Hour__c != null) {
                                            siteWrapperMap.get(dri.Contract_Job_Item__c).totalCost = siteWrapperMap.get(dri.Contract_Job_Item__c).totalCost + dri.Total_Cost_Hour__c;
                                        }
                                        siteWrapperMap.get(dri.Contract_Job_Item__c).description = siteWrapperMap.get(dri.Contract_Job_Item__c).description + ';' + dri.Daily_Report__r.Name;
                                    } else {
                                        swrap = new SiteWrapper();
                                        swrap.itemName = dri.Item_Name__c;
                                        swrap.rate = dri.Contract_Job_Item__r.Service_Type__c == 'Flexi Price/Quantity' && dri.Rate__c != null ? dri.Rate__c : dri.Contract_Job_Item__r.Service_Type__c == 'Flexi Price/Quantity' && dri.Rate__c == null ? 0 : dri.Rate__c;
                                        swrap.grp = dri.Group__c;
                                        swrap.unitOfMeasurement = dri.Contract_Job_Item__r.UOM__c;
                                        
                                        if (dri.Quantity__c != null && dri.Quantity__c != 0) {
                                            swrap.totalQuantity = dri.Quantity__c;
                                        } else if (dri.Number_of_Hours__c != null) {
                                            swrap.totalQuantity = dri.Number_of_Hours__c;
                                        } else {
                                            swrap.totalQuantity = 0;
                                        }

                                        if (dri.Total_Cost_Quantity__c != null) {
                                            swrap.totalCost = dri.Total_Cost_Quantity__c;
                                        } else if (dri.Total_Cost_Hour__c != null) {
                                            swrap.totalCost = dri.Total_Cost_Hour__c;
                                        } else {
                                            swrap.totalCost = 0;
                                        }

                                        swrap.description = dri.Daily_Report__r.Name;
                                        swrap.serviceType = dri.Contract_Job_Item__r.Service_Type__c;
                                        siteWrapperMap.put(dri.Contract_Job_Item__c, swrap);
                                    }
                                }
                                
                                if (siteWrapperMap != null && siteWrapperMap.values() != null && !siteWrapperMap.values().isEmpty()) {

                                    inv = new Invoice__c();
                                    inv.Contract__c = contractId;
                                    inv.Site__c = (sitId != null) ? sitId : null;
                                    inv.Start_Date__c = dailySummaryReportList[0].Summary_Report_Date__c;
                                    inv.End_Date__c = dailySummaryReportList[dailySummaryReportList.size() - 1].Summary_Report_Date__c;
                                    inv.Description__c = siteDescription;
                                    insert inv;
                                    
                                    invLtmInsertList = new List<Invoice_Line_Item__c>();
                                    for (SiteWrapper sw: siteWrapperMap.values()) {
                                        invLtm = new Invoice_Line_Item__c();
                                        invLtm.Item_Name__c = sw.itemName;
                                        invLtm.Invoice__c = inv.Id;
                                        invLtm.Daily_Site_Job__c= sw.description;
                                        invLtm.UOM__c = sw.unitOfMeasurement;
                                        invLtm.Unit_Price__c = sw.rate;
                                        invLtm.Quantity__c = sw.totalQuantity;
                                        invLtm.Group__c = sw.grp;
                                        invLtm.Apply_Admin_Fee__c = (sw.serviceType == 'Flexi Price/Quantity') ? true : false;
                                        invLtm.Description__c = sw.description;
                                        invLtm.Create_Manually__c = false;
                                        invLtmInsertList.add(invLtm);
                                    }
                                    
                                    if (invLtmInsertList != null && !invLtmInsertList.isEmpty()) {
                                        insert invLtmInsertList;
                                        //stringResult = 'You have successfully generated an Invoice.';
                                        stringResult = inv.Id;
                                    }

                                    if (dailySummaryReportList != null && !dailySummaryReportList.isEmpty()) {
                                        List<Daily_Summary_Report__c> updateDailySummaryReport = new List<Daily_Summary_Report__c>();
                                        for (Daily_Summary_Report__c dsr: dailySummaryReportList) {
                                            dsr.Invoice__c = inv.Id;
                                            dsr.Status__c = 'Invoiced';
                                            dsr.Invoice__c = (inv != null) ? inv.Id : null;
                                            updateDailySummaryReport.add(dsr);
                                        }
                                        update updateDailySummaryReport;
                                    }

                                    if (dailyReportsList != null && !dailyReportsList.isEmpty()) {
                                        List<Daily_Report__c> updateDailyReport = new List<Daily_Report__c>();
                                        for (Daily_Report__c dsr: dailyReportsList) {
                                            dsr.Status__c = 'Invoiced';
                                            dsr.Invoice__c = inv.Id;
                                            updateDailyReport.add(dsr);
                                        }
                                        update updateDailyReport;
                                    }


                                }


                            }


                        }


                    } else {
                        stringResult = 'Couldn\'t find any Approved Daily Reports. Kindly, check the status of existing Daily Reports or create a new one and get it Approved.';
                    }
                }
            } else {
                stringResult = 'Couldn\'t find any Approved Daily Summary Reports. Kindly, check the status of existing Daily Summary Reports or create a new one and get it Approved.';
            }


        } catch (Exception e) {stringResult = 'Cause: ' + e.getCause() + '. ErrorMessage: ' + e.getMessage();}

        return stringResult;
    }

    public class SiteWrapper {

        public String itemName;
        public Decimal rate;
        public Decimal totalQuantity;
        public Decimal totalCost;
        public String description;
        public String grp;
        public String serviceType;
        public String unitOfMeasurement;

    }


}