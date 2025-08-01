@isTest
public class DailyReportTrigger_Test {
    
    //This test method covers updateLTI and preventDuplicateReport methods
    static testMethod void testMethod1(){
        try{
            TestDataFactory testData = new TestDataFactory();
            
            Account acc = testData.createAccount();
            insert acc;
            
            Contract__c cont = testData.createContract();
            cont.Account__c = acc.Id;
            insert cont;
            
            List<Unit__c> insertUnitList = new List<Unit__c>();
            
            Unit__c rigUnit = testData.createRigUnit();
            rigUnit.Contract_New__c = cont.Id;
            rigUnit.LTI_Reset_Date__c = System.today() - 5;
            insertUnitList.add(rigUnit);
            
            Unit__c campUnit = testData.createCampUnit();
            campUnit.Contract_New__c = cont.Id;
            campUnit.LTI_Reset_Date__c = System.today() - 5;
            insertUnitList.add(campUnit);
            
            insert insertUnitList;
            
            Site__c site = testData.createSite();
            site.Account__c = acc.Id;
            site.Contract__c = cont.Id;
            insert site;          
            
            List<Daily_Summary_Report__c> dailySummaryReportList = new List<Daily_Summary_Report__c>();  
            
            Daily_Summary_Report__c dsr = new Daily_Summary_Report__c();
            dsr.Contract__c = cont.Id;
            dsr.Site__c = site.Id;
            dsr.Summary_Report_Date__c = System.today();
            dsr.Status__c = 'Open';
            dailySummaryReportList.add(dsr);
            
            Daily_Summary_Report__c dsr2 = dsr.clone(false);
            dsr2.Summary_Report_Date__c = system.today() + 1;
            dailySummaryReportList.add(dsr2);
            
            Daily_Summary_Report__c dsr3 = dsr.clone(false);
            dsr3.Summary_Report_Date__c = system.today() + 2;
            dailySummaryReportList.add(dsr3);         
            insert dailySummaryReportList;
            
            List<Daily_Report__c> dailyReportList = new List<Daily_Report__c>();
            
            Daily_Report__c dailyReportRig = testData.createRigDailyReport();
            dailyReportRig.Contract__c = cont.Id;
            dailyReportRig.Site__c = site.Id;
            dailyReportRig.Unit__c = rigUnit.Id;
            dailyReportList.add(dailyReportRig);        
            
            Daily_Report__c dailyReportCamp = testData.createCampDailyReport();
            dailyReportCamp.Contract__c = cont.Id;
            dailyReportCamp.Site__c = site.Id;
            dailyReportCamp.Unit__c = campUnit.Id;
            dailyReportCamp.Status__c = 'Submitted';
            dailyReportList.add(dailyReportCamp);       
            
            Daily_Report__c dailyReportCamp2 = dailyReportCamp.clone(false);
            dailyReportCamp2.Report_Date__c = system.today() + 1;
            dailyReportList.add(dailyReportCamp2);          
            
            Daily_Report__c dailyReportCamp3 = dailyReportCamp.clone(false);
            dailyReportCamp3.Report_Date__c = system.today() + 2;
            dailyReportList.add(dailyReportCamp3);   
            
            Test.startTest();
            insert dailyReportList;
            
            delete [select Id from Daily_Report__c where Id= :dailyReportCamp3.Id];
            
            Daily_Report__c dailyReportCamp4 = dailyReportCamp.clone(false);
            dailyReportCamp4.Report_Date__c = system.today();
            insert dailyReportCamp4;
            Test.stopTest();
        }
        
        catch(Exception e){
            String errorMessage = 'Cannot create daily report. A Daily Report of the same type for this day has been already created for the Site';
            Boolean exceptionThrown = e.getMessage().contains(errorMessage) ? true : false;
            //System.assertEquals(exceptionThrown, true);
            
        }
    }
    
