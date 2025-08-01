/**********************************************************************************
* @author        Kunal Jain
* @date
* @description   This is a controller for DailySummaryReport_Pdf visualforce page,
DailySummaryReport_Pdf
* @TestClass     DailySummaryReport_PdfCtrlTest
***********************************************************************************/
public without sharing class DailySummaryReport_PdfCtrl {
    
    private final Id dailySummaryReportId;
    public List<Active_Personnel__c> activePersonnelList { get; set; }
    public String unitsAssigned { get; set; }
    public Daily_Report__c rigDailyReport { get; set; }
    public Daily_Report__c campDailyReport { get; set; }
    public Daily_Report__c transportDailyReport { get; set; }
    public List<Daily_Report__c> transportDSJList {get;set;} // 19 May 2021: Adding multiple DSJ for transport
    public SummaryWrapper rigSummaryWrapper { get; set; }
    public SummaryWrapper campSummaryWrapper { get; set; }
    //public SummaryWrapper transportSummaryWrapper { get; set; }
    public List<SummaryWrapper> transportSummaryWrapperList {get;set;}
    public List<ApprovalWrapper> approvalWrapperList { get; set; }
    
    
    public DailySummaryReport_PdfCtrl(ApexPages.StandardController stdController) {
        
        try {
            activePersonnelList = new List<Active_Personnel__c>();
            rigDailyReport = new Daily_Report__c();
            campDailyReport = new Daily_Report__c();
            transportDailyReport = new Daily_Report__c();
            transportDSJList = new List<Daily_Report__c>();
            rigSummaryWrapper = new SummaryWrapper();
            campSummaryWrapper = new SummaryWrapper();
            //transportSummaryWrapper = new SummaryWrapper();
            transportSummaryWrapperList = new List<SummaryWrapper>();
            approvalWrapperList = new List<ApprovalWrapper>();
            unitsAssigned = '';
            
            dailySummaryReportId = stdController.getId();
            Daily_Summary_Report__c dailySummaryReport = [Select Id,Status__c,Date_Approved__c,Company_Manager_Name__c from Daily_Summary_Report__c where Id = :dailySummaryReportId];
            String reportApprovedParam = ApexPages.currentPage().getParameters().get('reportApproved');
            
            List<Daily_Report__c> dailyReportList = [
                SELECT Auto_Create_Daily_Report_Items__c,Contract__c,Description__c,Fuel_Levels__c,Id,Line_on_Spool__c,Line_Slipped__c,Manager__c,Name,Contract__r.Company_Manager__r.Name,Contract__r.Manager_Ops_Sup__r.Name,
                No_of_KM_s_from_Previous_Site__c,Ops_Sup__c,OwnerId,Previous_Site__c,Report_Date__c,Rubbish_Levels__c,Septic_Levels__c,Site__c,Status__c,Total_Fuel_Used__c,Type__c,Contract__r.Company_Manager__r.Email,
                Unit__c,Water_Levels__c,Fuel_Delivered__c, Weather__c,Unit__r.Name, Unit__r.LTI__c, (
                    SELECT Admin_Fee__c,Contract_Job_Item__c,Contract_Job_Item__r.Name,Contract__c,Daily_Report__c,Daily_Site_Job_Summary__c,Description__c,EndTime__c,End_Time__c,Group__c,Id,
                    Item_Frequency__c,Item_Name_Editable__c,Item_Name__c,Name,Number_of_Hours__c,Quantity_Hour__c,Quantity__c,Rate__c,RecordTypeId,StartTime__c,Start_Time__c,
                    Total_Cost_Hour__c,Total_Cost_Quantity__c,Total_Cost__c,UOM__c,WD_Asset__c,RecordType.DeveloperName
                    FROM Daily_Report_Items__r ORDER BY Start_Time__c ASC NULLS LAST, End_Time__c ASC NULLS LAST
                ),
                (SELECT Crew_Change__c,Daily_Report__c,Employees__c,Id,Locale__c,Name,Personnel_Name__c,Position__c,Shift__c,Daily_Report__r.Unit__r.Name,Position__r.Name
                 FROM Active_Personnels__r),
                (SELECT Id FROM Hazard_Cards__r),
                (Select Id,RecordType.Name,RecordType.DeveloperName from HSEQ_Forms__r)
                FROM Daily_Report__c
                WHERE Daily_Summary_Report__c = :dailySummaryReportId
                ORDER BY Type__c ASC
            ];
            Set<Id> transportDSJIdSet = new Set<Id>();
            if (!dailyReportList.isEmpty()) {
                for (Daily_Report__c dailyReport : dailyReportList) {
                    system.debug('dailyReport.Type__c: ' + dailyReport.Type__c);
                    unitsAssigned += dailyReport.Unit__r.Name + ' ; ';
                    rigDailyReport = dailyReport.Type__c == 'Rig' ? dailyReport : rigDailyReport;
                    campDailyReport = dailyReport.Type__c == 'Camp' ? dailyReport : campDailyReport;
                    //transportDailyReport = dailyReport.Type__c == 'Transport' ? dailyReport : transportDailyReport;
                    if (dailyReport.Type__c == 'Transport'){
                        transportDSJList.add(dailyReport);
                        transportDSJIdSet.add(dailyReport.Id);
                    }
                    if(!dailyReport.Active_Personnels__r.isEmpty()){
                        activePersonnelList.addAll(dailyReport.Active_Personnels__r);
                    }
                }
                unitsAssigned = unitsAssigned.removeEnd(' ; ');
            }
            
            if(rigDailyReport.Id != null){
                rigSummaryWrapper = prepareSummaryWrapper (rigSummaryWrapper, rigDailyReport, 'Rig');
                List<ProcessInstance> processInstanceList = [SELECT Id,Status, TargetObjectId,CreatedDate FROM ProcessInstance where TargetObjectId = :rigDailyReport.Id  AND Status = 'Approved' ORDER BY CREATEDDATE DESC];
                if(!processInstanceList.isEmpty()){
                    ApprovalWrapper approvalWrap = DailySummaryReport_PdfCtrl.createApprovalWrapper(rigDailyReport.Contract__r.Manager_Ops_Sup__r.Name, processInstanceList[0].CreatedDate, dailySummaryReport.Company_Manager_Name__c, '(Rig)', dailySummaryReport.Date_Approved__c, reportApprovedParam, rigDailyReport.Contract__r.Company_Manager__r.Email);
                    approvalWrapperList.add(approvalWrap);
                }
                else {
                    ApprovalWrapper approvalWrap = DailySummaryReport_PdfCtrl.createApprovalWrapperFromHistory(rigDailyReport.Id, dailySummaryReport.Company_Manager_Name__c, '(Rig)', dailySummaryReport.Date_Approved__c, reportApprovedParam, rigDailyReport.Contract__r.Company_Manager__r.Email);
                    approvalWrapperList.add(approvalWrap);
                }
            }
            
            if(campDailyReport.Id != null){
                campSummaryWrapper = prepareSummaryWrapper(campSummaryWrapper, campDailyReport, 'Camp');
                List<ProcessInstance> processInstanceList = [SELECT Id,Status, TargetObjectId,CreatedDate FROM ProcessInstance where TargetObjectId = :campDailyReport.Id AND  Status = 'Approved' ORDER BY CREATEDDATE DESC];
                if(!processInstanceList.isEmpty()){
                    ApprovalWrapper approvalWrap = DailySummaryReport_PdfCtrl.createApprovalWrapper(campDailyReport.Contract__r.Manager_Ops_Sup__r.Name, processInstanceList[0].CreatedDate, dailySummaryReport.Company_Manager_Name__c, '(Camp)', dailySummaryReport.Date_Approved__c, reportApprovedParam, rigDailyReport.Contract__r.Company_Manager__r.Email);
                    approvalWrapperList.add(approvalWrap);
                }
                else {
                    ApprovalWrapper approvalWrap = DailySummaryReport_PdfCtrl.createApprovalWrapperFromHistory(campDailyReport.Id, dailySummaryReport.Company_Manager_Name__c, '(Camp)', dailySummaryReport.Date_Approved__c, reportApprovedParam, rigDailyReport.Contract__r.Company_Manager__r.Email);
                    approvalWrapperList.add(approvalWrap);
                }
            }
            /* 19 May 2021: Removed and replaced with list of Transport Daily Reports (DSJ)
            if(transportDailyReport.Id != null){
                transportSummaryWrapper = prepareSummaryWrapper (transportSummaryWrapper, transportDailyReport, 'Transport');
                List<ProcessInstance> processInstanceList = [SELECT Id,Status, TargetObjectId,CreatedDate FROM ProcessInstance where TargetObjectId = :transportDailyReport.Id  AND Status = 'Approved' ORDER BY CREATEDDATE DESC];
                if(!processInstanceList.isEmpty()){
                    ApprovalWrapper approvalWrap = DailySummaryReport_PdfCtrl.createApprovalWrapper(transportDailyReport.Contract__r.Manager_Ops_Sup__r.Name, processInstanceList[0].CreatedDate, dailySummaryReport.Company_Manager_Name__c, '(Transport)', dailySummaryReport.Date_Approved__c, reportApprovedParam, transportDailyReport.Contract__r.Company_Manager__r.Email);
                    approvalWrapperList.add(approvalWrap);
                }
                else {
                    ApprovalWrapper approvalWrap = DailySummaryReport_PdfCtrl.createApprovalWrapperFromHistory(transportDailyReport.Id, dailySummaryReport.Company_Manager_Name__c, '(Transport)', dailySummaryReport.Date_Approved__c, reportApprovedParam, transportDailyReport.Contract__r.Company_Manager__r.Email);
                    approvalWrapperList.add(approvalWrap);
                }
            }*/
            if (transportDSJList.size() > 0){
                List<ProcessInstance> processInstanceList = [SELECT Id,Status, TargetObjectId,CreatedDate FROM ProcessInstance where TargetObjectId in :transportDSJIdSet  AND Status = 'Approved' ORDER BY CREATEDDATE DESC];
                Map<Id, ProcessInstance> processInstanceIdMap = new Map<Id, ProcessInstance>();
                // approval history for tracking
                List<Daily_Report__History> dailySiteJobHistory = [select Id, Field, CreatedDate, NewValue, CreatedBy.Name from Daily_Report__History 
                                        where ParentId in :transportDSJIdSet
                                        and Field = 'Status__c'
                                        order by CreatedDate DESC];

                for (ProcessInstance pi : processInstanceList){
                    processInstanceIdMap.put(pi.TargetObjectId, pi);
                }
                for (Daily_Report__c transportDailyReport : transportDSJList){
                    if(transportDailyReport.Id != null){
                        SummaryWrapper tsw = new SummaryWrapper();
                        tsw = prepareSummaryWrapper (tsw, transportDailyReport, 'Transport');
                        transportSummaryWrapperList.add(tsw);
                        if(!processInstanceList.isEmpty()){
                            if (processInstanceIdMap.containsKey(transportDailyReport.Id)){
                                ApprovalWrapper approvalWrap = DailySummaryReport_PdfCtrl.createApprovalWrapper(transportDailyReport.Contract__r.Manager_Ops_Sup__r.Name, processInstanceIdMap.get(transportDailyReport.Id).CreatedDate, dailySummaryReport.Company_Manager_Name__c, '(Transport)', dailySummaryReport.Date_Approved__c, reportApprovedParam, transportDailyReport.Contract__r.Company_Manager__r.Email);
                                approvalWrapperList.add(approvalWrap);
                            }
                        }
                        else {
                            ApprovalWrapper approvalWrap = DailySummaryReport_PdfCtrl.createApprovalWrapperFromHistoryTransport(dailySummaryReport.Company_Manager_Name__c, '(Transport)', dailySummaryReport.Date_Approved__c, reportApprovedParam, transportDailyReport.Contract__r.Company_Manager__r.Email, dailySiteJobHistory);
                            approvalWrapperList.add(approvalWrap);
                        }
                    }
                }
            }
            //system.debug('approvalWrapperList: ' + approvalWrapperList);
            
        } catch (Exception e) {
            System.debug('In DailySummaryReport_Controller. At line: ' + e.getLineNumber() + '. Cause: ' + e.getCause() + '. ErrorMessage: ' + e.getMessage());
        }
    }
    
    public class SummaryWrapper {
        public Boolean reportPresent { get; set; }
        public Decimal ltiRigFreeDays { get; set; }
        public Integer hazards { get; set; }
        public Map<String, Integer> hseqCountMap { get; set; }
        public Map<String, Decimal> dailyJobItemQuantityMap { get; set; }
        // 10 Feb 2020: D BANEZ adding general data
        public Decimal waterLevels {get;set;}
        public Decimal rubbishLevels {get;set;}
        public Decimal fuelLevels {get;set;}
        public Decimal septicLevels {get;set;}
        public Decimal fuelDelivered {get;set;}
        // 19 May 2021: for multiple Transport DSJ's
        public Daily_Report__c dr {get;set;}
        
        public SummaryWrapper(){
            this.reportPresent = false;
            this.ltiRigFreeDays = 0;
            this.hazards = 0;
            this.waterLevels = 0;
            this.rubbishLevels = 0;
            this.fuelLevels = 0;
            this.septicLevels = 0;
            this.fuelDelivered = 0;
            this.hseqCountMap = new Map<String,Integer>();
            this.dailyJobItemQuantityMap = new Map<String,Decimal>();
            this.dr = new Daily_Report__c();
        }
        
    }
    
    public class ApprovalWrapper {
        public String opsManagerName { get; set; }
        public DateTime opsMgrApprovalDate { get; set; }
        public String opsMgrApprovalTime { get; set; }
        public String clientRepresentativeName { get; set; }
        public DateTime clientRepApprovalDate { get; set; }
        public String clientRepApprovalTime {get; set; }
        public String type { get; set; }
        public String clientRepEmailAddress { get; set;}
    }
    
    public static SummaryWrapper prepareSummaryWrapper(SummaryWrapper summary, Daily_Report__c dailyReport, String reportType){
        SummaryWrapper summaryWrap = summary;
        summary.reportPresent = true;
        summaryWrap.ltiRigFreeDays = dailyReport.Unit__r.LTI__c;
        summaryWrap.hazards = !dailyReport.Hazard_Cards__r.isEmpty() ? dailyReport.Hazard_Cards__r.size() : summaryWrap.hazards;
        // 10 Feb 2020: D BANEZ: set general data
        summaryWrap.waterLevels = dailyReport.Water_Levels__c;
        summaryWrap.rubbishLevels = dailyReport.Rubbish_Levels__c;
        summaryWrap.fuelLevels = dailyReport.Fuel_Levels__c;
        summaryWrap.septicLevels = dailyReport.Septic_Levels__c;
        summaryWrap.fuelDelivered = dailyReport.Fuel_Delivered__c;
        summaryWrap.dr = dailyReport;
        
        if(reportType == 'Rig'){
            List<String> rigStatsItemNameList = Label.Rig_Stats_Summary_Items.split(';');
            for(String rigStatName: rigStatsItemNameList){
                summaryWrap.dailyJobItemQuantityMap.put(rigStatName,0);
            }
            if(!dailyReport.Daily_Report_Items__r.isEmpty()){
                for(Daily_Report_Item__c dailyReportItem: dailyReport.Daily_Report_Items__r){
                    if(rigStatsItemNameList.contains(dailyReportItem.Contract_Job_Item__r.Name)){
                        Decimal itemQuantity = dailyReportItem.Quantity_Hour__c != null ? dailyReportItem.Quantity_Hour__c : 0;
                        Decimal tempQuantity = summaryWrap.dailyJobItemQuantityMap.get(dailyReportItem.Contract_Job_Item__r.Name);
                        summaryWrap.dailyJobItemQuantityMap.put(dailyReportItem.Contract_Job_Item__r.Name, tempQuantity + itemQuantity);
                    }
                }
            }
        }
        
        List<String> hseqRecordTypeLabels = (reportType == 'Rig') ? Label.Rig_Hseq_RecordTypes.split(';') : Label.Camp_Hseq_RecordTypes.split(';');
        
        if (reportType == 'Rig' || reportType == 'Camp'){
            List<RecordType> hseqRecordTypeList = [Select Id,DeveloperName,Name from RecordType where SObjectType='HSEQ_Forms__c' AND DeveloperName IN: hseqRecordTypeLabels ORDER BY Name];
        
            for(RecordType recType: hseqRecordTypeList){
                String recordTypeName = recType.DeveloperName == 'Safe_Operation_Procedure' ? 'SOP Review' : recType.Name;
                summaryWrap.hseqCountMap.put(recordTypeName,0);
            }
        }
        
        
        if(!dailyReport.HSEQ_Forms__r.isEmpty()){
            for(HSEQ_Forms__c hseqForm: dailyReport.HSEQ_Forms__r){
                String recordTypeName = hseqForm.RecordType.DeveloperName == 'Safe_Operation_Procedure' ? 'SOP Review' : hseqForm.RecordType.Name;
                if(summaryWrap.hseqCountMap.containsKey(recordTypeName)){
                    summaryWrap.hseqCountMap.put(recordTypeName, summaryWrap.hseqCountMap.get(recordTypeName) + 1);
                } else{
                    summaryWrap.hseqCountMap.put(recordTypeName, 1);
                }
            }
        }
        
        if(!dailyReport.Hazard_Cards__r.isEmpty()){
            summaryWrap.hazards = dailyReport.Hazard_Cards__r.size();
        }
        
        return summaryWrap;
        
    }
    
    
   
    public static ApprovalWrapper createApprovalWrapper(String opsManagerName, DateTime opsMgrApprovalDate, String clientRepresentativeName, String type, DateTime dateApproved, String reportApprovedParam, String clientRepEmailAddress){
        ApprovalWrapper approvalWrap = new ApprovalWrapper();
        approvalWrap.opsManagerName = opsManagerName;
        approvalWrap.opsMgrApprovalDate = opsMgrApprovalDate;
        approvalWrap.opsMgrApprovalTime = opsMgrApprovalDate.format('hh:mm a');
        approvalWrap.clientRepresentativeName = clientRepresentativeName;
        approvalWrap.clientRepApprovalDate = dateApproved != null ? dateApproved : String.isNotBlank(reportApprovedParam) ? System.now() : dateApproved;
        approvalWrap.clientRepApprovalTime = approvalWrap.clientRepApprovalDate != null ? approvalWrap.clientRepApprovalDate.format('hh:mm a') : null;
        approvalWrap.type = type;   
        approvalWrap.clientRepEmailAddress = clientRepEmailAddress;
        return approvalWrap;
    }
    
    public static ApprovalWrapper createApprovalWrapperFromHistory(Id recordId, String clientRepresentativeName, String type, DateTime dateApproved, String reportApprovedParam, String clientRepEmailAddress){
        ApprovalWrapper approvalWrap = new ApprovalWrapper();
        List<Daily_Report__History> dailySiteJobHistory = [select Id, Field, CreatedDate, NewValue, CreatedBy.Name from Daily_Report__History 
                                                          where ParentId = :recordId
                                                          and Field = 'Status__c'
                                                         order by CreatedDate DESC];
        for (Daily_Report__History drh : dailySiteJobHistory){
            if (drh.NewValue == 'Ops - Approved'){
                approvalWrap.opsManagerName = drh.CreatedBy.Name;
                approvalWrap.opsMgrApprovalDate = drh.CreatedDate;
                approvalWrap.opsMgrApprovalTime = approvalWrap.opsMgrApprovalDate.format('hh:mm a');
                approvalWrap.clientRepresentativeName = clientRepresentativeName;
                approvalWrap.clientRepApprovalDate = dateApproved != null ? dateApproved : String.isNotBlank(reportApprovedParam) ? System.now() : dateApproved;
                approvalWrap.clientRepApprovalTime = approvalWrap.clientRepApprovalDate != null ? approvalWrap.clientRepApprovalDate.format('hh:mm a') : null;
                approvalWrap.type = type;   
                approvalWrap.clientRepEmailAddress = clientRepEmailAddress;
                break;
            }
        }
        
        return approvalWrap;
    }

    public static ApprovalWrapper createApprovalWrapperFromHistoryTransport(String clientRepresentativeName, String type, DateTime dateApproved, String reportApprovedParam, String clientRepEmailAddress, List<Daily_Report__History> dailySiteJobHistory){
        ApprovalWrapper approvalWrap = new ApprovalWrapper();
        for (Daily_Report__History drh : dailySiteJobHistory){
            if (drh.NewValue == 'Ops - Approved'){
                approvalWrap.opsManagerName = drh.CreatedBy.Name;
                approvalWrap.opsMgrApprovalDate = drh.CreatedDate;
                approvalWrap.opsMgrApprovalTime = approvalWrap.opsMgrApprovalDate.format('hh:mm a');
                approvalWrap.clientRepresentativeName = clientRepresentativeName;
                approvalWrap.clientRepApprovalDate = dateApproved != null ? dateApproved : String.isNotBlank(reportApprovedParam) ? System.now() : dateApproved;
                approvalWrap.clientRepApprovalTime = approvalWrap.clientRepApprovalDate != null ? approvalWrap.clientRepApprovalDate.format('hh:mm a') : null;
                approvalWrap.type = type;   
                approvalWrap.clientRepEmailAddress = clientRepEmailAddress;
                break;
            }
        }
        
        return approvalWrap;
    }
    
}