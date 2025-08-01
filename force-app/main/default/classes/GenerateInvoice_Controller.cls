/**
* Created by Captain America on 20-Dec-17.
*/

public with sharing class GenerateInvoice_Controller {

    private final Invoice__c inv;
    public Invoice__c invoice { get; set; }
    public List<Daily_Summary_Report__c> dailySummaryReportList { get; set; }
    public List<JobItemSummaryWrapper> jobItemSummaryWrapperList { get; set; }
    public Map<Id,JobItemSummaryWrapper> jobItemWrapperMap { get; set; }
    public Decimal totalCost { get; set; }
    public List<Daily_Report__c> dailyReportList {get; set;}
    public String unitsAssigned { get; set; }
    public Map<Id,List<Daily_Report_Item__c>> dailyReportIdDailyReportItemsMap { get; set; }
    public Map<Id,Daily_Report__c> dailyReportMap2 { get; set; }
    public Decimal calculatedGst {get; set;}
    public Decimal totalWithGst {get; set;}
    public Decimal amountPaid  { get; set; }
    public Decimal balanceDue { get; set; }
    public Map<String,List<Daily_Report_Item__c>> itemNameItemDetailMap { get; set; }
    
    public GenerateInvoice_Controller(ApexPages.StandardController stdController) {

        try{
            jobItemSummaryWrapperList = new List<JobItemSummaryWrapper>();
            JobItemSummaryWrapper summaryWrapper;
            Set<String> unitsAssignedList = new Set<String>();
            unitsAssigned = '';
            dailyReportList = new List<Daily_Report__c>();
            dailyReportMap2 = new Map<Id,Daily_Report__c>();
            dailyReportIdDailyReportItemsMap = new Map<Id,List<Daily_Report_Item__c>>();
            itemNameItemDetailMap = new Map<String,List<Daily_Report_Item__c>>();
            jobItemWrapperMap = new Map<Id,JobItemSummaryWrapper>();
            Set<Id> dailySummaryReportIdSet = new Set<Id>();
            dailySummaryReportList = new List<Daily_Summary_Report__c>();
            totalCost = 0;
            calculatedGst = 0;
            totalWithGst = 0;
            amountPaid = 0;
            balanceDue = 0;

            inv = (Invoice__c) stdController.getRecord();
            invoice = [
                SELECT Id,Name,Site__c,Site__r.Name,Contract__c,Contract__r.Name,Contract__r.Account__r.Name,Contract__r.Contract_Start_Date__c,Purchase_Order__c,
                Contract__r.Account__r.BillingCity,Contract__r.Account__r.BillingStreet,Contract__r.Account__r.BillingState,Contract__r.Account__r.BillingPostalCode,Description__c,
                Contract__r.Account__r.BillingCountry,Site__r.Start_Date__c,Site__r.End_Date__c,Contract__r.Account__r.Terms__c, (
                        Select Id, Name, Invoice__c, Apply_Admin_Fee__c, Daily_Site_Job__c, Description__c, Group__c, Item_Name__c, Quantity__c, Total__c, Unit_Price__c,Create_Manually__c
                        from Invoice_Line_Items__r where Total__c != null
                )
                from
                Invoice__c
                where Id = :inv.Id
            ];


            Map<Id, Daily_Report__c> dailyReportMap = new Map<Id, Daily_Report__c>([SELECT Id,Site__c,Contract__c from Daily_Report__c where Site__c = :invoice.Site__c AND Contract__c = :invoice.Contract__c]);
            if (dailyReportMap != null && !dailyReportMap.keySet().isEmpty()) {
                List<AggregateResult> dailyReportAggregateResult = [
                        Select SUM(Number_of_Hours__c) totalHours,SUM(Quantity__c) totalQuantity, Contract_Job_Item__r.Item_Name__r.Name itemName, SUM(Total_Cost_Hour__c) totalHoursCost, 
                        SUM( Total_Cost_Quantity__c) totalQuantityCost,Contract_Job_Item__r.Item_Name__r.UOM__c unitOfMeasurement, Daily_Report__r.Type__c type
                        from Daily_Report_Item__c
                        where Daily_Report__c IN :dailyReportMap.keySet()
                        GROUP BY Contract_Job_Item__r.Item_Name__r.Name, Contract_Job_Item__r.Item_Name__r.UOM__c, Daily_Report__r.Type__c
                        ORDER BY Daily_Report__r.Type__c DESC
                ];

                dailyReportList = [
                        Select Id,Name,Type__c,Unit__r.Name,Incident_Occurred__c,Report_Date__c,Daily_Summary_Report__c, (
                                Select Id,Item_Name__c,Description__c,Rate__c,StartTime__c,EndTime__c,Number_of_Hours__c,Quantity__c,
                                        Total_Cost_Hour__c,Total_Cost_Quantity__c,Daily_Report__r.Name,Daily_Report__r.Report_Date__c,Contract_Job_Item__r.Item_Name__r.Name
                                from Daily_Report_Items__r
                        )
                        from Daily_Report__c
                        where Id IN :dailyReportMap.keySet()
                ];

                if(!invoice.Invoice_Line_Items__r.isEmpty()){
                    for(Invoice_Line_Item__c invoiceLineItem: invoice.Invoice_Line_Items__r){
                        JobItemSummaryWrapper jobItem = new JobItemSummaryWrapper();
                        jobItem.itemName = invoiceLineItem.Item_Name__c;
                        jobItem.totalQuantity = invoiceLineItem.Quantity__c;
                        jobItem.totalCostGroup = invoiceLineItem.Unit_Price__c;
                        jobItem.itemTotal = invoiceLineItem.Total__c;
                        jobItem.displayJobItemSummary = invoiceLineItem.Create_Manually__c ? false : true;
                        totalCost += invoiceLineItem.Total__c != null ? invoiceLineItem.Total__c : totalCost;
                        jobItemSummaryWrapperList.add(jobItem);
                    }
                }

                /*for (AggregateResult aggRes: dailyReportAggregateResult) {
                        system.debug(String.valueOf(aggRes.get('itemName')));
                        summaryWrapper = new JobItemSummaryWrapper();
                        summaryWrapper.itemName = String.valueOf(aggRes.get('itemName'));
                        summaryWrapper.unitOfMeasurement = String.valueOf(aggRes.get('unitOfMeasurement'));
                        if((Decimal) aggRes.get('totalHours') != null){
                            summaryWrapper.totalQuantity  = (Decimal) aggRes.get('totalHours');
                        }
                        else if((Decimal) aggRes.get('totalQuantity') != null){
                            summaryWrapper.totalQuantity  = (Decimal) aggRes.get('totalQuantity');
                        }
                        else{
                            summaryWrapper.totalQuantity = 0;
                        }
                        if((Decimal) aggRes.get('totalHoursCost') != null){
                            summaryWrapper.totalCostGroup = (Decimal) aggRes.get('totalHoursCost');
                            totalCost = totalCost + (Decimal) aggRes.get('totalHoursCost');
                        }
                        else if((Decimal) aggRes.get('totalQuantityCost') != null){
                            summaryWrapper.totalCostGroup = (Decimal) aggRes.get('totalQuantityCost');
                            totalCost = totalCost + (Decimal) aggRes.get('totalQuantityCost');
                        }
                        system.debug('summaryWrapper: ' + summaryWrapper);
                        jobItemSummaryWrapperList.add(summaryWrapper);
                    }*/


                
                
                system.debug('jobItemSummaryWrapperList: ' + jobItemSummaryWrapperList);
                
                //Create data for daily site jobs
                if (!dailyReportList.isEmpty()) {
                    for (Daily_Report__c dailyReport: dailyReportList) {
                        dailySummaryReportIdSet.add(dailyReport.Daily_Summary_Report__c);
                        unitsAssignedList.add(dailyReport.Unit__r.Name);
                        if (dailyReport.Daily_Report_Items__r != null && !dailyReport.Daily_Report_Items__r.isEmpty()) {
                            dailyReportMap2.put(dailyReport.Id,dailyReport);
                            for (Daily_Report_Item__c dailyReportItem: dailyReport.Daily_Report_Items__r) {
                                
                                /*if(dailyReportIdDailyReportItemsMap.containsKey(dailyReport.Id)){
                                    dailyReportIdDailyReportItemsMap.get(dailyReport.Id).add(dailyReportItem);
                                }
                                else{
                                    dailyReportIdDailyReportItemsMap.put(dailyReport.Id, new List<Daily_Report_Item__c>{dailyReportItem});
                                }*/
                                
                                if(itemNameItemDetailMap.containsKey(dailyReportItem.Item_Name__c)){
                                    itemNameItemDetailMap.get(dailyReportItem.Item_Name__c).add(dailyReportItem);
                                }
                                else{
                                    itemNameItemDetailMap.put(dailyReportItem.Item_Name__c,new List<Daily_Report_Item__c>{dailyReportItem});
                                }

                            //Create Map for DailyReportItemWrapper
                                summaryWrapper = new JobItemSummaryWrapper();
                                summaryWrapper.itemName = dailyReportItem.Item_Name__c;
                                if(dailyReportItem.Number_of_Hours__c != null){
                                    summaryWrapper.totalQuantity  = dailyReportItem.Number_of_Hours__c;
                                }
                                else if(dailyReportItem.Quantity__c != null){
                                    summaryWrapper.totalQuantity  = dailyReportItem.Quantity__c;
                                }
                                if(dailyReportItem.Total_Cost_Hour__c != null){
                                summaryWrapper.totalCostGroup  = dailyReportItem.Total_Cost_Hour__c;
                                }
                                else if(dailyReportItem.Total_Cost_Quantity__c != null){
                                summaryWrapper.totalCostGroup  = dailyReportItem.Total_Cost_Quantity__c;
                                }
                                jobItemWrapperMap.put(dailyReportItem.Id,summaryWrapper);
                            }

                        }
                    }
                }
                
                system.debug('itemNameItemDetailMap: ' + itemNameItemDetailMap);
                
                List<String> unitsAssignedListUnique = new List<String>();
                unitsAssignedListUnique.addAll(unitsAssignedList);
                unitsAssigned = String.join(unitsAssignedListUnique, ', ');
                
                dailySummaryReportList = [Select Id,Name,Summary_Report_Date__c,Date_Approved__c,Company_Manager_Name__c,Rig_Manager_Status_Approved_By__r.Name,Contract__r.Company_Manager__r.Name,Contract__r.Manager_Ops_Sup__r.Name,
                                          Ops_Manager_Status_Approved_By__r.Name,Contract__r.Manager_Ops_Sup__r.Email
                                          from Daily_Summary_Report__c where Id IN :dailySummaryReportIdSet];          
                
                //Calculate Gst and total with Gst 
                Decimal gstValue = Decimal.valueOf(Label.GstRate);
                Decimal tempCalculatedGst = totalCost * (gstValue/100);
                calculatedGst = tempCalculatedGst.setScale(2);
                totalWithGst = calculatedGst + totalCost;
                balanceDue = totalWithGst - amountPaid;



            }
        }
        catch(Exception e){
            System.debug('At '+e.getLineNumber()+'. Cause: '+e.getCause()+'. ErrorMessage: '+e.getMessage());
        }

    }

    public class JobItemSummaryWrapper {

        public String itemName { get; set; }
        public String unitOfMeasurement { get; set; }
        public Decimal totalQuantity { get; set; }
        public Decimal totalCostGroup { get; set; }
        public Decimal itemTotal { get; set; }
        public Boolean displayJobItemSummary { get; set; }
        
    }
    
    

}