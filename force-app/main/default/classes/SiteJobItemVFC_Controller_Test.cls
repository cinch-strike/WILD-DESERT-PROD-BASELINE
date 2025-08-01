@isTest
public class SiteJobItemVFC_Controller_Test {
    
    @testSetup
    static void testSetup(){
        
        TestDataFactory testData = new TestDataFactory();
        List<Item__c> itemList = new List<Item__c>();
        
        Item__c item1 = testData.createItemRigOperating();
        item1.Service_Type__c = 'Fixed Price/Hour';
        itemList.add(item1);
        
        Item__c item2 = testData.createItemRigOperating();
        item2.Name = 'Rig Parts';
        item2.Service_Type__c = 'Fixed Price/Quantity';
        itemList.add(item2);
        
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
        rigUnit.Contract_New__c = cont.Id;
        rigUnit.LTI_Reset_Date__c = System.today() - 5;
        insert rigUnit;
        
        List<Contract_Item__c> contractItemList = new List<Contract_Item__c>();
        
        Contract_Item__c contractItem1 = testData.createContractJobItem();
        contractItem1.Unit_Type__c = 'Rig';
        contractItem1.Contract__c = cont.Id;
        contractItem1.Item_Name__c = item1.Id;
        contractItem1.Add_to_NDT__c = true;
        contractItem1.Auto_Populate_in_Daily_Report__c = true;
        contractItem1.Service_Type__c = 'Fixed Price/Hour';
        contractItem1.Item_Frequency__c = 'Multi Per Day';
        contractItemList.add(contractItem1);
        
        Contract_Item__c contractItem2 = testData.createContractJobItem();
        contractItem2.Unit_Type__c = 'Rig';
        contractItem2.Contract__c = cont.Id;
        contractItem2.Item_Name__c = item2.Id;
        contractItem2.Add_to_NDT__c = true;
        contractItem2.Auto_Populate_in_Daily_Report__c = true;
        contractItem2.Service_Type__c = 'Fixed Price/Quantity';
        contractItem2.Item_Frequency__c = 'Multi Per Day';
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
        insert dailyReportRig;
        
        Id perHourRecordTypeId = [Select Id From RecordType Where SObjectType = 'Daily_Report_Item__c' And DeveloperName='Per_Hour'].Id;
        Id perQuantityRecordTypeId = [Select Id From RecordType Where SObjectType = 'Daily_Report_Item__c' And DeveloperName='Per_Quantity'].Id;
        
        List<Daily_Report_Item__c> dailyReportItemList = new List<Daily_Report_Item__c>();
        
        Daily_Report_Item__c dailyReportItem1 = new Daily_Report_Item__c();
        dailyReportItem1.RecordTypeId = perHourRecordTypeId;
        dailyReportItem1.Daily_Report__c = dailyReportRig.Id;
        dailyReportItem1.Start_Time__c = System.now().addHours(-1);
        dailyReportItem1.End_Time__c = System.now().addHours(1);
        dailyReportItem1.Contract_Job_Item__c = contractItem1.Id;
        dailyReportItemList.add(dailyReportItem1);
        
        Daily_Report_Item__c dailyReportItem11 = new Daily_Report_Item__c();
        dailyReportItem11 = dailyReportItem1.clone(false,false,false,false);
        dailyReportItem11.Start_Time__c = System.now().addHours(-3);
        dailyReportItem11.End_Time__c = System.now().addHours(-2);
        dailyReportItemList.add(dailyReportItem11);
        
        
        Daily_Report_Item__c dailyReportItem2 = new Daily_Report_Item__c();
        dailyReportItem2.Daily_Report__c = dailyReportRig.Id;
        dailyReportItem2.Contract_Job_Item__c = contractItem2.Id;
        dailyReportItem2.RecordTypeId = perQuantityRecordTypeId;
        dailyReportItem2.Quantity__c = 5;
        dailyReportItemList.add(dailyReportItem2);
        
        Daily_Report_Item__c dailyReportItem3 = new Daily_Report_Item__c();
        dailyReportItem3.RecordTypeId = perHourRecordTypeId;
        dailyReportItem3.Daily_Report__c = dailyReportRig.Id;
        dailyReportItem3.Start_Time__c = System.now().addHours(2);
        dailyReportItem3.End_Time__c = System.now().addHours(4);
        dailyReportItem3.Contract_Job_Item__c = contractItem1.Id;
        dailyReportItemList.add(dailyReportItem3);
        
        Daily_Report_Item__c dailyReportItem4 = new Daily_Report_Item__c();
        dailyReportItem4.Daily_Report__c = dailyReportRig.Id;
        dailyReportItem4.Contract_Job_Item__c = contractItem2.Id;
        dailyReportItem4.RecordTypeId = perQuantityRecordTypeId;
        dailyReportItem4.Quantity__c = 5;
        dailyReportItemList.add(dailyReportItem4);
        
        insert dailyReportItemList;        
    }
    
