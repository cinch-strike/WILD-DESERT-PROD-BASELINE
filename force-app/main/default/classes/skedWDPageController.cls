public with sharing class skedWDPageController extends skedPageControllerBase {


 //=========================================================================
 //=====================Components==========================================
 
  public skedWDPersonnel myComponent1Controller {set;
    get{
        System.debug('***Page Component1'); 
        //get the map, then the component controller using the appropriate key
        if(getComponentControllerMap()!=null){
          skedWDPersonnel mcc;
          mcc = (skedWDPersonnel )getComponentControllerMap().get('component1');
          if(mcc!= null)
             return mcc;
        }
        //just in case something goes wrong return something...this can be handled better
        return new skedWDPersonnel (); 
    }
  }  
  
    public skedWDServicesReceive myComponent3Controller {set;
    get{
        //get the map, then the component controller using the appropriate key
        if(getComponentControllerMap()!=null){
          skedWDServicesReceive mcc;
          mcc = (skedWDServicesReceive )getComponentControllerMap().get('component3');
          if(mcc!= null)
             return mcc;
        }
        //just in case something goes wrong return something...this can be handled better
        return new skedWDServicesReceive(); 
    }
  }
        
  
  //=========================================================================
  //=====================Page================================================
  
  
  public WD_Report__c WDR {
  get{
       if (WDR == null){
           WDR = new WD_Report__c();
           WDR.Sales_Order__c = JobOrderId;
       }
       
       return WDR;
    }
  set;}
  
    public Id WDReportId{
    get{
      if (ApexPages.currentPage().getParameters().get('WDReportId') != null ){
          WDReportId = ApexPages.currentPage().getParameters().get('WDReportId');
      }
  
      return WDReportId;
      }
    set;}
  
  public string WDPageRecordType {
  get{
      if (ApexPages.currentPage().getParameters().get('RecordType') != null ){
          WDPageRecordType = ApexPages.currentPage().getParameters().get('RecordType');
      }  
      return WDPageRecordType;
    }
  set;}
  
  public string selectedPayEnding {get; set;}
  
  public List<SelectOption> getPayEndingList   (){
  
     List<SelectOption> options = new List<SelectOption>();
     options.add(new SelectOption('', '-- Select One --'));       


        // Custom setting
        Map<String, PayEnding__c> payEnding = PayEnding__c.getAll();         

        
         Schema.DescribeFieldResult fieldResult =
         WD_Personnel__c.Pay_Ending__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
         for( Schema.PicklistEntry f : ple)
           {
              options.add(new SelectOption(f.getLabel(), f.getValue()));
           } 
           
         return options;

    }
    
      public List<SelectOption> getTruckList   (){
  
     List<SelectOption> options = new List<SelectOption>();
     //options.add(new SelectOption('', '-- Select One --'));       

         Schema.DescribeFieldResult fieldResult =
         WD_Report__c.Trucks_on_Job__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
         for( Schema.PicklistEntry f : ple)
           {
              options.add(new SelectOption(f.getLabel(), f.getValue()));
           } 
           
         return options;

    }
    
    public List<WD_Personnel__c> PersonnelList { get; set;}
    public List<ServicesReceived__c> ServiceReceivedList { get; set;}
    public List<WDSRWrapper> WDSRWrapperList { get; set;}
    

  
    public Id JobOrderId{
    get{
      if (ApexPages.currentPage().getParameters().get('JobOrderId') != null ){
          JobOrderId = ApexPages.currentPage().getParameters().get('JobOrderId');
      }
  
      return JobOrderId;
      }
    set;}
  
  public Job_Orders__c  JO {get; set;}

  //Constructor
  public skedWDPageController(){
      
      System.debug('***TestPageCtrl2 WDPage'+ApexPages.currentPage().getParameters().get('WDReportId'));
      if (ApexPages.currentPage().getParameters().get('WDReportId') != null ){
    
      WDR = [Select Sales_Order__c, Weather__c , Hard_Copy__c, Date__c, Status__c, Pay_Ending_Date__c, Trucks_on_Job__c ,
      RecordTypeId, WD_Unit__c, Site__c, Client__c, Camp__c, Job_Description__c, 
      Fuel_on_hand__c, Fuel_Delivered__c, Fuel_Used__c, LTI_Free_Days__c, TBM__c, Hazards_Raised__c,
      Emergency_Drill__c, Line_on_Spool__c, SOP_Review__c, Permit_to_Work__c, Safety_Meetings__c, Inductions_Employee__c,
      Line_Slipped__c, Approved_By__c
      From WD_Report__c Where Id = :WDReportId LIMIT 1];
      
      selectedPayEnding = WDR.Pay_Ending_Date__c;
      
      WDPageRecordType = getRecordTypeName(WDR.RecordTypeId);
      
      JO = [Select WD_Unit__c, Site_ID__c, Client__c, Description__c, Fuel_on_hand__c, Fuel_Delivered__c, Fuel_Used__c
                            From Job_Orders__c Where Id = :WDR.Sales_Order__c LIMIT 1];
                            
            PersonnelList = new List<WD_Personnel__c>();   
            PersonnelList.addAll([Select Night_Shift__c, DR__c, Total_Hours__c, Name__c, Position__c, Date_Created__c, Pay_Ending__c, WD_Unit__c, Crew_Change_Day__c  
            From WD_Personnel__c Where DR__c = :WDReportId ]);
            
            ServiceReceivedList = new List<ServicesReceived__c>();
            ServiceReceivedList.addAll([Select Total_Cost__c, Description_of_Operations__c, Date__c, DR__c, RecordTypeId, Item_total__c, Category__c, Start_time__c, Finish_time__c, Item__c, Item_Rate__c
            From ServicesReceived__c Where DR__c = :WDReportId ]);
            
            WDSRWrapperList = new List<WDSRWrapper>();
            for (ServicesReceived__c srRet : ServiceReceivedList){
                WDSRWrapper wdwrap = new WDSRWrapper();
                wdwrap.SR = srRet;
                WDSRWrapperList.add(wdwrap);
            }
            
            JobOrderId = JO.Id;
                            
         System.debug('***Page Cstr');  
      }
  
      if (ApexPages.currentPage().getParameters().get('JobOrderId') != null ){
          JO = [Select WD_Unit__c, Site_ID__c, Client__c, Description__c, Fuel_on_hand__c, Fuel_Delivered__c, Fuel_Used__c
                            From Job_Orders__c Where Id = :JobOrderId LIMIT 1];
         
          //Copy details from Job order to WD Report
          WDR.WD_Unit__c = JO.WD_Unit__c;
          WDR.Site__c = JO.Site_ID__c;
          WDR.Client__c = JO.Client__c;
          WDR.Date__c = System.Today();
          WDR.Job_Description__c = JO.Description__c;
          
          
          integer count = [Select Count() From WD_Report__c Where Sales_Order__c = :JO.Id];
          //Copy Fuel Management of last WDR to the latest WDR being created
          //WD_Report__c prevWDR = new WD_Report__c();
          WDR.Fuel_on_hand__c = JO.Fuel_on_hand__c;
          
          WDSRWrapperList = new List<WDSRWrapper>();
          PersonnelList = new List<WD_Personnel__c>();  

          
      }
  
  }
  
  
   public PageReference WDRSavePage() {

    if (WDR != null){
    
        Savepoint sp = Database.setSavepoint();
        try{
            WDR.RecordTypeId = getRecordTypeId(WDPageRecordType);        
            
            if (WDR.Status__c == null || WDR.Status__c == '')
            WDR.Status__c = 'In Progress';

            WDR.Pay_Ending_Date__c = selectedPayEnding;
            //WDR.Fuel_on_hand__c = WDR.Fuel_on_hand__c + WDR.Fuel_Delivered__c - WDR.Fuel_Used__c;
                                                     
        //Insert/Update the WD Report                 
        upsert WDR;
        
        //Saving the components data
        if (WDR.Id != null){
            //Personnel Save
            myComponent1Controller.WDReportId = WDR.Id;
            myComponent1Controller.WDUnit = WDR.WD_Unit__c;
            myComponent1Controller.PayEndingDate= selectedPayEnding;            
            myComponent1Controller.SaveWDPersonnel();            
            
            //Service Received Save
            myComponent3Controller.WDReportId = WDR.Id;         
            myComponent3Controller.SaveWDLineItem();
            
            //Updating the WD Unit Fuel Management
            Unit__c WDUnit = [Select Fuel_on_hand__c, Fuel_Delivered__c, Fuel_Used__c From Unit__c
                                Where Id =: WDR.WD_Unit__c];
            
            System.debug('*'+WDR.Fuel_on_hand__c);                    
            System.debug('*'+WDR.Fuel_Delivered__c);    
            System.debug('*'+WDR.Fuel_Used__c);    
            
            WDR.Fuel_Delivered__c = WDR.Fuel_Delivered__c == null ? 0 : WDR.Fuel_Delivered__c;
            WDR.Fuel_Used__c = WDR.Fuel_Used__c == null ? 0 : WDR.Fuel_Used__c;
            
            WDUnit.Fuel_on_hand__c = WDR.Fuel_on_hand__c + WDR.Fuel_Delivered__c - WDR.Fuel_Used__c;
                      

            //Update WD Unit of the WD Report
            update WDUnit;
            
            //Updating the Job Order Fuel Management of the related WD Report 
            JO.Fuel_on_hand__c = WDR.Fuel_on_hand__c + WDR.Fuel_Delivered__c - WDR.Fuel_Used__c;            
            
            //Update the Job Order Fuel Management
            Update JO;
        }
        
        return new PageReference('/' + WDR.Id);

        
        }
        catch(Exception e){
            Database.rollback(sp); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
    }

    return null;
  }
  
  public PageReference Cancel() {
    return new PageReference('/' + JobOrderId);    
  }

  
  //Helper method
    public static string getRecordTypeName(String recordTypeId) {
    try {    
            return WD_Report__c.SObjectType
                   .getDescribe()
                   .getRecordTypeInfosById()
                   .get(recordTypeId)
                   .getName();
        } catch(Exception e) {
            return null;
        }
    }
    
    public static Id getRecordTypeId(String recordTypeName) {
        try {
            return WD_Report__c.SObjectType
                   .getDescribe()
                   .getRecordTypeInfosByName()
                   .get(recordTypeName)
                   .getRecordTypeId();
        } catch(Exception e) {
            return null;
        }
    }
  
  
}