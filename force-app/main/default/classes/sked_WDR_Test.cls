@isTest
    public class sked_WDR_Test {
         
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
         

         
         private static void init() {
            
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
            //WDR.Name = 'WDR Test';
            
            //WDR
            insert WDR;
            
            Schema.DescribeSObjectResult itemSchema = Schema.SObjectType.Services_Received__c; 
            Map<String,Schema.RecordTypeInfo> ItemRecordTypeInfo = itemSchema.getRecordTypeInfosByName(); 
            Id item_rtId = ItemRecordTypeInfo.get('Operations - Transport').getRecordTypeId();
            
            Item = new Services_Received__c();
            Item.Name = 'Test Item';
            Item.RecordTypeId = item_rtId;
            Item.ID__c = 'item id';
            Item.Owner_of_Hire_Item__c = Client.Id;
            Item.Client__c = Client.Id;
            Item.Date_Active__c = System.Today();
            Item.Collection_Delivery_Notes__c = 'Item Notes';
            Item.Description__c = 'Item Description';
            Item.Rate__c = '5';
            
            //Item
            insert Item;            
            
            RecordType rt = [select id,Name from RecordType where SobjectType='ServicesReceived__c' and Name='Hire/Additional' Limit 1];
            
            List<ServicesReceived__c> liSR = new List<ServicesReceived__c>();
            
            ServiceReceived1 = new ServicesReceived__c();
            ServiceReceived1.RecordTypeId = rt.Id;
            ServiceReceived1.Category__c = 'Operating';
            ServiceReceived1.Item__c = Item.Id;
            ServiceReceived1.Start_time__c = '11:00';
            ServiceReceived1.Finish_time__c = '11:30';
            ServiceReceived1.Date__c = System.Today();
            
            liSR.add(ServiceReceived1);
            
            ServiceReceived2 = new ServicesReceived__c();
            ServiceReceived2.RecordTypeId = rt.Id;
            ServiceReceived2.Category__c = 'Rig Move';
            ServiceReceived2.Item__c = Item.Id;
            ServiceReceived2.Start_time__c = '11:00';
            ServiceReceived2.Finish_time__c = '11:30';
            ServiceReceived2.Date__c = System.Today();
            
            liSR.add(ServiceReceived2);
            
            ServiceReceived3 = new ServicesReceived__c();
            ServiceReceived3.RecordTypeId = rt.Id;
            ServiceReceived3.Category__c = 'SBWC';
            ServiceReceived3.Item__c = Item.Id;
            ServiceReceived3.Start_time__c = '11:00';
            ServiceReceived3.Finish_time__c = '11:30';
            ServiceReceived3.Date__c = System.Today();
            
            liSR.add(ServiceReceived3);
            
            ServiceReceived4 = new ServicesReceived__c();
            ServiceReceived4.RecordTypeId = rt.Id;
            ServiceReceived4.Category__c = 'SBWOC';
            ServiceReceived4.Item__c = Item.Id;
            ServiceReceived4.Start_time__c = '11:00';
            ServiceReceived4.Finish_time__c = '11:30';
            ServiceReceived4.Date__c = System.Today();
            
            liSR.add(ServiceReceived4);
            
            ServiceReceived5 = new ServicesReceived__c();
            ServiceReceived5.RecordTypeId = rt.Id;
            ServiceReceived5.Category__c = 'Repair';
            ServiceReceived5.Item__c = Item.Id;
            ServiceReceived5.Start_time__c = '11:00';
            ServiceReceived5.Finish_time__c = '11:30';
            ServiceReceived5.Date__c = System.Today();
            
            liSR.add(ServiceReceived5);
            
            ServiceReceived6 = new ServicesReceived__c();
            ServiceReceived6.RecordTypeId = rt.Id;
            ServiceReceived6.Category__c = 'Inspection/PMS';
            ServiceReceived6.Item__c = Item.Id;
            ServiceReceived6.Start_time__c = '11:00';
            ServiceReceived6.Finish_time__c = '11:30';
            ServiceReceived6.Date__c = System.Today();
            
            liSR.add(ServiceReceived6);
            
            ServiceReceived7 = new ServicesReceived__c();
            ServiceReceived7.RecordTypeId = rt.Id;
            ServiceReceived7.Category__c = 'Crew Travel';
            ServiceReceived7.Item__c = Item.Id;
            ServiceReceived7.Start_time__c = '11:00';
            ServiceReceived7.Finish_time__c = '11:30';
            ServiceReceived7.Date__c = System.Today();
            
            liSR.add(ServiceReceived7);
            
            Schema.DescribeSObjectResult sr2Schema = Schema.SObjectType.ServicesReceived__c; 
            Map<String,Schema.RecordTypeInfo> sr2RecordTypeInfo = sr2Schema.getRecordTypeInfosByName(); 
            Id sr2_rtId = sr2RecordTypeInfo.get('Hire/Additional').getRecordTypeId();
            
            ServiceReceived8 = new ServicesReceived__c();
            ServiceReceived8.RecordTypeId = rt.Id;
            ServiceReceived8.Category__c = 'Crew Travel';
            ServiceReceived8.Item__c = Item.Id;
            ServiceReceived8.Item_total__c = 12;
            ServiceReceived8.Date__c = System.Today();
            
            liSR.add(ServiceReceived8);
            
            //List of SR
            insert liSR;
            
            Position = new Position__c();
            Position.Name = 'Driller';
            
            insert Position;
            
            Employee = new Employees__c();
            Employee.Status__c = 'Active';
            Employee.First_Name__c = 'Rey';
            Employee.Last_Name__c = 'Doe';
            Employee.Position__c = Position.Id;
            Employee.PositionLookup__c = Position.Id;
            Employee.Assigned_to_Unit__c = WDUNit.Id;

            insert Employee;
            
            Personnel = new WD_Personnel__c();
            Personnel.DR__c = WDR.Id;
            Personnel.Date_Created__c = System.Today();
            Personnel.Pay_Ending__c = '03/03/2015';
            Personnel.WD_Unit__c = WDUnit.Id;
            Personnel.Position__c = Position.Id;
            Personnel.Name__c = Employee.Id;
            Personnel.Total_Hours__c = 20;
            
            insert Personnel;
            
            //sked_CheckRecursive.runOnce();
            WD_Report__c report = [Select Fuel_Delivered__c, Fuel_Used__c From WD_Report__c Where Id = :WDR.Id];
            
            report.Fuel_Delivered__c = 200;
            report.Fuel_Used__c = 70;
            
            update report;
            
               
         }
         
        
        static testMethod void TestWDTriggers() {        
            Test.startTest();       
              init();     
            Test.stopTest();    
        }
        
        static testMethod void TestWDPersonnelComponent() {    
           
            Test.startTest();   
              init();           
              skedWDPersonnel wdp = new skedWDPersonnel();   
              wdp.rowNumber = 0;
              wdp.NewPersonnel = Personnel;  
              System.debug('test class eid '+Employee.Id);
              System.debug('test class pid '+Employee.PositionLookup__c);
              
              wdp.AddWDP(); 
              wdp.isEdit = false;
              wdp.numberOfRowToEdit = 0;              
              wdp.editNewObject();
              
              wdp.AddWDP();
              wdp.numberOfRowToRemove = 0;
              wdp.removeNewObject();
              
              wdp.AddWDP();
              wdp.numberOfRowToRemove = 0;
              wdp.deleteNewObject();
              
              
              wdp.showPopup();
              wdp.closePopup();
              
              wdp.PayEndingDate = '03/03/2015';
              
              wdp.WDUnit = WDUNit.Id;
              
              wdp.WDReportId = WDR.Id;
              
              wdp.SaveWDPersonnel();
              
              //wdp.removeNewObject(0);
              
               WD_Personnel__c retVal = [Select Id From  WD_Personnel__c where DR__c = :WDR.Id LIMIT 1];

              System.assertNotEquals(retVal, null);       
              
            Test.stopTest();    
        }
        
        static testMethod void TestWDServiceReceive() {    
           
            Test.startTest();      
              init();           
              skedWDServicesReceive wds = new skedWDServicesReceive();   
              wds.rowNumber = 0;
              wds.NewLineItem = ServiceReceived1 ;                                          
              
              wds.numberOfRowToEdit = 0;
              //wds.numberOfRowToRemove = 1;              
              
              wds.WDReportId = WDR.Id;
              
              wds.selectedRecordType = '--None--';
              wds.showPopup();
              wds.closePopup();
              
              wds.selectedRecordType = 'Hire/Additional';
              wds.showPopup();
              wds.closePopup();                                                   
              
              wds.selectedRecordType = 'Operations';
              wds.showPopup();
              wds.closePopup();
              wds.AddWDSR();
              
              wds.editNewObject();
              
            Schema.DescribeSObjectResult srSchema = Schema.SObjectType.ServicesReceived__c; 
            Map<String,Schema.RecordTypeInfo> srRecordTypeInfo = srSchema.getRecordTypeInfosByName(); 
            Id nItemRecId = srRecordTypeInfo.get('Hire/Additional').getRecordTypeId();
              
              wds.NewLineItem = ServiceReceived2 ;
              wds.NewLineItem.RecordTypeId = nItemRecId;
              wds.AddWDSR();
                           
              
              wds.SaveWDLineItem();
              
              //wds.removeNewObject(0);
              
               WD_Personnel__c retVal = [Select Id From  WD_Personnel__c where DR__c = :WDR.Id LIMIT 1];

              System.assertNotEquals(retVal, null);       
              
            Test.stopTest();    
        }
        
        static testMethod void TestPageCtrl1() {    
           
            Test.startTest();   

            Init();
            
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
            
            PageReference pageRef = Page.WDRpage;
 
            Test.setCurrentPage(pageRef);
            
            ApexPages.currentPage().getParameters().put('JobOrderId',Job.id);
            ApexPages.currentPage().getParameters().put('RecordType','12 Hour Rig');
            
            skedWDPersonnel swdp = new skedWDPersonnel();
            skedWDServicesReceive swds = new skedWDServicesReceive();
            skedWDPageController pageCtrl = new skedWDPageController();
            List<SelectOption> payEndList = pageCtrl.getPayEndingList();
            List<SelectOption> truckList = pageCtrl.getTruckList();

            swdp.key = 'component1';
            swdp.pageController = pageCtrl;
            
            swdp.key = 'component2';
            swdp.pageController = pageCtrl;
            
            skedWDPersonnel pagePersonnel = pageCtrl.myComponent1Controller;
            skedWDServicesReceive pageServiceReceived = pageCtrl.myComponent3Controller;
            
            pageCtrl.WDRSavePage();                                 
        

            //System.assertNotEquals(pageCtrl.WDR.Id, null);  
            
            Test.stopTest();    
        }       

        static testMethod void TestPageCtrl2() {    
           
            Test.startTest();   

            Init();         
            
            WDSRWrapper wrapper = new WDSRWrapper();
            wrapper.SR = ServiceReceived1;
            string recName = wrapper.RecordTypeName;
            string itemName = wrapper.ItemName;
                
                
            //PageReference pageRef2 = new PageReference('apex/WDRpage?WDReportId='+WDR.Id);
            System.debug('***TestPageCtrl2 '+ WDR.Id);
 
            Test.setCurrentPage(new PageReference('apex/WDRpage?WDReportId='+WDR.Id));
            skedWDPageController pageCtrl2 = new skedWDPageController();            
            
            skedWDPersonnel pagePersonnel = new skedWDPersonnel ();
            skedWDServicesReceive pageServiceReceived = new skedWDServicesReceive ();
            
            pageCtrl2.myComponent1Controller = pagePersonnel;
            pageCtrl2.myComponent3Controller = pageServiceReceived;
            
            pageCtrl2.PersonnelList = new List<WD_Personnel__c>();
            pageCtrl2.PersonnelList.add(Personnel);
            pageCtrl2.ServiceReceivedList = new List<ServicesReceived__c>();
            pageCtrl2.ServiceReceivedList.add(ServiceReceived1);
            pageCtrl2.ServiceReceivedList.add(ServiceReceived2);
            pageCtrl2.ServiceReceivedList.add(ServiceReceived3);
            
            pageCtrl2.WDR.Fuel_Delivered__c = 900;
            pageCtrl2.WDR.Fuel_Used__c = 100;
            
            pageCtrl2.WDRSavePage();
            //System.assertNotEquals(pageCtrl2.WDR.Id, null);
            
            
            Test.stopTest();    
        }
        
    }