    //Without dailyReportId
    static testMethod void testMethodWithoutId(){
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.SiteJobItemVFC_CustomConstructor();
    }
    
    //With dailyReportId, for single item
    static testMethod void testMethodWithId1(){
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.dailyReportId = [Select Id from Daily_Report__c LIMIT 1].Id;        
        siteJobItem.SiteJobItemVFC_CustomConstructor();
        siteJobItem.driItem = [Select Id,Start_Time__c,End_Time__c from Daily_Report_Item__c where Start_Time__c != null LIMIT 1].Id;
        system.debug('siteJobItem.driItem: ' + siteJobItem.driItem);
        siteJobItem.getSiteJobItems();
    }
    
    //With dailyReportId
    static testMethod void testMethodWithId2(){
        
        TestDataFactory testData = new TestDataFactory();
        List<Contract_Item__c> contractItemInsertList = new List<Contract_Item__c>();
        
        
        
        
        Daily_Report__c dailyReport = [Select Id,Contract__c from Daily_Report__c LIMIT 1];
        
        Item__c item1 = new Item__c();
        item1.Name = 'Rig Operating 1';
        item1.Active__c = true;
        item1.Unit_Type__c = 'Rig';
        item1.Service_Type__c = 'Fixed Price/Hour';
        item1.Group__c = 'Operating';
        item1.UOM__c = 'Hour';
        item1.Add_to_NDT__c = true;
        insert item1;
        
        Contract_Item__c contractItem1 = testData.createContractJobItem();
        contractItem1.Unit_Type__c = 'Rig';
        contractItem1.Contract__c = dailyReport.Contract__c;
        contractItem1.Item_Name__c = item1.Id;
        contractItem1.Add_to_NDT__c = true;
        contractItem1.Auto_Populate_in_Daily_Report__c = true;
        contractItem1.Service_Type__c = 'Fixed Price/Hour';
        contractItemInsertList.add(contractItem1);
        
        Item__c item2 = new Item__c();
        item2.Name = 'Rig Extra Night Driller';
        item2.Active__c = true;
        item2.Unit_Type__c = 'Rig';
        item2.Service_Type__c = 'Fixed Price/Quantity';
        item2.Group__c = 'Operating';
        item2.UOM__c = 'Hour';
        item2.Add_to_NDT__c = true;
        insert item2;
        
        Contract_Item__c contractItem2 = testData.createContractJobItem();
        contractItem2.Unit_Type__c = 'Rig';
        contractItem2.Contract__c = dailyReport.Contract__c;
        contractItem2.Item_Name__c = item1.Id;
        contractItem2.Add_to_NDT__c = true;
        contractItem2.Auto_Populate_in_Daily_Report__c = true;
        contractItem2.Service_Type__c = 'Fixed Price/Hour';
        contractItemInsertList.add(contractItem2);
        insert contractItemInsertList;
        
        Map<Id,Contract_Item__c> contractJobItemSet = new Map<Id,Contract_Item__c>([Select Id from Contract_Item__c]);
        
        
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.dailyReportId = [Select Id from Daily_Report__c LIMIT 1].Id;
        siteJobItem.SiteJobItemVFC_CustomConstructor();
        siteJobItem.createContractJobItemString(contractJobItemSet.keyset());
        siteJobItem.hideContractJobItemsModal();
        siteJobItem.clearValues();
        siteJobItem.resetItemList();
        siteJobItem.returnDailyReport();
        siteJobItem.editInVf();
        
    }
    
