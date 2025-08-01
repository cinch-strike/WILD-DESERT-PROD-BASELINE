@isTest
public class InvocableGenerateInvoiceTest {
    
    static testMethod void testMeth1(){
        
        TestDataFactory testData = new TestDataFactory();
        
        Item__c item1 = testData.createItemRigOperating();
        insert item1;
        
        Item__c item2 = testData.createItemRigOperating();
        item2.Name = 'Rig Parts';
        item2.Service_Type__c = 'Fixed Price/Quantity';
        insert item2;
        
        Account acc = testData.createAccount();
        acc.Regions_LG_Area__c='NSW';
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
      
        List<InvocableGenerateInvoice.InputVariables> InvVeriables = new List<InvocableGenerateInvoice.InputVariables>();
        InvocableGenerateInvoice.InputVariables igv = new InvocableGenerateInvoice.InputVariables();
       
        igv.contId = cont.Id;
        igv.siteId = site.id;
        InvocableGenerateInvoice.InputVariables igv1 = new InvocableGenerateInvoice.InputVariables();
       
        igv1.contId = null;
        igv1.siteId = site.id;
        InvVeriables.add(igv);
        InvVeriables.add(igv1);
        
        
       
               
        Test.startTest();
     InvocableGenerateInvoice.genInv(InvVeriables);
      
        Test.stopTest();
        //List<Invoice__c> invoiceList = [Select Id,Site__c,Contract__c from Invoice__c where Site__c= :site.Id AND Contract__c= :cont.Id];
        //System.assertEquals(true,!invoiceList.isEmpty());
        
        //List<Invoice_Line_Item__c> invoiceLineItemList = [Select Id,Name from Invoice_Line_Item__c where Invoice__c= :invoiceList[0].Id];
        //System.assertEquals(2, invoiceLineItemList.size());        
    }
    
}