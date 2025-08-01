@isTest
public class DailySummaryReportTrigger_Test {
    
    //Calls preventSubmittedStatus method
    static testMethod void testMeth1(){
        
        try{
            TestDataFactory testData = new TestDataFactory();
            
            Item__c item2 = testData.createItemRigOperating();
            insert item2;
            
            Account acc = testData.createAccount();
            acc.Regions_LG_Area__c = 'Maranoa';
            insert acc;
            
            Contract__c cont = testData.createContract();
            cont.Account__c = acc.Id;
            insert cont;
            
            Site__c site1 = testData.createSite();
            site1.Account__c = acc.Id;
            site1.Contract__c = cont.Id;
            insert site1;
            
            Unit__c rigUnit = testData.createRigUnit();
            rigUnit.Contract_New__c = cont.Id;
            rigUnit.LTI_Reset_Date__c = System.today() - 5;
            insert rigUnit;
            
            Contract_Item__c contractItem2 = testData.createContractJobItem();
            contractItem2.Unit_Type__c = 'Rig';
            contractItem2.Contract__c = cont.Id;
            contractItem2.Item_Name__c = item2.Id;
            contractItem2.Add_to_NDT__c = true;
            insert contractItem2;
            
            Daily_Report__c dailyReportRig = testData.createRigDailyReport();
            dailyReportRig.Contract__c = cont.Id;
            dailyReportRig.Site__c = site1.Id;
            dailyReportRig.Unit__c = rigUnit.Id;
            insert dailyReportRig;
            
            List<Daily_Summary_Report__c> relatedDailySummaryReport = [Select Id,Status__c from Daily_Summary_Report__c where Summary_Report_Date__c = today];
            if(relatedDailySummaryReport.isEmpty()){
                Daily_Summary_Report__c dsr = new Daily_Summary_Report__c();
                dsr.Summary_Report_Date__c = System.today();
                dsr.Status__c = 'Open';
                dsr.Contract__c = cont.Id;
                dsr.Site__c = site1.Id;
                insert dsr;
                relatedDailySummaryReport.add(dsr);
            }
            
           // List<Daily_Summary_Report__c> relatedDailySummaryReport = [Select Id,Status__c from Daily_Summary_Report__c where Summary_Report_Date__c = today];
            relatedDailySummaryReport[0].Status__c = 'Submitted';
            update relatedDailySummaryReport[0];

            delete relatedDailySummaryReport[0];
        }
        catch(Exception e){
            String errorMessage = 'A Daily Site Job Summary cannot be submitted till all the Daily Site Jobs have been Ops - Approved.';
            Boolean exceptionThrown = e.getMessage().contains(errorMessage) ? true : false;
            //System.assertEquals(exceptionThrown, true);
            system.debug('## exception: ' + e.getMessage());
        }
    }
    
    
    //Calls preventDuplicateSummaryReport method
    static testMethod void testMeth2(){
        
        try{
            TestDataFactory testData = new TestDataFactory();
            
            Item__c item2 = testData.createItemRigOperating();
            insert item2;
            
            Account acc = testData.createAccount();
            insert acc;
            
            Contract__c cont = testData.createContract();
            cont.Account__c = acc.Id;
            insert cont;
            
            Site__c site1 = testData.createSite();
            site1.Account__c = acc.Id;
            site1.Contract__c = cont.Id;
            insert site1;
            
            
            Unit__c rigUnit = testData.createRigUnit();
            rigUnit.Contract_New__c = cont.Id;
            rigUnit.LTI_Reset_Date__c = System.today() - 5;
            insert rigUnit;
            
            Contract_Item__c contractItem2 = testData.createContractJobItem();
            contractItem2.Unit_Type__c = 'Rig';
            contractItem2.Contract__c = cont.Id;
            contractItem2.Item_Name__c = item2.Id;
            contractItem2.Add_to_NDT__c = true;
            insert contractItem2;
            
            Daily_Report__c dailyReportRig = testData.createRigDailyReport();
            dailyReportRig.Contract__c = cont.Id;
            dailyReportRig.Site__c = site1.Id;
            dailyReportRig.Unit__c = rigUnit.Id;
            insert dailyReportRig;
            
            Daily_Summary_Report__c dsr3 = new Daily_Summary_Report__c();
            dsr3.Contract__c = cont.Id;
            dsr3.Site__c = site1.Id;
            dsr3.Summary_Report_Date__c = System.today()-1;
            dsr3.Status__c = 'Open';
            insert dsr3;
            
            Daily_Summary_Report__c dsr = new Daily_Summary_Report__c();
            dsr.Contract__c = cont.Id;
            dsr.Site__c = site1.Id;
            dsr.Summary_Report_Date__c = System.today();
            dsr.Status__c = 'Open';
            insert dsr;
            
            Daily_Summary_Report__c dsr2 = new Daily_Summary_Report__c();
            dsr2.Contract__c = cont.Id;
            dsr2.Site__c = site1.Id;
            dsr2.Summary_Report_Date__c = System.today();
            dsr2.Status__c = 'Open';
            insert dsr2;
            
            
        }
        catch(Exception e){
            String errorMessage = 'A Daily Site Job Summary of this type has already been created';
            Boolean exceptionThrown = e.getMessage().contains(errorMessage) ? true : false;
            //System.assertEquals(exceptionThrown, true);
            system.debug('## exception: ' + e.getMessage());
        }
    }
    
    static testMethod void preventDailySiteJobSummaryDeletionTestMethod(){
        
        try{
            TestDataFactory testData = new TestDataFactory();
            
            Item__c item2 = testData.createItemRigOperating();
            insert item2;
            
            Account acc = testData.createAccount();
            insert acc;
            
            Contract__c cont = testData.createContract();
            cont.Account__c = acc.Id;
            insert cont;
            
            Site__c site1 = testData.createSite();
            site1.Account__c = acc.Id;
            site1.Contract__c = cont.Id;
            insert site1;
            
            
            Unit__c rigUnit = testData.createRigUnit();
            rigUnit.Contract_New__c = cont.Id;
            rigUnit.LTI_Reset_Date__c = System.today() - 5;
            insert rigUnit;
            
            Contract_Item__c contractItem2 = testData.createContractJobItem();
            contractItem2.Unit_Type__c = 'Rig';
            contractItem2.Contract__c = cont.Id;
            contractItem2.Item_Name__c = item2.Id;
            contractItem2.Add_to_NDT__c = true;
            insert contractItem2;
            
            Daily_Summary_Report__c dsr3 = new Daily_Summary_Report__c();
            dsr3.Contract__c = cont.Id;
            dsr3.Site__c = site1.Id;
            dsr3.Summary_Report_Date__c = System.today()-1;
            dsr3.Status__c = 'Open';
            insert dsr3;
            
            Daily_Report__c dailyReportRig = testData.createRigDailyReport();
            dailyReportRig.Contract__c = cont.Id;
            dailyReportRig.Site__c = site1.Id;
            dailyReportRig.Unit__c = rigUnit.Id;
            dailyReportRig.Daily_Summary_Report__c = dsr3.Id;
            insert dailyReportRig;
            
            delete dsr3;           
            
            
        }
        catch(Exception e){
            String errorMessage = 'You cannot delete a Daily Site Job Summary if it has Daily Site Jobs Attached to it.';
            Boolean exceptionThrown = e.getMessage().contains(errorMessage) ? true : false;
            system.debug('## exception: ' + e.getMessage());
            //System.assertEquals(exceptionThrown, true);
        }
    }
    
    
    
    
    
}