    //With dailyReportId, for single item
    static testMethod void testMethodWithId3(){
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.dailyReportId = [Select Id from Daily_Report__c LIMIT 1].Id;        
        for(Daily_Report_Item__c dri: siteJobItem.driList){
            if(dri.Contract_Job_Item__r.Service_Type__c.contains('Quantity')){
                dri.Quantity__c = 4;
            }
            else if(dri.Contract_Job_Item__r.Service_Type__c.contains('Hour') && (dri.Start_Time__c == null || dri.End_Time__c == null)){
                dri.Start_Time__c = System.now().addHours(6);
                dri.StartTime__c =  dri.Start_Time__c.addHours(6).format('h:mm a');
                dri.End_Time__c = System.now().addHours(7);
                dri.EndTime__c = dri.End_Time__c.format('h:mm a');
            }
        }
        siteJobItem.saveAndAdd();
        
    }
    
    static testMethod void testMethodWithIdDelete(){
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.dailyReportId = [Select Id from Daily_Report__c LIMIT 1].Id;        
        for(Daily_Report_Item__c dri: siteJobItem.driList){
            if(dri.Contract_Job_Item__r.Service_Type__c.contains('Quantity')){
                dri.Quantity__c = 4;
            }
            else if(dri.Contract_Job_Item__r.Service_Type__c.contains('Hour') && (dri.Start_Time__c == null || dri.End_Time__c == null)){
                dri.Start_Time__c = System.now().addHours(6);
                dri.StartTime__c =  dri.Start_Time__c.addHours(6).format('h:mm a');
                dri.End_Time__c = System.now().addHours(7);
                dri.EndTime__c = dri.End_Time__c.format('h:mm a');
            }
        }
        siteJobItem.saveAndAdd();
        for(Daily_Report_Item__c dri: siteJobItem.driList){
            if(dri.Id == null && dri.Contract_Job_Item__c == null){
                dri.Contract_Job_Item__c = [Select Id from Contract_Item__c where Item_Frequency__c = 'Multi Per Day' LIMIT 1].Id;
            }
        }
        Id dailyReportItem = [Select Id from Daily_Report_Item__c LIMIT 1].Id;
        ApexPages.currentPage().getParameters().put('itm',dailyReportItem);
        siteJobItem.deleteJobItem();
        
    }
    
    static testMethod void testMethodWithIdCloseSiteJob(){
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.dailyReportId = [Select Id from Daily_Report__c LIMIT 1].Id;      
        siteJobItem.closeSiteJob();
    }
    
    static testMethod void testMethodShowCancelModal1(){
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.dailyReportId = [Select Id from Daily_Report__c LIMIT 1].Id;    
        siteJobItem.showCancelModal();
    }
    
    static testMethod void testMethodShowCancelModal2(){
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.dailyReportId = [Select Id from Daily_Report__c LIMIT 1].Id;   
        siteJobItem.dr.Status__c = null;
        siteJobItem.showCancelModal();
    }
    
    static testMethod void testMethodSaveSiteJobItemSave(){
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.dailyReportId = [Select Id from Daily_Report__c LIMIT 1].Id; 
        for(Daily_Report_Item__c dri: siteJobItem.driList){
            if(dri.Contract_Job_Item__r.Service_Type__c.contains('Quantity')){
                dri.Quantity__c = 4;
            }
            else if(dri.Contract_Job_Item__r.Service_Type__c.contains('Hour') && (dri.Start_Time__c == null || dri.End_Time__c == null)){
                dri.Start_Time__c = System.now().addHours(6);
                dri.StartTime__c =  dri.Start_Time__c.addHours(6).format('h:mm a');
                dri.End_Time__c = System.now().addHours(7);
                dri.EndTime__c = dri.End_Time__c.format('h:mm a');
            }
        }
        
        siteJobItem.source = 'save';
        siteJobItem.saveSiteJobItem();
    }
    
