public with sharing class skedWDRextension {

    //Use for Record Types selection
    public string selectedRecordType {get; set;}
    public List<SelectOption> RecordTypeList {get;set;}  
    
    //Use for inline VF redirect
    public String redirectUrl {public get; private set;}
    public Boolean shouldRedirect {public get; private set;}
    
    //Current Job Order Record
    public Job_Orders__c Jo {get; set;}
    
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
    
    //Geet the current user profile
    public String userProfileName {
        get {
            return [
                    select Profile.Name
                    from User
                    where Id = :Userinfo.getUserId()
                    ].Profile.Name;
        }
    }
    
     //Table data
     public List<WDRWrapper> WDRWrapperList {get; set;}     
     public class WDRWrapper {
         public WD_Report__c Report {get; set;}
         public string RecordTypeName {get; set;}     
     }
    
     public List<WD_Report__c> WDRList  {
      get{
            if(WDRList == null)
              WDRList = new List<WD_Report__c>();    
              
              return WDRList;
      }
       set;}
   
    //CSTR
    public skedWDRextension(ApexPages.StandardController controller) {
    
        JO = (Job_Orders__c)controller.getRecord();    
        
        RecordTypeList = new List<SelectOption>();
        RecordTypeList.add(new SelectOption('','--None--'));
        
        if (userProfileName == 'Field Manager - Flushby' || userProfileName == 'Field Manager - Rig' || userProfileName == 'Ops Manager -Rig' ||
                        userProfileName == 'System Administrator')                
            RecordTypeList.add(new SelectOption('12 Hour Rig','12 Hour Rig'));
    
        if (userProfileName == 'Field Manager - Camp'  ||
                        userProfileName == 'System Administrator')                
            RecordTypeList.add(new SelectOption('Remote Camp','Remote Camp'));
        
        if (userProfileName == 'Field Manager - Flushby'  || userProfileName == 'Ops Manager - Transport' ||
                        userProfileName == 'System Administrator')                
            RecordTypeList.add(new SelectOption('Transport','Transport'));
          
        //Retrieve the WD Reports already related to the Job Order
        WDRList = [Select Date__c, RecordTypeId, Name, Hard_Copy__c , Operating_Hrs__c, Rig_Move_Hrs__c,Travel_Hrs__c, Standby_WC_Hrs__c, Repair_Hrs__c
                  From WD_Report__c Where Sales_Order__c = :JO.Id];
           
        WDRWrapperList = new List<WDRWrapper>();
           
        for (WD_Report__c wdr : WDRList ){
             WDRWrapper wrap = new WDRWrapper();
             wrap.Report = wdr;
             wrap.RecordTypeName = getRecordTypeName(wdr.RecordTypeId);
             
             WDRWrapperList.add(wrap);
        }

    }
    
    //Redirect to the WD Report Page
    public PageReference showWDRPage() {
        
        shouldRedirect = false;
                        
        if (selectedRecordType != '' && selectedRecordType != '--None--' && selectedRecordType != null){
             shouldRedirect = true;
             redirectUrl = '/apex/WDRPage?RecordType='+selectedRecordType+'&JobOrderId='+JO.Id;  }  
            
         return null;
    }

}