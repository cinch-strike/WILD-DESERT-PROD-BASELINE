/******************************************************************************
* @author        Kunal Jain
* @date         
* @description   This is a test class for DailyReportItemTrigger_Handler
******************************************************************************/
@isTest
public class DailyReportItemTrigger_Test {
    
    static testMethod void testMethod1(){
        
        
        TestDataFactory testData = new TestDataFactory();
        
        List<Item__c> itemInsertList = new List<Item__c>();
        Item__c item = testData.createItemCampStandy();
        itemInsertList.add(item);
        
        Item__c item2 = testData.createItemRigOperating();
        itemInsertList.add(item2);
        
        Item__c item3 = item2.clone(false);
        itemInsertList.add(item3);
        
        insert itemInsertList;
        
        Account acc = testData.createAccount();
        acc.Regions_LG_Area__c = 'VIC';
        insert acc;
        
        Contract__c cont = testData.createContract();
        cont.Account__c = acc.Id;
        insert cont;
        
        List<Contract_Item__c> contractItemList = new List<Contract_Item__c>();
        Contract_Item__c contractItem = testData.createContractJobItem();
        contractItem.Contract__c = cont.Id;
        contractItem.Item_Name__c = item.Id;
        contractItem.Add_to_NDT__c = true;
        contractItemList.add(contractItem);
        
        Contract_Item__c contractItem2 = testData.createContractJobItem();
        contractItem2.Unit_Type__c = 'Rig';
        contractItem2.Contract__c = cont.Id;
        contractItem2.Item_Name__c = item2.Id;
        contractItem2.Add_to_NDT__c = true;
        contractItemList.add(contractItem2);
        
        Contract_Item__c contractItem3 = contractItem2.clone(false);
        contractItemList.add(contractItem3);
        
        insert contractItemList;
        
        List<Unit__c> unitInsertList = new List<Unit__c>();
        Unit__c rigUnit = testData.createRigUnit();
        rigUnit.Contract_New__c = cont.Id;
        rigUnit.LTI_Reset_Date__c = System.today() - 5;
        unitInsertList.add(rigUnit);
        
        Unit__c campUnit = testData.createCampUnit();
        campUnit.Contract_New__c = cont.Id;
        campUnit.LTI_Reset_Date__c = System.today() - 5;
        unitInsertList.add(campUnit);
        
        insert unitInsertList;
        
        List<Site__c> siteInsertList = new List<Site__c>();
        Site__c site1 = testData.createSite();
        site1.Account__c = acc.Id;
        site1.Contract__c = cont.Id;
        site1.Site_Active__c = true;
        siteInsertList.add(site1);
        
        Site__c site2 = testData.createSite();
        site2.Name = 'Test Site 2';
        site2.Account__c = acc.Id;
        site2.Contract__c = cont.Id;
        site2.Site_Active__c = true;
        siteInsertList.add(site2);
        
        insert siteInsertList;
        
        Daily_Report__c dailyReportRig = testData.createRigDailyReport();
        dailyReportRig.Contract__c = cont.Id;
        dailyReportRig.Site__c = site1.Id;
        dailyReportRig.Unit__c = rigUnit.Id;
        insert dailyReportRig;
        
        List<Daily_Report_Item__c> reportItemInsertList = new List<Daily_Report_Item__c>();
        Daily_Report_Item__c dailyReportItem = new Daily_Report_Item__c();
        dailyReportItem.Daily_Report__c = dailyReportRig.Id;
        dailyReportItem.Start_Time__c = System.now().addHours(-1);
        dailyReportItem.End_Time__c = System.now().addHours(1);
        dailyReportItem.Contract_Job_Item__c = contractItem2.Id;
        reportItemInsertList.add(dailyReportItem);
        
        Daily_Report_Item__c dailyReportItem3 = dailyReportItem.clone(false);
        dailyReportItem.Contract_Job_Item__c = contractItem3.Id;
        reportItemInsertList.add(dailyReportItem3);
        
        insert reportItemInsertList;
        
        delete dailyReportItem3;
        
        List<Daily_Report__c> reportInsertList = new List<Daily_Report__c>();
        Daily_Report__c dailyReportCamp = testData.createCampDailyReport();
        dailyReportCamp.Contract__c = cont.Id;
        dailyReportCamp.Site__c = site1.Id;
        dailyReportCamp.Unit__c = campUnit.Id;
        reportInsertList.add(dailyReportCamp);
        
        Daily_Report__c dailyReportCamp2 = testData.createCampDailyReport();
        dailyReportCamp2.Contract__c = cont.Id;
        dailyReportCamp2.Site__c = site2.Id;
        dailyReportCamp2.Unit__c = campUnit.Id;
        reportInsertList.add(dailyReportCamp2);
        
        insert reportInsertList;
        
        Daily_Report_Item__c dailyReportItem2 = new Daily_Report_Item__c();
        dailyReportItem2.Daily_Report__c = dailyReportCamp2.Id;
        dailyReportItem2.Quantity__c = 6.0;
        dailyReportItem2.Contract_Job_Item__c = contractItem.Id;
        insert dailyReportItem2;
        
    }
}