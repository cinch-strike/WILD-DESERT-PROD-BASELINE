/**************************************************************************
* @author        Kunal Jain
* @date         
* @description   This is a test class for DailySiteJobStandard_Controller 
***************************************************************************/
@isTest
public class DailySiteJobStandard_Controller_Test {
    
    static testMethod void testMethod1(){
        
        TestDataFactory testData = new TestDataFactory();
        List<Item__c> itemList = new List<Item__c>();
        
        Test.startTest();        
        
        Item__c item1 = testData.createItemRigOperating();
        item1.Service_Type__c = 'Fixed Price/Hour';
        itemList.add(item1);
        
        insert itemList;
        
        Account acc = testData.createAccount();
        insert acc;
        
        Contract__c cont = testData.createContract();
        cont.Account__c = acc.Id;
        insert cont;
        
        Site__c site = testData.createSite();
        site.Account__c = acc.Id;
        site.Contract__c = cont.Id;
        insert site;
        
        Unit__c rigUnit = testData.createRigUnit();
        rigUnit.Contract_New__c= cont.Id;
        rigUnit.Site__c = site.Id;
        rigUnit.LTI_Reset_Date__c = System.today() - 5;
        rigUnit.Unit_Manager__c = UserInfo.getUserId();
        insert rigUnit;
        
        List<Contract_Item__c> contractItemList = new List<Contract_Item__c>();
        
        Contract_Item__c contractItem1 = testData.createContractJobItem();
        contractItem1.Unit_Type__c = 'Rig';
        contractItem1.Contract__c = cont.Id;
        contractItem1.Item_Name__c = item1.Id;
        contractItem1.Add_to_NDT__c = true;
        contractItem1.Auto_Populate_in_Daily_Report__c = true;
        contractItem1.Service_Type__c = 'Fixed Price/Hour';
        contractItemList.add(contractItem1);
        
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
        
        PageReference pgRef = Page.DailySiteJobStandard_VF;
        Test.setCurrentPage(pgRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(dailyReportRig);
        DailySiteJobStandard_Controller dailySiteJobStandard = new DailySiteJobStandard_Controller(sc);
        dailySiteJobStandard.init();
        
        PageReference pgRef2 = Page.DailySiteJobStandard_VF;
        Test.setCurrentPage(pgRef2);
        ApexPages.currentPage().getParameters().put('contractId',cont.Id);
        ApexPages.currentPage().getParameters().put('siteId',site.Id);
        ApexPages.currentPage().getParameters().put('rigUnit',rigUnit.Id);
        ApexPages.currentPage().getParameters().put('unitType','Rig');
        ApexPages.currentPage().getParameters().put('retURL',cont.Id);
        Daily_Report__c dailyReportRig2 = testData.createRigDailyReport();
        ApexPages.StandardController sc2 = new ApexPages.StandardController(dailyReportRig2);
        DailySiteJobStandard_Controller dailySiteJobStandard2 = new DailySiteJobStandard_Controller(sc2);
        dailySiteJobStandard2.init();
    }

}