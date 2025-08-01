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
public without sharing class DailySiteJobSummaryDetail_Controller {
    
    private final Daily_Summary_Report__c dailySummary;
    public Daily_Summary_Report__c dailySiteJobSummary { get; set; }
    public List<Daily_Report__c> dailyReportList { get; set; }
    public Map<Id, List<Active_Personnel__c>> dailyReportIdActivePersonnelsMap { get; set; }
    public Boolean showCancelPopup {get;set;}
    public Boolean userTypeGuest { get; set; }
    public String baseUrl { get; set; }
    public Id companyMgrContactId;
    public Id opsSupId;
    public Boolean sendEmailConfirmationModal { get; set; }
    public Boolean rejectConfirmationModal { get; set; }
    public Boolean sendOpsSupEmailConfirmationModal {get;set;}
    public Integer totalDailySiteJobCount { get; set; }
    public Boolean rigManagerApproval {get;set;}
    public Boolean opsSupApproval {get;set;}
    public Boolean disableSubmitToOpsSup {get;set;}
    public Boolean disableApproveSendToOCR {get;set;}
    public String dailySiteJobToRejectId {get;set;}
    
    public Boolean showDeleteButton {
        get {
            User u = [select Id, AbilityToDeleteDSJAndDSJS__c, Profile.Name from User where Id = :UserInfo.getUserId() limit 1];
            if (u.Profile.Name == 'System Administrator'){
                showDeleteButton = true;
            }
            else if (dailySiteJobSummary.Status__c == 'Approved' || dailySiteJobSummary.Status__c == 'Invoiced'){
                showDeleteButton = false;
            }
            else {
                showDeleteButton = (u.AbilityToDeleteDSJAndDSJS__c || dailySiteJobSummary.Status__c == 'Open') && !userTypeGuest;
            }
            
            return showDeleteButton;
        }
        set;
    }
    
    public Boolean hasOpenTransportJobs {
        get {
            return (openTransportJobs.size()>0);
        }
        set;
    }
    
    public List<Transport_Job__c> openTransportJobs {
        get {
            if (openTransportJobs == null){
                openTransportJobs = new List<Transport_Job__c>();
                openTransportJobs = [select Id, Name, OwnerId, Owner.Name, Status__c, Job_Date__c, Site__c, Unit__c, Billable__c,
                                     Category__c from Transport_Job__c
                                    where Billable__c = true and Site__c = :dailySiteJobSummary.Site__c and 
                                    (Status__c = 'Assigned' or Status__c = 'In Progress' or Status__c = 'Completed')
                                    order by Job_Date__c asc];
            }
            return openTransportJobs;
        }
        set;
       
    }
    public DailySiteJobSummaryDetail_Controller(ApexPages.StandardController stdController) {
        
        try{
            baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            showCancelPopup = false;
            totalDailySiteJobCount = 0;
            sendEmailConfirmationModal = false;
            sendOpsSupEmailConfirmationModal = false;
            rejectConfirmationModal = false;
            disableSubmitToOpsSup = false;
            disableApproveSendToOCR = false;
            dailySiteJobToRejectId = null;
            
            userTypeGuest = UserInfo.getUserType() == 'Guest' ? true : false;
            dailyReportIdActivePersonnelsMap = new Map<Id, List<Active_Personnel__c>>();
            dailySummary = (Daily_Summary_Report__c) stdController.getRecord();
            
            
            dailySiteJobSummary = [
                    SELECT Id,Name,Status__c,Contract__c,Site__c,Summary_Report_Date__c,Invoice__c,Company_Manager_Name__c,Company_Manager_Comments__c, Contract__r.Company_Manager__c, Rig_Manager__c,
                    Contract__r.Manager_Ops_Sup__c, Ops_Supervisor__c
                    from Daily_Summary_Report__c
                    where Id = :dailySummary.Id
            ];
            companyMgrContactId = dailySiteJobSummary.Contract__r.Company_Manager__c;
            opsSupId = dailySiteJobSummary.Contract__r.Manager_Ops_Sup__c;
            if(userTypeGuest){
                Contract__c con = [Select Id,Company_Manager__r.Name from Contract__c where Company_Manager__c != NULL AND Id= :dailySiteJobSummary.Contract__c];
                dailySiteJobSummary.Company_Manager_Name__c = con.Company_Manager__r.Name;
                companyMgrContactId = con.Company_Manager__c;
            }
            
            
            dailyReportList = [
                SELECT Id,Name,Daily_Summary_Report__c,Type__c,Unit__c,Unit__r.Name,Contract__c,Line_on_Spool__c,Line_Slipped__c,No_of_KM_s_from_Previous_Site__c,Previous_Site__c,
                Weather__c,Site__c,Report_Date__c,Status__c,Description__c,Auto_Create_Daily_Report_Items__c,Total_Fuel_Used__c,Water_Levels__c,Fuel_Levels__c,Fuel_Delivered__c, Septic_Levels__c,Rubbish_Levels__c,
                OpsSupervisorApprovalNotes__c
                from Daily_Report__c
                where Daily_Summary_Report__c = :dailySiteJobSummary.Id
            ];
            
           List<Active_Personnel__c> activePersonnelList = [
    SELECT Id, Name, Crew__c, Crew_Change__c, Daily_Report__c, Employees__c, Position__c, Position__r.Name,
           Employees__r.Shift__c, Employees__r.Name, Personnel_Name__c, Shift__c, Locale__c,
           Travel_Hrs__c, Work_Hrs__c, RM_Notes__c
    FROM Active_Personnel__c
    WHERE Daily_Report__c IN :dailyReportList
];
            
            if (dailyReportList != null && !dailyReportList.isEmpty()) {
                totalDailySiteJobCount = dailyReportList.size();
                /*for (Daily_Report__c dailyReport: dailyReportList) {
                    dailyReportIdActivePersonnelsMap.put(dailyReport.Id, new List<Active_Personnel__c>());
                    if (dailyReport.Active_Personnels__r != null && !dailyReport.Active_Personnels__r.isEmpty()) {
                        for (Active_Personnel__c activePersonnel: dailyReport.Active_Personnels__r) {
                            dailyReportIdActivePersonnelsMap.get(dailyReport.Id).add(activePersonnel);
                        }
                    }
                }*/
                if(!activePersonnelList.isEmpty()){
                    for(Active_Personnel__c activePersonnel: activePersonnelList){
                        if(!dailyReportIdActivePersonnelsMap.containsKey(activePersonnel.Daily_Report__c)){
                            dailyReportIdActivePersonnelsMap.put(activePersonnel.Daily_Report__c, new List<Active_Personnel__c>());
                        }
                        dailyReportIdActivePersonnelsMap.get(activePersonnel.Daily_Report__c).add(activePersonnel);
                    }
                    activePersonnelList = null;
                }
            }
            
            // 7 March 2020
            rigManagerApproval = ((dailySiteJobSummary.Status__c == 'Open' || dailySiteJobSummary.Status__c == 'Rejected' || dailySiteJobSummary.Status__c == 'Pending') && UserInfo.getUserId() == dailySiteJobSummary.Rig_Manager__c); // rig manager only
            for (Daily_Report__c report : dailyReportList){
                if (report.Status__c != 'Manager - Approved' && report.Status__c != 'Ops - Approved'){
                    disableSubmitToOpsSup = true;
                    disableApproveSendToOCR = true;
                    break;
                }
            }
            opsSupApproval = ((dailySiteJobSummary.Status__c == 'Submitted' || dailySiteJobSummary.Status__c == 'Rejected') && UserInfo.getUserId() == dailySiteJobSummary.Ops_Supervisor__c);
        }
        
        catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + e)); }
    }
    
    public pageReference showCancelModal() {
        showCancelPopup = true;
        return null;
    }

    public PageReference hideApprovalModal(){
        showCancelPopup = false;
        return null;
    }

    public PageReference approveReport(){
        dailySiteJobSummary.Status__c = 'Approved';
        dailySiteJobSummary.Date_Approved__c = System.now();
        Database.SaveResult saveResult = Database.update(dailySiteJobSummary);
        //update dailySiteJobSummary;
        if(saveResult.isSuccess()){
            sendApprovedPdfCopyToClientRep();
            sendEmailToRigManager('Daily_Site_Job_Summary_Approved');
            sendEmailToOpsSupervisor('Daily_Site_Job_Summary_Approved');
        }

        renderConfirmationModal();
        //sendReportToCompanyManager();
        showCancelPopup = false;
        PageReference pgRef = new PageReference(baseUrl + '/approval/DailySiteJobSummary_VF?id='+dailySiteJobSummary.Id);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public PageReference rejectReport(){
        dailySiteJobSummary.Status__c = 'Rejected';
        update dailySiteJobSummary;
        sendEmailToOpsSupervisor('Daily_Site_Job_Summary_Rejected');
        showCancelPopup = false;
        PageReference pgRef = new PageReference(baseUrl + '/approval/DailySiteJobSummary_VF?id='+dailySiteJobSummary.Id);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public PageReference createPdfOpenedTask(){
        
        try{
            if(userTypeGuest){
                String taskSubject = 'OCR Opened the Daily Summary Report PDF';
                List<Task> taskList = [Select Id,Subject from Task where WhatId = :dailySiteJobSummary.Id AND Subject = :taskSubject];
        
                if(taskList.size() == 0){
                    Task tsk = new Task();
                    tsk.WhatId = dailySiteJobSummary.Id;
                    tsk.Status = 'Completed';
                    tsk.Subject = 'OCR Opened the Daily Summary Report PDF';
                    tsk.Priority = 'Normal';
                    tsk.WhoId = companyMgrContactId;
                    insert tsk;
                }
            }          
            
            PageReference pageRef = new PageReference(baseUrl + '/apex/DailySummaryReport_Pdf?id=' + dailySiteJobSummary.Id);
            return pageRef;
        }
        catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + e)); return null; }       
    }

    public void renderConfirmationModal(){
        sendEmailConfirmationModal = sendEmailConfirmationModal ? false : true;
    }
    
    public void rejectConfirmationModal(){
        rejectConfirmationModal = rejectConfirmationModal ? false : true;
    }
    
    public void renderOpsSupConfirmationModal(){
        sendOpsSupEmailConfirmationModal = sendOpsSupEmailConfirmationModal ? false : true;
    }
    
    public PageReference sendEmailToCompanyMan(){
        String siteJobSummaryStatusPriorValue = dailySiteJobSummary.Status__c;
        try{
            
            dailySiteJobSummary.Status__c = 'Ops Mgr - Approved';
            update dailySiteJobSummary;
            /* 14 Nov 2023 : Moving sending of email to Flow
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            Id emailTemplateId = [Select Id from EmailTemplate where DeveloperName = 'Company_Manager_Approval'].Id;
            email.setTemplateId(emailTemplateId);
            email.setTargetObjectId(companyMgrContactId); 
            email.setWhatId(dailySummary.Id);
            email.setSaveAsActivity(true);
            emails.add(email);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});*/
            sendEmailConfirmationModal = false;
        }
        catch(Exception e){
            dailySiteJobSummary.Status__c = siteJobSummaryStatusPriorValue;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Oops An error has occurred: ' + e.getMessage()));
            return null;
        }
        
        PageReference pRef = Page.DailySiteJobSummary_VF;
        pRef.getParameters().put('id', dailySiteJobSummary.Id);
        pRef.setRedirect(true);
        return pRef;
    }
    
    public PageReference sendRequestToOpsSupervisor(){
        String siteJobSummaryStatusPriorValue = dailySiteJobSummary.Status__c;
        try{
            dailySiteJobSummary.Status__c = 'Submitted';
            update dailySiteJobSummary;
            sendOpsSupEmailConfirmationModal = false;
        }
        catch(Exception e){
            dailySiteJobSummary.Status__c = siteJobSummaryStatusPriorValue;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Oops An error has occurred: ' + e.getMessage()));
            return null;
        }
        PageReference pRef = Page.DailySiteJobSummary_VF;
        pRef.getParameters().put('id', dailySiteJobSummary.Id);
        pRef.setRedirect(true);
        return pRef;
    }
    
    public void sendApprovedPdfCopyToClientRep(){
        PageReference pdfPage = Page.DailySummaryReport_Pdf;
        pdfPage.getParameters().put('id',dailySiteJobSummary.Id);
        pdfPage.getParameters().put('reportApproved','true');
        Blob pdfBody = Test.isRunningTest() ? Blob.valueOf('TestPdf') : pdfPage.getContentAsPDF();

        Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();
        emailFileAttachment.body = pdfBody;
        emailFileAttachment.fileName = 'DSJS Report ' + dailySiteJobSummary.Name + ' - ' + dailySiteJobSummary.Summary_Report_Date__c.day() + '-' + dailySiteJobSummary.Summary_Report_Date__c.month() + '-' + dailySiteJobSummary.Summary_Report_Date__c.year() + '.pdf';
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<EmailTemplate> emailTemplateList = [Select Id from EmailTemplate where DeveloperName = 'DSJS_Approved_With_Attachment'];
        if(!emailTemplateList.isEmpty()){
            email.setTemplateId(emailTemplateList[0].Id);
            email.setTargetObjectId(dailySiteJobSummary.Contract__r.Company_Manager__c);
            email.setWhatId(dailySiteJobSummary.Id);
            email.setSaveAsActivity(true);
            email.setOrgWideEmailAddressId('0D29000000000o6'); // sole Org Wide email
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{emailFileAttachment});
            emailList.add(email);
        }
        if(!emailList.isEmpty()){
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList);
        }


    }

    public void sendEmailToRigManager(String emailTemplateName){
        try{
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            Id emailTemplateId = [Select Id from EmailTemplate where DeveloperName = :emailTemplateName].Id;
            email = Messaging.renderStoredEmailTemplate(emailTemplateId,dailySiteJobSummary.Rig_Manager__c,dailySiteJobSummary.Id);
            email.setSubject(email.getSubject());
            email.setHtmlBody(email.getHtmlBody());
            email.setSaveAsActivity(true);
            email.setTargetObjectId(dailySiteJobSummary.Rig_Manager__c);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: ' + e.getMessage()));
        }
    }
    
    public void sendEmailToOpsSupervisor(String emailTemplateName){
        try{
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            Id emailTemplateId = [Select Id from EmailTemplate where DeveloperName = :emailTemplateName].Id;
            email = Messaging.renderStoredEmailTemplate(emailTemplateId,dailySiteJobSummary.Ops_Supervisor__c,dailySiteJobSummary.Id);
            email.setSubject(email.getSubject());
            email.setHtmlBody(email.getHtmlBody());
            email.setSaveAsActivity(true);
            email.setTargetObjectId(dailySiteJobSummary.Ops_Supervisor__c);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: ' + e.getMessage()));
        }
    }
    
    public PageReference rejectSingleDailySiteJob(){
        Daily_Report__c dReport = new Daily_Report__c();//Id = dailySiteJobToRejectId);
        for (Daily_Report__c dr : dailyReportList){
            if (dr.Id == dailySiteJobToRejectId){
                dReport.Id = dr.Id;
                dReport.OpsSupervisorApprovalNotes__c = dr.OpsSupervisorApprovalNotes__c;
            }
        }
        //dReport.OpsSupervisorApprovalNotes__c = inputDailySiteJobRejectComments;
        dReport.Status__c = 'Rejected';
        dReport.OpsSupervisorRejected__c = true;
        try {
            update dReport;
        }
        catch (Exception e){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: ' + e.getMessage())); 
            return null;
        }
        PageReference pRef = Page.DailySiteJobSummary_VF;
        pRef.getParameters().put('id', dailySiteJobSummary.Id);
        pRef.setRedirect(true);
        return pRef;
    }
}