/**
* Created by Captain America on 18-Jan-18.
*/
@isTest
public with sharing class DailySiteJobSummary_Controller_Test {
    
    static testMethod void testMethod1(){
        
        PageReference pgRef = Page.DailySiteJobSummary_VF;
        pgRef.getParameters().put('userTypeGuest','true');
        Test.setCurrentPage(pgRef);
        
        TestDataFactory testData = new TestDataFactory();
        
        Test.startTest();
        
        Position__c position = new Position__c();
        position.Name = 'Leasehand';
        insert position;
        
        Account acc = testData.createAccount();
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'FName';
        con.LastName = 'LName';
        con.AccountId = acc.Id;
        con.Email = 'test@email.com';
        insert con;
        
        Contract__c cont = testData.createContract();
        cont.Account__c = acc.Id;
        cont.Company_Manager__c = con.Id;
        insert cont;
        
        Site__c site = testData.createSite();
        site.Account__c = acc.Id;
        site.Contract__c = cont.Id;
        insert site;
        
        Unit__c campUnit = testData.createCampUnit();
        campUnit.Contract_New__c = cont.Id;
        campUnit.LTI_Reset_Date__c = System.today() - 5;
        campUnit.Site__c = site.Id;
        insert campUnit;
        
        Employees__c employee = testData.createEmployee();
        employee.Assigned_to_Unit__c = campUnit.Id;
        employee.PositionLookup__c = position.Id;
        employee.Mobile__c = '61429786541';
        insert employee;
                
        Daily_Summary_Report__c dailySummaryReport = new Daily_Summary_Report__c();
        dailySummaryReport.Contract__c = cont.Id;
        dailySummaryReport.Site__c = site.Id;
        dailySummaryReport.Summary_Report_Date__c = System.today();
        dailySummaryReport.Rig_Manager__c = UserInfo.getUserId();
        insert dailySummaryReport;
        
        Daily_Report__c dailyReportCamp = testData.createCampDailyReport();
        dailyReportCamp.Contract__c = cont.Id;
        dailyReportCamp.Site__c = site.Id;
        dailyReportCamp.Unit__c = campUnit.Id;
        dailyReportCamp.Status__c = 'Open';
        dailyReportCamp.Daily_Summary_Report__c = dailySummaryReport.Id;
        insert dailyReportCamp;
        
        Active_Personnel__c activePersonel = new Active_Personnel__c();
        activePersonel.Employees__c = employee.Id;
        activePersonel.Daily_Report__c = dailyReportCamp.Id;
        insert activePersonel;
        
        dailyReportCamp.Status__c = 'Ops - Approved';
        update dailyReportCamp;
        
        ApexPages.StandardController sc = new ApexPages.standardController(dailySummaryReport);
        DailySiteJobSummaryDetail_Controller dailySiteJobSummaryDetail = new DailySiteJobSummaryDetail_Controller(sc);
        dailySiteJobSummaryDetail.userTypeGuest = true;
        dailySiteJobSummaryDetail.showCancelModal();
        dailySiteJobSummaryDetail.sendEmailToCompanyMan();
        dailySiteJobSummaryDetail.approveReport();
        dailySiteJobSummaryDetail.rejectReport();
        Boolean x = DailySiteJobSummaryDetail.showDeleteButton;
               
        dailySiteJobSummaryDetail.createPdfOpenedTask();
        String taskSubject = 'OCR Opened the Daily Summary Report PDF';
        List<Task> taskList = [Select Id,Subject from Task where WhatId = :dailySummaryReport.Id AND Subject = :taskSubject];
        system.assertEquals(1, taskList.size());
        
        dailySiteJobSummaryDetail.createPdfOpenedTask();
        system.assertEquals(1, taskList.size());
        
        dailySiteJobSummaryDetail.hideApprovalModal();
        dailySiteJobSummaryDetail.rejectConfirmationModal();
        dailySiteJobSummaryDetail.renderOpsSupConfirmationModal();
        dailySiteJobSummaryDetail.sendRequestToOpsSupervisor();
        //dailySiteJobSummaryDetail.rejectSiteJobSummary();
        dailySiteJobSummaryDetail.rejectSingleDailySiteJob();
        Boolean hTransport = dailySiteJobSummaryDetail.hasOpenTransportJobs;
        
        DailySummaryReportAttachment.createDailySummaryReportAttachment(new List<Id>{dailySummaryReport.Id});
        
        Test.stopTest();
    }
}