    static testMethod void testMethodSaveSiteJobItemSaveAndNext(){
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.dailyReportId = [Select Id from Daily_Report__c LIMIT 1].Id; 
        for(Daily_Report_Item__c dri: siteJobItem.driList){
            if(dri.Contract_Job_Item__r.Service_Type__c.contains('Quantity')){
                dri.Quantity__c = 4;
            }
            else if(dri.Contract_Job_Item__r.Service_Type__c.contains('Hour') && (dri.Start_Time__c == null || dri.End_Time__c == null)){
                dri.Start_Time__c = System.now().addHours(6);
                dri.StartTime__c =  dri.Start_Time__c.addHours(6).format('h:mm a');
                dri.End_Time__c = System.now().addHours(7);
                dri.EndTime__c = dri.End_Time__c.format('h:mm a');
            }
        }
        
        siteJobItem.source = 'saveAndNext';
        siteJobItem.saveSiteJobItem();
        
    }
    
    static testMethod void testMethodSaveSiteJobItemSaveAndClose(){
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.dailyReportId = [Select Id from Daily_Report__c LIMIT 1].Id; 
        for(Daily_Report_Item__c dri: siteJobItem.driList){
            if(dri.Contract_Job_Item__r.Service_Type__c.contains('Quantity')){
                dri.Quantity__c = 4;
            }
            else if(dri.Contract_Job_Item__r.Service_Type__c.contains('Hour') && (dri.Start_Time__c == null || dri.End_Time__c == null)){
                dri.Start_Time__c = System.now().addHours(6);
                dri.StartTime__c =  dri.Start_Time__c.addHours(6).format('h:mm a');
                dri.End_Time__c = System.now().addHours(7);
                dri.EndTime__c = dri.End_Time__c.format('h:mm a');
            }
        }
        
        siteJobItem.source = 'saveAndClose';
        siteJobItem.saveSiteJobItem();
        
    }
    
    static testMethod void testMethodSaveSiteJobItemQuantityNull(){
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.dailyReportId = [Select Id from Daily_Report__c LIMIT 1].Id; 
        siteJobItem.saveSiteJobItem();
        system.assertEquals(true,siteJobItem.quantityHourErrorOccurred);
    }
    
    static testMethod void testMethodSaveSiteJobItemTimeNull(){
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.dailyReportId = [Select Id from Daily_Report__c LIMIT 1].Id; 
        for(Daily_Report_Item__c dri: siteJobItem.driList){
            if(dri.Contract_Job_Item__r.Service_Type__c.contains('Quantity')){
                dri.Quantity__c = 4;
            }
        }
        siteJobItem.saveSiteJobItem();
        system.assertEquals(true,siteJobItem.quantityHourErrorOccurred);
    }
    
    static testMethod void testMethodSaveSiteJobItemTime(){
        SiteJobItemVFC_Controller siteJobItem = new SiteJobItemVFC_Controller();
        siteJobItem.dailyReportId = [Select Id from Daily_Report__c LIMIT 1].Id; 
        for(Daily_Report_Item__c dri: siteJobItem.driList){
            if(!dri.Contract_Job_Item__r.Service_Type__c.contains('Quantity')){
                dri.Start_Time__c = System.now().addMinutes(30);
                dri.StartTime__c =  dri.Start_Time__c.format('h:mm a');
                dri.End_Time__c = System.now().addHours(7);
                dri.EndTime__c = dri.End_Time__c.format('h:mm a');
            }
        }
        siteJobItem.saveSiteJobItem();
        system.assertEquals(true,siteJobItem.quantityHourErrorOccurred);
    } 
    
    static testMethod void testMethodSiteJobItemSpecific(){
        //PageReference pgRef = Page.SiteJobItemSpecific_VF;
        //Test.setCurrentPage(pgRef);
        Daily_Report_Item__c dailyReportItem = [Select Id from Daily_Report_Item__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(dailyReportItem);
        SiteJobItemSpecific_Controller siteJobItemSpecific = new SiteJobItemSpecific_Controller(sc);
        siteJobItemSpecific.siteJobItemSpecific();
        
    }
    
}