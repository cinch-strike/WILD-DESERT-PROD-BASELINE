/**************************************************************************
* @author        Kunal Jain
* @date         
* @description   This is a test class for DailySummaryReport_Controller 
***************************************************************************/
@isTest
public class DailySummaryReport_Controller_Test {
    
    static testMethod void testData(){
        
        TestDataFactory testData = new TestDataFactory();
        
        Item__c item = testData.createItemCampStandy();
        item.Name = 'Camp Fuel Daily Usage';
        item.Service_Type__c = 'Flexi Price/Quantity';
        insert item;
        
        Item__c item2 = item.clone(false);
        item2.Name = 'Camp 12hr Operating';
        item2.Service_Type__c = 'Fixed Price/Hour';
        insert item2;
        
        Account acc = testData.createAccount();
        insert acc;
        
        Contract__c cont = testData.createContract();
        cont.Account__c = acc.Id;
        insert cont;
        
        Site__c site = testData.createSite();
        site.Account__c = acc.Id;
        site.Contract__c = cont.Id;
        insert site;
        
        Daily_Summary_Report__c dailySummaryReport = new Daily_Summary_Report__c();
        dailySummaryReport.Summary_Report_Date__c = System.today();
        dailySummaryReport.Status__c = 'Open';
        dailySummaryReport.Site__c = site.Id;
        dailySummaryReport.Contract__c = cont.Id;
        insert dailySummaryReport;
        
        Unit__c rigUnit = testData.createRigUnit();
        rigUnit.Contract_New__c= cont.Id;
        rigUnit.Site__c = site.Id;
        rigUnit.LTI_Reset_Date__c = System.today() - 5;
        rigUnit.Unit_Manager__c = UserInfo.getUserId();
        insert rigUnit;
        
        Unit__c campUnit = testData.createCampUnit();
        campUnit.Contract_New__c = cont.Id;
        campUnit.LTI_Reset_Date__c = System.today() - 5;
        campUnit.Site__c = site.Id;
        insert campUnit;
        
        Position__c position = new Position__c();
        position.Name = 'Leasehand';
        insert position;
        
        Contract_Item__c contractItem = testData.createContractJobItem();
        contractItem.Contract__c = cont.Id;
        contractItem.Item_Name__c = item.Id;
        contractItem.Add_to_NDT__c = true;
        contractItem.Auto_Populate_in_Daily_Report__c  = true;
        contractItem.Group__c = null;
        insert contractItem;
        
        Contract_Item__c contractItem2 = testData.createContractJobItem();
        contractItem2.Contract__c = cont.Id;
        contractItem2.Item_Name__c = item2.Id;
        contractItem2.Add_to_NDT__c = true;
        contractItem2.Auto_Populate_in_Daily_Report__c = true;
        contractItem2.Group__c = null;
        insert contractItem2;
        
        Employees__c employee = testData.createEmployee();
        employee.Assigned_to_Unit__c = campUnit.Id;
        employee.PositionLookup__c = position.Id;
        employee.Mobile__c = '61429786541';
        insert employee;
        
        Employees__c employee2;
        employee2 = employee.clone(false,false);
        insert employee2;    
        
        Daily_Report__c dailyReportRig = testData.createRigDailyReport();
        dailyReportRig.Contract__c = cont.Id;
        dailyReportRig.Site__c = site.Id;
        dailyReportRig.Unit__c = rigUnit.Id;
        dailyReportRig.Daily_Summary_Report__c = dailySummaryReport.Id;
        insert dailyReportRig;
        
        Daily_Report__c dailyReportCamp = testData.createCampDailyReport();
        dailyReportCamp.Contract__c = cont.Id;
        dailyReportCamp.Site__c = site.Id;
        dailyReportCamp.Unit__c = campUnit.Id;
        dailyReportCamp.Auto_Create_Daily_Report_Items__c = true;
        dailyReportCamp.Weather__c = 'Awesome';
        dailyReportCamp.Daily_Summary_Report__c = dailySummaryReport.Id;
        insert dailyReportCamp;
        
        Hazard_Card__c hazardCard = testData.createHazardCard();
        hazardCard.Unit__c = campUnit.Id;
        hazardCard.Reported_By__c = employee2.Id;
        hazardCard.Unit_Manager__c = employee2.Id;
        hazardCard.Site__c = site.Id;
        hazardCard.Daily_Site_Job__c = dailyReportCamp.Id;
        insert hazardCard;
        
        Hazard_Card__c hazardCard2 = hazardCard.clone(false);
        insert hazardCard2;            
        
        HSEQ_Forms__c hseqForm = testData.createHseqForm();
        hseqForm.Unit__c = campUnit.Id;
        hseqForm.Inducted_By__c = employee2.Id;
        hseqForm.Site__c = site.Id;
        hseqForm.Daily_Site_Job__c = dailyReportCamp.Id;
        insert hseqForm;
        
        HSEQ_Forms__c hseqForm2 = hseqForm.clone(false);
        insert hseqForm2;       
        
        List<Daily_Report_Item__c> dailyReportItemInList = new List<Daily_Report_Item__c>();
        Daily_Report_Item__c dailyReportItem1 = new Daily_Report_Item__c();
        dailyReportItem1.Contract_Job_Item__c = contractItem.Id;
        dailyReportItem1.Daily_Report__c = dailyReportCamp.Id;
        dailyReportItem1.Quantity__c = 100;
        dailyReportItemInList.add(dailyReportItem1);
        
        Daily_Report_Item__c dailyReportItem2 = new Daily_Report_Item__c();
        dailyReportItem2.Contract_Job_Item__c = contractItem2.Id;
        dailyReportItem2.Daily_Report__c = dailyReportCamp.Id;
        dailyReportItem2.Start_Time__c = System.now().addHours(-1);
        dailyReportItem2.End_Time__c = System.now().addHours(1);
        dailyReportItemInList.add(dailyReportItem2);
        
        Test.startTest();
        insert dailyReportItemInList;
        system.debug('dailyReportItemInList: ' + dailyReportItemInList);
        List<Daily_Report_Item__c> dailyReportItemList = [Select Id,Daily_Report__c,Contract_Job_Item__c,Quantity__c,Start_Time__c,End_Time__c from Daily_Report_Item__c
                                                          where Contract_Job_Item__c = :contractItem.Id and Id != :dailyReportItemInList[0].Id];
        if(!dailyReportItemList.isEmpty()){
            dailyReportItemList[0].Quantity__c = 5;
            update dailyReportItemList[0];
        }
        
        
        List<Daily_Report_Item__c> dailyReportItemList1 = [Select Id,Daily_Report__c,Contract_Job_Item__c,Quantity__c,Start_Time__c,End_Time__c from Daily_Report_Item__c
                                                           where Contract_Job_Item__c = :contractItem2.Id and Id != :dailyReportItemInList[1].Id];
        if(!dailyReportItemList1.isEmpty()){
            dailyReportItemList1[0].Start_Time__c = System.now().addHours(-2);
            dailyReportItemList1[0].End_Time__c = System.now().addHours(2);
            update dailyReportItemList1[0];
        }     
        
        List<Daily_Summary_Report__c> relatedDailySummaryReport = [Select Id,Status__c from Daily_Summary_Report__c where Summary_Report_Date__c = today];
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(relatedDailySummaryReport[0]);
        DailySummaryReport_Controller dsrc = new DailySummaryReport_Controller(sc);
        Test.stopTest();
        
        system.assertEquals(2, dsrc.hazardCount);
        system.assertEquals(1, dsrc.siteWrapperMap.keyset().size());        
        
    }
    
}