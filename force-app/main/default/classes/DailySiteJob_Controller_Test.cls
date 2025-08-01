@isTest
public class DailySiteJob_Controller_Test {
    
    
    static testMethod void testMethod1(){
        
        TestDataFactory testData = new TestDataFactory();
        List<Item__c> itemList = new List<Item__c>();
        
        Test.startTest();
        
        Item__c item1 = testData.createItemRigOperating();
        item1.Service_Type__c = 'Fixed Price/Hour';
        itemList.add(item1);
        
        Item__c item2 = testData.createItemRigOperating();
        item2.Name = 'Rig Parts';
        item2.Service_Type__c = 'Fixed Price/Quantity';
        itemList.add(item2);
        
        insert itemList;
        
        Position__c position = new Position__c();
        position.Name = 'Leasehand';
        insert position;
        
        Account acc = testData.createAccount();
        acc.Regions_LG_Area__c = 'Maranoa';
        insert acc;
        
        Contract__c cont = testData.createContract();
        cont.Account__c = acc.Id;
        insert cont;
        
        Site__c site = testData.createSite();
        site.Account__c = acc.Id;
        site.Contract__c = cont.Id;
        insert site;
        
        Unit__c rigUnit = testData.createRigUnit();
        rigUnit.Contract_New__c = cont.Id;
        rigUnit.Site__c = site.Id;
        rigUnit.LTI_Reset_Date__c = System.today() - 5;
        rigUnit.Unit_Manager__c = UserInfo.getUserId();
        insert rigUnit;
        
        Employees__c employee = testData.createEmployee();
        employee.Assigned_to_Unit__c = rigUnit.Id;
        employee.PositionLookup__c = position.Id;
        employee.Mobile__c = '61429786541';
        insert employee;
        
        List<Contract_Item__c> contractItemList = new List<Contract_Item__c>();
        
        Contract_Item__c contractItem1 = testData.createContractJobItem();
        contractItem1.Unit_Type__c = 'Rig';
        contractItem1.Contract__c = cont.Id;
        contractItem1.Item_Name__c = item1.Id;
        contractItem1.Add_to_NDT__c = true;
        contractItem1.Auto_Populate_in_Daily_Report__c = true;
        contractItem1.Service_Type__c = 'Fixed Price/Hour';
        contractItemList.add(contractItem1);
        
        Contract_Item__c contractItem2 = testData.createContractJobItem();
        contractItem2.Unit_Type__c = 'Rig';
        contractItem2.Contract__c = cont.Id;
        contractItem2.Item_Name__c = item2.Id;
        contractItem2.Add_to_NDT__c = true;
        contractItem2.Auto_Populate_in_Daily_Report__c = true;
        ContractItem2.Service_Type__c = 'Fixed Price/Quantity';
        contractItemList.add(contractItem2);
        
        insert contractItemList;
        
        Daily_Report__c dailyReportRig = testData.createRigDailyReport();
        dailyReportRig.Contract__c = cont.Id;
        dailyReportRig.Site__c = site.Id;
        dailyReportRig.Unit__c = rigUnit.Id;
        dailyReportRig.Auto_Create_Daily_Report_Items__c = true;
        dailyReportRig.Line_on_Spool__c = 1;
        dailyReportRig.Line_Slipped__c = 1;
        dailyReportRig.No_of_KM_s_from_Previous_Site__c = 1;
        dailyReportRig.Weather__c = 'Cool';
        dailyReportRig.Status__c = 'Open';
        insert dailyReportRig;
        
        Active_Personnel__c ap = new Active_Personnel__c();
        ap.Daily_Report__c = dailyReportRig.Id;
        ap.Position__c = position.Id;
        ap.Employees__c = employee.Id;
        insert ap;
        
        /*DailySiteJob_Controller dailySiteJob2 = new DailySiteJob_Controller();
        dailySiteJob2.saveReport = true;
        dailySiteJob2.dailyReport.Report_Date__c = null;
        dailySiteJob2.SaveandNext();
        dailySiteJob2.dailyReport.Report_Date__c = System.today() - 1;
        dailySiteJob2.getNewHazardUrl();
        dailySiteJob2.getNewHseqUrl();
        dailySiteJob2.getNewWorkOrderUrl();
        dailySiteJob2.saveSiteJob();
        dailySiteJob2.dailyReport.Report_Date__c = null;
        dailySiteJob2.saveSiteJob();*/
        
        
        PageReference pageRef = Page.DailySiteJob_VF;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('siteJobId',dailyReportRig.Id);
        ApexPages.currentPage().getParameters().put('tabView','1');
        ApexPages.currentPage().getParameters().put('retUrl','www.google.com');
        ApexPages.currentPage().getParameters().put('siteId',site.Id);
        ApexPages.currentPage().getParameters().put('contractId',cont.Id);
        ApexPages.currentPage().getParameters().put('unitId',rigUnit.Id);
        ApexPages.currentPage().getParameters().put('unitType',dailyReportRig.Type__c);
        
        DailySiteJob_Controller dailySiteJob = new DailySiteJob_Controller();
        dailySiteJob.saveReport = true;
        dailySiteJob.saveSiteJob();
        ApexPages.currentPage().getParameters().put('tabView','3');
        dailySiteJob.saveSiteJob();
        ApexPages.currentPage().getParameters().put('tabView','4');
        dailySiteJob.saveSiteJob();
        dailySiteJob.saveReport = false;
        dailySiteJob.SaveandNext();
        dailySiteJob.SaveandClose();
        dailySiteJob.SaveandSubmit();
        dailySiteJob.closeSiteJob();
        dailySiteJob.dailyReportJobId = null;
        dailySiteJob.closeSiteJob();
        dailySiteJob.showCancelModal();
        dailySiteJob.getNewHazardUrl();
        dailySiteJob.getNewHseqUrl();
        dailySiteJob.getNewWorkOrderUrl();
        dailySiteJob.dailyReport.Status__c = 'Ops - Approved';
        dailySiteJob.showCancelModal();
        dailySiteJob.approveDailySiteJob();
        dailySiteJob.rejectDailySiteJob();
        dailySiteJob.nextTab = 1;
        dailySiteJob.source = 'Test';
        dailySiteJob.hasError = true;
        dailySiteJob.showCancelPopup = true;
        dailySiteJob.newHazardUrl = 'www.url.com';
        dailySiteJob.newHseqUrl  = 'www.url.com';
        dailySiteJob.newWorkOrderUrl  = 'www.url.com';
        
        Boolean isApprovalStatusPending = dailySiteJob.isApprovalStatusPending;
        Boolean approvalEnabled = dailySiteJob.approvalEnabled;
        Boolean isReportDateEditable = dailySiteJob.isReportDateEditable;
        
        dailySiteJob.deleteSelectedActivePersonnel();
        ApexPages.currentPage().getParameters().put('personnelId',ap.Id);
        dailySiteJob.deleteSelectedActivePersonnel();
        
        Test.stopTest();
    }
    