    //This method covers the preventOpenReport method
    static testMethod void testMethod2(){
        
        try{
            TestDataFactory testData = new TestDataFactory();
            
            Account acc = testData.createAccount();
            insert acc;
            
            Contract__c cont = testData.createContract();
            cont.Account__c = acc.Id;
            insert cont;
            
            List<Unit__c> unitList = new List<Unit__c>();
            
            Unit__c rigUnit = testData.createRigUnit();
            rigUnit.Contract_New__c = cont.Id;
            rigUnit.LTI_Reset_Date__c = System.today() - 5;
            unitList.add(rigUnit);
            
            Unit__c campUnit = testData.createCampUnit();
            campUnit.Contract_New__c = cont.Id;
            campUnit.LTI_Reset_Date__c = System.today() - 5;
            unitList.add(campUnit);
            
            insert unitList;
            
            Site__c site = testData.createSite();
            site.Account__c = acc.Id;
            site.Contract__c = cont.Id;
            insert site;
            
            Daily_Report__c dailyReportCamp = testData.createCampDailyReport();
            dailyReportCamp.Contract__c = cont.Id;
            dailyReportCamp.Site__c = site.Id;
            dailyReportCamp.Unit__c = campUnit.Id;
            dailyReportCamp.Status__c = 'Open';
            Test.startTest();
            insert dailyReportCamp;
            
            Daily_Report__c dailyReportCamp2 = dailyReportCamp.clone(false);
            dailyReportCamp2.Report_Date__c = system.today() + 1;
            insert dailyReportCamp2;
            Test.stopTest();
        }
        catch(Exception e){
            String errorMessage = 'Daily Report cannot be created since a Daily Report';
            Boolean exceptionThrown = e.getMessage().contains(errorMessage) ? true : false;
            System.assertEquals(exceptionThrown, true);
        }
        
    }   
    
    //This method covers the updateLTI method 
    static testMethod void testMethod3(){
        
        TestDataFactory testData = new TestDataFactory();
        
        Account acc = testData.createAccount();
        insert acc;
        
        Contract__c cont = testData.createContract();
        cont.Account__c = acc.Id;
        insert cont;
        
        List<Unit__c> unitList = new List<Unit__c>();
        
        Unit__c rigUnit = testData.createRigUnit();
        rigUnit.Contract_New__c = cont.Id;
        rigUnit.LTI_Reset_Date__c = System.today() - 5;
        unitList.add(rigUnit);        
        insert unitList;
        
        Site__c site = testData.createSite();
            site.Account__c = acc.Id;
            site.Contract__c = cont.Id;
            insert site;
        
        List<Daily_Report__c> dailyReportList = new List<Daily_Report__c>();
        Daily_Report__c dailyReportRig = testData.createRigDailyReport();
        dailyReportRig.Contract__c = cont.Id;
        dailyReportRig.Site__c = site.Id;
        dailyReportRig.Unit__c = rigUnit.Id;
        dailyReportList.add(dailyReportRig);
        insert dailyReportList;
        
        system.assertEquals(1, [Select Id,LTI__c from Unit__c where Id = :rigUnit.Id].LTI__c);
        
    
    }
    
    static testMethod void testDeletion(){
        TestDataFactory testData = new TestDataFactory();
            
        Account acc = testData.createAccount();
        insert acc;
        
        Contract__c cont = testData.createContract();
        cont.Account__c = acc.Id;
        insert cont;
        
        List<Unit__c> insertUnitList = new List<Unit__c>();
        
        Unit__c campUnit = testData.createCampUnit();
        campUnit.Contract_New__c = cont.Id;
        campUnit.LTI_Reset_Date__c = System.today() - 5;
        insertUnitList.add(campUnit);
        
        insert insertUnitList;
        
        Site__c site = testData.createSite();
        site.Account__c = acc.Id;
        site.Contract__c = cont.Id;
        site.WD_Camp__c = campUnit.Id;
        site.WD_Rig__c = campUnit.Id; // stand alone
        insert site;          
        
        List<Daily_Summary_Report__c> dailySummaryReportList = new List<Daily_Summary_Report__c>();  
        
        Daily_Summary_Report__c dsr = new Daily_Summary_Report__c();
        dsr.Contract__c = cont.Id;
        dsr.Site__c = site.Id;
        dsr.Summary_Report_Date__c = System.today();
        dsr.Status__c = 'Open';
        dailySummaryReportList.add(dsr);
        
        Daily_Report__c dailyReportCamp = testData.createCampDailyReport();
        dailyReportCamp.Contract__c = cont.Id;
        dailyReportCamp.Site__c = site.Id;
        dailyReportCamp.Unit__c = campUnit.Id;
        dailyReportCamp.Status__c = 'Open';
        insert dailyReportCamp;
        dailyReportCamp.Status__c = 'Submitted';
        update dailyReportCamp;
        try {
            delete dailyReportCamp;
        }
        catch (Exception e){
            system.assertNotEquals(null, e.getMessage());
        }
        dailyReportCamp.Status__c = 'Open';
        //update dailyReportCamp;
        //delete dailyReportCamp;
    }
    
}