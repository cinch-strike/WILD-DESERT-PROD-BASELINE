@isTest(SeeAllData=true)
    public class sked_WDR_Test2 {
         
         static Account Client;
         static Job_Orders__c Job;
         static WD_Report__c WDR;
         static WD_Personnel__c Personnel;
         static ServicesReceived__c ServiceReceived1;
         static ServicesReceived__c ServiceReceived2;
         static ServicesReceived__c ServiceReceived3;
         static ServicesReceived__c ServiceReceived4;
         static ServicesReceived__c ServiceReceived5;
         static ServicesReceived__c ServiceReceived6;
         static ServicesReceived__c ServiceReceived7;
         static ServicesReceived__c ServiceReceived8;
         static Unit__c WDUNit;
         static Site__c Site;
         static Services_Received__c Item;
         static Position__c Position;
         static Employees__c Employee;
         
         static testMethod void TestWDTriggers() {  

            Schema.DescribeSObjectResult accSchema = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = accSchema.getRecordTypeInfosByName(); 
            Id acc_rtId = AccountRecordTypeInfo.get('Client').getRecordTypeId();
    
            Client = new Account();
            Client.Name = 'John Doe';
            Client.RecordTypeId = acc_rtId;
            
            //Client
            insert Client;
            
            Site = new Site__c();
            Site.Name = 'Site Test';
            Site.Account__c = Client.Id;
            
            //Site
            insert Site;
            
            WDUNit = new Unit__c();
            WDUNit.Name = 'WD Unit Test';
            WDUNit.Site__c = Site.Id;
            WDUNit.Fuel_On_Hand__c = 50;
            WDUNit.Fuel_Delivered__c = 100;
            WDUNit.Fuel_Used__c = 10;
            
            //WD Unit
            insert WDUNit;
   
            Job = new Job_Orders__c();
            Job.Client__c = Client.Id;
            Job.Description__c = 'Job Test';
            Job.Job_Date__c = System.Today();
            Job.To_Be_Invoiced__c = 'On Job Completion';
            Job.Job_Status__c = 'Open';
            Job.WD_Unit__c = WDUNit.Id;
            Job.Site_ID__c = Site.Id;
            
            
            //Job
            insert Job;
            
            Schema.DescribeSObjectResult wdrSchema = Schema.SObjectType.WD_Report__c; 
            Map<String,Schema.RecordTypeInfo> WDRRecordTypeInfo = wdrSchema.getRecordTypeInfosByName(); 
            Id wdr_rtId = WDRRecordTypeInfo.get('12 Hour Rig').getRecordTypeId();
            
            WDR = new WD_Report__c();
            WDR.RecordTypeId = wdr_rtId;
                WDR.Sales_Order__c = Job.Id;
            WDR.Approved_By__c = UserInfo.getUserId();
            WDR.WD_Unit__c = WDUNit.Id;
            
            //WDR
            insert WDR;
         
            Test.startTest();  

            WD_Report__c report = [Select Fuel_Delivered__c, Fuel_Used__c From WD_Report__c Where Id = :WDR.Id];
            
            report.Fuel_Delivered__c = 200;
            report.Fuel_Used__c = 70;
            
            update report;          
                
            Test.stopTest();    
        }
        
        static testMethod void TestPageBaseClass() {
            
            Schema.DescribeSObjectResult accSchema = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = accSchema.getRecordTypeInfosByName(); 
            Id acc_rtId = AccountRecordTypeInfo.get('Client').getRecordTypeId();
    
            Client = new Account();
            Client.Name = 'John Doe';
            Client.RecordTypeId = acc_rtId;
            
            //Client
            insert Client;
            
            Site = new Site__c();
            Site.Name = 'Site Test';
            Site.Account__c = Client.Id;
            
            //Site
            insert Site;
            
            WDUNit = new Unit__c();
            WDUNit.Name = 'WD Unit Test';
            WDUNit.Site__c = Site.Id;
            WDUNit.Fuel_On_Hand__c = 50;
            WDUNit.Fuel_Delivered__c = 100;
            WDUNit.Fuel_Used__c = 10;
            
            //WD Unit
            insert WDUNit;
   
            Job = new Job_Orders__c();
            Job.Client__c = Client.Id;
            Job.Description__c = 'Job Test';
            Job.Job_Date__c = System.Today();
            Job.To_Be_Invoiced__c = 'On Job Completion';
            Job.Job_Status__c = 'Open';
            Job.WD_Unit__c = WDUNit.Id;
            Job.Site_ID__c = Site.Id;
            
            
            //Job
            insert Job;
            
            Schema.DescribeSObjectResult wdrSchema = Schema.SObjectType.WD_Report__c; 
            Map<String,Schema.RecordTypeInfo> WDRRecordTypeInfo = wdrSchema.getRecordTypeInfosByName(); 
            Id wdr_rtId = WDRRecordTypeInfo.get('12 Hour Rig').getRecordTypeId();
            
            WDR = new WD_Report__c();
            WDR.RecordTypeId = wdr_rtId;
              WDR.Sales_Order__c = Job.Id;
            WDR.Approved_By__c = UserInfo.getUserId();
            
            //WDR.Name = 'WDR Test';
            
            //WDR
            insert WDR;
            
            Test.startTest();
            
            Test.setCurrentPage(new PageReference('apex/WDRpage?WDReportId='+WDR.Id));
            skedWDPageController pageCtrl2 = new skedWDPageController();            
            
            skedWDPersonnel componentPersonnel = new skedWDPersonnel ();
            skedWDServicesReceive componentServiceReceived = new skedWDServicesReceive ();
                    
            
            pageCtrl2.myComponent1Controller = componentPersonnel;
            pageCtrl2.myComponent3Controller = componentServiceReceived;
            
            pageCtrl2.myComponent1Controller.key = 'component1';
            pageCtrl2.myComponent1Controller.pageController = pageCtrl2;
            
            pageCtrl2.myComponent3Controller.key = 'component3';
            pageCtrl2.myComponent3Controller.pageController = pageCtrl2;
            
            skedComponentControllerBase skcBase = pageCtrl2.getMyComponentController();
            
            Test.stopTest(); 
            
            
        }
        
        static testMethod void TestWDExtension() {  
        
                    Schema.DescribeSObjectResult accSchema = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = accSchema.getRecordTypeInfosByName(); 
            Id acc_rtId = AccountRecordTypeInfo.get('Client').getRecordTypeId();
    
            Client = new Account();
            Client.Name = 'John Doe';
            Client.RecordTypeId = acc_rtId;
            
            //Client
            insert Client;
            
            Site = new Site__c();
            Site.Name = 'Site Test';
            Site.Account__c = Client.Id;
            
            //Site
            insert Site;
            
            WDUNit = new Unit__c();
            WDUNit.Name = 'WD Unit Test';
            WDUNit.Site__c = Site.Id;
            WDUNit.Fuel_On_Hand__c = 50;
            WDUNit.Fuel_Delivered__c = 100;
            WDUNit.Fuel_Used__c = 10;
            
            //WD Unit
            insert WDUNit;
   
            Job = new Job_Orders__c();
            Job.Client__c = Client.Id;
            Job.Description__c = 'Job Test';
            Job.Job_Date__c = System.Today();
            Job.To_Be_Invoiced__c = 'On Job Completion';
            Job.Job_Status__c = 'Open';
            Job.WD_Unit__c = WDUNit.Id;
            Job.Site_ID__c = Site.Id;
            
            
            //Job
            insert Job;
            
            Schema.DescribeSObjectResult wdrSchema = Schema.SObjectType.WD_Report__c; 
            Map<String,Schema.RecordTypeInfo> WDRRecordTypeInfo = wdrSchema.getRecordTypeInfosByName(); 
            Id wdr_rtId = WDRRecordTypeInfo.get('12 Hour Rig').getRecordTypeId();
            
            WDR = new WD_Report__c();
            WDR.RecordTypeId = wdr_rtId;
          WDR.Sales_Order__c = Job.Id;
            WDR.Approved_By__c = UserInfo.getUserId();
            
            //WDR
            insert WDR;
        
        Test.startTest(); 
                
        Test.setCurrentPageReference(new PageReference('/'+Job.Id));
                
        ApexPages.StandardController sc = new ApexPages.standardController(Job);
        skedWDRextension skedExt = new skedWDRextension(sc);
        skedExt.selectedRecordType = '12 Hour Rig';
        skedExt.showWDRPage();

        
        Test.stopTest(); 
        
        }
        
        static testMethod void TestRExtension() {  
        
            Schema.DescribeSObjectResult accSchema = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = accSchema.getRecordTypeInfosByName(); 
            Id acc_rtId = AccountRecordTypeInfo.get('Client').getRecordTypeId();
    
            Client = new Account();
            Client.Name = 'John Doe';
            Client.RecordTypeId = acc_rtId;
            
            //Client
            insert Client;
            
            Site = new Site__c();
            Site.Name = 'Site Test';
            Site.Account__c = Client.Id;
            
            //Site
            insert Site;
            
            WDUNit = new Unit__c();
            WDUNit.Name = 'WD Unit Test';
            WDUNit.Site__c = Site.Id;
            WDUNit.Fuel_On_Hand__c = 50;
            WDUNit.Fuel_Delivered__c = 100;
            WDUNit.Fuel_Used__c = 10;
            
            //WD Unit
            insert WDUNit;
   
            Job = new Job_Orders__c();
            Job.Client__c = Client.Id;
            Job.Description__c = 'Job Test';
            Job.Job_Date__c = System.Today();
            Job.To_Be_Invoiced__c = 'On Job Completion';
            Job.Job_Status__c = 'Open';
            Job.WD_Unit__c = WDUNit.Id;
            Job.Site_ID__c = Site.Id;
            
            
            //Job
            insert Job;
            
            Schema.DescribeSObjectResult wdrSchema = Schema.SObjectType.WD_Report__c; 
            Map<String,Schema.RecordTypeInfo> WDRRecordTypeInfo = wdrSchema.getRecordTypeInfosByName(); 
            Id wdr_rtId = WDRRecordTypeInfo.get('12 Hour Rig').getRecordTypeId();
            
            WDR = new WD_Report__c();
            WDR.RecordTypeId = wdr_rtId;
          WDR.Sales_Order__c = Job.Id;
            WDR.Approved_By__c = UserInfo.getUserId();
            
            //WDR
            insert WDR;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(WDR);
        skedRelatedSRExtension skeExt = new skedRelatedSRExtension(sc);
        
        }
        
        
         
         
}