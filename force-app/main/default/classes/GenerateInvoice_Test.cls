@isTest
public class GenerateInvoice_Test {
    
    static testMethod void testMeth1(){
        
        TestDataFactory testData = new TestDataFactory();
        
        Item__c item1 = testData.createItemRigOperating();
        insert item1;
        
        Item__c item2 = testData.createItemRigOperating();
        item2.Name = 'Rig Parts';
        item2.Service_Type__c = 'Fixed Price/Quantity';
        insert item2;
        
        Account acc = testData.createAccount();
        insert acc;
        
        Contract__c cont = testData.createContract();
        cont.Account__c = acc.Id;
        insert cont;
        
        String resultInitial = GenerateInvoice.generateInvoiceRecord(cont.Id,null);
        system.debug('resultInitial: ' + resultInitial);
        
        Site__c site = testData.createSite();
        site.Account__c = acc.Id;
        site.Contract__c = cont.Id;
        insert site;
        
        Unit__c rigUnit = testData.createRigUnit();
        rigUnit.Contract_New__c = cont.Id;
        rigUnit.LTI_Reset_Date__c = System.today() - 5;
        insert rigUnit;
        
        Contract_Item__c contractItem1 = testData.createContractJobItem();
        contractItem1.Unit_Type__c = 'Rig';
        contractItem1.Contract__c = cont.Id;
        contractItem1.Item_Name__c = item1.Id;
        contractItem1.Add_to_NDT__c = true;
        contractItem1.Auto_Populate_in_Daily_Report__c = true;
        insert contractItem1;
        
        Contract_Item__c contractItem2 = testData.createContractJobItem();
        contractItem2.Unit_Type__c = 'Rig';
        contractItem2.Contract__c = cont.Id;
        contractItem2.Item_Name__c = item2.Id;
        contractItem2.Add_to_NDT__c = true;
        contractItem2.Auto_Populate_in_Daily_Report__c = true;
        insert contractItem2;
        
        Daily_Report__c dailyReportRig = testData.createRigDailyReport();
        dailyReportRig.Contract__c = cont.Id;
        dailyReportRig.Site__c = site.Id;
        dailyReportRig.Unit__c = rigUnit.Id;
        dailyReportRig.Auto_Create_Daily_Report_Items__c = false;
        dailyReportRig.Line_on_Spool__c = 1;
        dailyReportRig.Line_Slipped__c = 1;
        dailyReportRig.No_of_KM_s_from_Previous_Site__c = 1;
        dailyReportRig.Weather__c = 'Cool';
        insert dailyReportRig;
        
        List<Daily_Summary_Report__c> relatedDailySummaryReport = [Select Id,Status__c from Daily_Summary_Report__c where Summary_Report_Date__c = today];
        if(relatedDailySummaryReport.isEmpty()){
            Daily_Summary_Report__c dsr = new Daily_Summary_Report__c();
            dsr.Summary_Report_Date__c = System.today();
            dsr.Status__c = 'Open';
            dsr.Contract__c = cont.Id;
            dsr.Site__c = site.Id;
            insert dsr;
            relatedDailySummaryReport.add(dsr);
        }
        
        
        String result2 = GenerateInvoice.generateInvoiceRecord(cont.Id,site.Id);
        system.debug('result2: ' + result2);
        
        dailyReportRig.Status__c = 'Ops - Approved';
        update dailyReportRig;
        relatedDailySummaryReport[0].Status__c = 'Approved';
        update relatedDailySummaryReport[0];
        
        
        String result3 = GenerateInvoice.generateInvoiceRecord(cont.Id, site.Id);
        system.debug('result3: ' + result3);
        
        Id perHourRecordTypeId = [Select Id From RecordType Where SObjectType = 'Daily_Report_Item__c' And DeveloperName='Per_Hour'].Id;
        Id perQuantityRecordTypeId = [Select Id From RecordType Where SObjectType = 'Daily_Report_Item__c' And DeveloperName='Per_Quantity'].Id;
        
        Daily_Report_Item__c dailyReportItem1 = new Daily_Report_Item__c();
        dailyReportItem1.RecordTypeId = perHourRecordTypeId;
        dailyReportItem1.Daily_Report__c = dailyReportRig.Id;
        dailyReportItem1.Start_Time__c = System.now().addHours(-1);
        dailyReportItem1.End_Time__c = System.now().addHours(1);
        dailyReportItem1.Contract_Job_Item__c = contractItem1.Id;
        insert dailyReportItem1;
        
        Daily_Report_Item__c dailyReportItem2 = new Daily_Report_Item__c();
        dailyReportItem2.Daily_Report__c = dailyReportRig.Id;
        dailyReportItem2.Contract_Job_Item__c = contractItem2.Id;
        dailyReportItem2.RecordTypeId = perQuantityRecordTypeId;
        dailyReportItem2.Quantity__c = 5;
        insert dailyReportItem2;
        
        Daily_Report_Item__c dailyReportItem3 = new Daily_Report_Item__c();
        dailyReportItem3.RecordTypeId = perHourRecordTypeId;
        dailyReportItem3.Daily_Report__c = dailyReportRig.Id;
        dailyReportItem3.Start_Time__c = System.now().addHours(-1);
        dailyReportItem3.End_Time__c = System.now().addHours(1);
        dailyReportItem3.Contract_Job_Item__c = contractItem1.Id;
        insert dailyReportItem3;
        
        Daily_Report_Item__c dailyReportItem4 = new Daily_Report_Item__c();
        dailyReportItem4.Daily_Report__c = dailyReportRig.Id;
        dailyReportItem4.Contract_Job_Item__c = contractItem2.Id;
        dailyReportItem4.RecordTypeId = perQuantityRecordTypeId;
        dailyReportItem4.Quantity__c = 5;
        insert dailyReportItem4;
        
        dailyReportRig.Status__c = 'Approved';
        update dailyReportRig;
        
        Test.startTest();
        String result = GenerateInvoice.generateInvoiceRecord(cont.Id, site.Id);  
        system.debug('result: ' + result);
        Test.stopTest();
        //List<Invoice__c> invoiceList = [Select Id,Site__c,Contract__c from Invoice__c where Site__c= :site.Id AND Contract__c= :cont.Id];
        //System.assertEquals(true,!invoiceList.isEmpty());
        
        //List<Invoice_Line_Item__c> invoiceLineItemList = [Select Id,Name from Invoice_Line_Item__c where Invoice__c= :invoiceList[0].Id];
        //System.assertEquals(2, invoiceLineItemList.size());        
    }
    
}