    static testMethod void testMethod2(){
        
        TestDataFactory testData = new TestDataFactory();
        List<Item__c> itemList = new List<Item__c>();
        
        Test.startTest();
        
        Item__c item1 = testData.createItemRigOperating();
        item1.Service_Type__c = 'Fixed Price/Hour';
        itemList.add(item1);
        
        Item__c item2 = testData.createItemRigOperating();
        item2.Name = 'Rig Parts';
        item2.Service_Type__c = 'Fixed Price/Quantity';
        itemList.add(item2);
        
        insert itemList;
        
        Position__c position = new Position__c();
        position.Name = 'Leasehand';
        insert position;
        
        Account acc = testData.createAccount();
        acc.Regions_LG_Area__c = 'Maranoa';
        insert acc;
        
        Contract__c cont = testData.createContract();
        cont.Account__c = acc.Id;
        insert cont;
        
        Site__c site = testData.createSite();
        site.Account__c = acc.Id;
        site.Contract__c = cont.Id;
        insert site;
        
        Unit__c rigUnit = testData.createRigUnit();
        rigUnit.Contract_New__c = cont.Id;
        rigUnit.Site__c = site.Id;
        rigUnit.LTI_Reset_Date__c = System.today() - 5;
        rigUnit.Unit_Manager__c = UserInfo.getUserId();
        insert rigUnit;
        
        Employees__c employee = testData.createEmployee();
        employee.Assigned_to_Unit__c = rigUnit.Id;
        employee.PositionLookup__c = position.Id;
        employee.Mobile__c = '61429786541';
        insert employee;
        
        List<Contract_Item__c> contractItemList = new List<Contract_Item__c>();
        
        Contract_Item__c contractItem1 = testData.createContractJobItem();
        contractItem1.Unit_Type__c = 'Rig';
        contractItem1.Contract__c = cont.Id;
        contractItem1.Item_Name__c = item1.Id;
        contractItem1.Add_to_NDT__c = true;
        contractItem1.Auto_Populate_in_Daily_Report__c = true;
        contractItem1.Service_Type__c = 'Fixed Price/Hour';
        contractItemList.add(contractItem1);
        
        Contract_Item__c contractItem2 = testData.createContractJobItem();
        contractItem2.Unit_Type__c = 'Rig';
        contractItem2.Contract__c = cont.Id;
        contractItem2.Item_Name__c = item2.Id;
        contractItem2.Add_to_NDT__c = true;
        contractItem2.Auto_Populate_in_Daily_Report__c = true;
        ContractItem2.Service_Type__c = 'Fixed Price/Quantity';
        contractItemList.add(contractItem2);
        
        insert contractItemList;
        
        Daily_Report__c dailyReportRig = testData.createRigDailyReport();
        dailyReportRig.Contract__c = cont.Id;
        dailyReportRig.Site__c = site.Id;
        dailyReportRig.Unit__c = rigUnit.Id;
        dailyReportRig.Auto_Create_Daily_Report_Items__c = true;
        dailyReportRig.Line_on_Spool__c = 1;
        dailyReportRig.Line_Slipped__c = 1;
        dailyReportRig.No_of_KM_s_from_Previous_Site__c = 1;
        dailyReportRig.Weather__c = 'Cool';
        dailyReportRig.Status__c = 'Open';
        insert dailyReportRig;
        
        Active_Personnel__c ap = new Active_Personnel__c();
        ap.Daily_Report__c = dailyReportRig.Id;
        ap.Position__c = position.Id;
        ap.Employees__c = employee.Id;
        insert ap;
        
        PageReference pageRef = Page.DailySiteJob_VF;
        Test.setCurrentPageReference(pageRef);
        //ApexPages.currentPage().getParameters().put('siteJobId','none');
        ApexPages.currentPage().getParameters().put('tabView','1');
        ApexPages.currentPage().getParameters().put('retUrl','www.google.com');
        ApexPages.currentPage().getParameters().put('siteId',site.Id);
        ApexPages.currentPage().getParameters().put('contractId',cont.Id);
        ApexPages.currentPage().getParameters().put('unitId',rigUnit.Id);
        ApexPages.currentPage().getParameters().put('unitType',dailyReportRig.Type__c);
        
        DailySiteJob_Controller dailySiteJob = new DailySiteJob_Controller();
        dailySiteJob.saveReport = true;
        dailySiteJob.saveSiteJob();
        ApexPages.currentPage().getParameters().put('tabView','3');
        dailySiteJob.saveSiteJob();
        ApexPages.currentPage().getParameters().put('tabView','4');
        dailySiteJob.saveSiteJob();
        dailySiteJob.saveReport = false;
        dailySiteJob.SaveandNext();
        dailySiteJob.SaveandClose();
        dailySiteJob.SaveandSubmit();
        dailySiteJob.closeSiteJob();
        dailySiteJob.dailyReportJobId = null;
        dailySiteJob.closeSiteJob();
        dailySiteJob.showCancelModal();
        dailySiteJob.getNewHazardUrl();
        dailySiteJob.getNewHseqUrl();
        dailySiteJob.getNewWorkOrderUrl();
        dailySiteJob.dailyReport.Status__c = 'Ops - Approved';
        dailySiteJob.showCancelModal();
        
        dailySiteJob.deleteSelectedActivePersonnel();
        ApexPages.currentPage().getParameters().put('personnelId',ap.Id);
        dailySiteJob.deleteSelectedActivePersonnel();
        
        Test.stopTest();
    }
}