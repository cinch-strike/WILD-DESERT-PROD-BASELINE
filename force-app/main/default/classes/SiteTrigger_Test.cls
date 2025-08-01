@isTest
public class SiteTrigger_Test {
    static testMethod void testMethod1(){
        
        try{
            TestDataFactory testData = new TestDataFactory();
            
            Account acc = testData.createAccount();
            insert acc;
            
            Contract__c cont = testData.createContract();
            cont.Account__c = acc.Id;
            insert cont;
            
            Unit__c rigUnit = testData.createRigUnit();
            rigUnit.Contract_New__c = cont.Id;
            rigUnit.LTI_Reset_Date__c = System.today() - 5;
            insert rigUnit;
            
            Site__c site1 = testData.createSite();
            site1.Account__c = acc.Id;
            site1.Contract__c = cont.Id;
            site1.Status__c = 'Open';
            insert site1;
            
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
            
            Daily_Report__c dailyReportRig = testData.createRigDailyReport();
            dailyReportRig.Contract__c = cont.Id;
            dailyReportRig.Site__c = site1.Id;
            dailyReportRig.Unit__c = rigUnit.Id;
            dailyReportRig.Status__c = 'Open';
            insert dailyReportRig;
            
            Test.startTest();
            site1.Site_Status__c = 'Closed';
            update site1;
            Test.stopTest();
            
        }
        catch(Exception e){
            String errorMessage = 'Site Status cannot be set to Closed';
            Boolean exceptionThrown = e.getMessage().contains(errorMessage) ? true : false;
            System.assertEquals(exceptionThrown, true);
        }   
    }
    
    static testMethod void preventSiteDelete(){
        
        try{
            TestDataFactory testData = new TestDataFactory();
            
            Account acc = testData.createAccount();
            insert acc;
            
            Contract__c cont = testData.createContract();
            cont.Account__c = acc.Id;
            insert cont;
            
            Unit__c rigUnit = testData.createRigUnit();
            rigUnit.Contract_New__c = cont.Id;
            rigUnit.LTI_Reset_Date__c = System.today() - 5;
            insert rigUnit;
            
            Site__c site1 = testData.createSite();
            site1.Account__c = acc.Id;
            site1.Contract__c = cont.Id;
            site1.Status__c = 'Open';
            insert site1;
            
            Daily_Report__c dailyReportRig = testData.createRigDailyReport();
            dailyReportRig.Contract__c = cont.Id;
            dailyReportRig.Site__c = site1.Id;
            dailyReportRig.Unit__c = rigUnit.Id;
            dailyReportRig.Status__c = 'Open';
            insert dailyReportRig;
            
            delete site1;
            
        }
        catch(Exception e){
            String errorMessage = 'You cannot delete a Site when there are records associated with it.';
            Boolean exceptionThrown = e.getMessage().contains(errorMessage) ? true : false;
            System.assertEquals(exceptionThrown, true);
        }   
    }
}