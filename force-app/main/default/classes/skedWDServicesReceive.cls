public with sharing class skedWDServicesReceive extends skedComponentControllerBase {

    //Use in table rows. 
    public Integer rowNumber{ get; set; }
    public Integer numberOfRowToRemove { get; set; }
    public Integer numberOfRowToEdit { get; set; }

    //Use in modal pop-up
    public boolean displayPopup {get; set;}    
    public boolean displayHourly {get; set;} 
    public boolean displayDaily {get; set;}  
    
    public boolean isEdit {get; set;}  
    
    //Required fields error 
    public boolean showError {get; set;} 
    
    public void closePopup() {        
        displayPopup = false;  }
        
    public void showPopup() { 
        System.debug('**before '+displayPopup );
        
        showError = false;
        
        if (isEdit == null) {isEdit = false;}       
        displayPopup = false;   
                     
        if (selectedRecordType == '' || selectedRecordType == '--None--' || selectedRecordType == null)
            return; 
                
        if (selectedRecordType == 'Operations'){ displayPopup = true;
        displayHourly = true;   displayDaily = false; }
        
        if (selectedRecordType =='Hire/Additional'){ displayPopup = true;
        displayDaily = true;    displayHourly = false; } 
        
        System.debug('**after'+displayPopup );   
    }
    
    //Use for Record Types selection
    public string selectedRecordType {get; set;}   
    public List<SelectOption> RecordTypeList {get;set;}  
       
    
    //Helper method
    public static string getRecordID (String recordTypeName) {
    try {    
            return ServicesReceived__c.SObjectType
                   .getDescribe()
                   .getRecordTypeInfosByName()
                   .get(recordTypeName)
                   .getRecordTypeId();
        } catch(Exception e) {
            return null;
        }
    }

    //WD Report Id from the parent page
     public ID WDReportId {
          get;
          set {
              if (value != null) {
                WDReportId  = value;}
              }
    }
   
   //Place holder of the inputs from the pop-up
   public ServicesReceived__c NewLineItem {
   get{ 
       if (NewLineItem == null){
             NewLineItem = new ServicesReceived__c();
             NewLineItem.Date__c = System.Today();
                
         }      
                
            return NewLineItem ;
      }  
       set;
    }
    
    public Time StartTime {get; set;}
    public Time FinishTime {get; set;}
    
       
    //Helper property and method   
    public static Map<Id, Services_Received__c> mapItems {get; set;}     
    public static Services_Received__c getSRItem(String itemId) {
    try {
                if (mapItems == null)
                    mapItems = new Map<Id, Services_Received__c>([Select Name, Rate__c From Services_Received__c LIMIT 50000]);
    
                if (mapItems.size() > 0)
                    return mapItems.get(itemId);    
                    
                 return null;         
           
        } catch(Exception e) {
            return null;
        }
    }
    
    
     //Table Data
    public List<ServicesReceived__c> WDSRList {get; set;}
    
    
    public List<WDSRWrapper> WDSRWrapperList {get; set;}
     
    
  //Method for saving the list of WD SR
  public void SaveWDLineItem() {
      WDSRList = new List<ServicesReceived__c>();
      
      if (WDSRWrapperList == null){
          WDSRWrapperList = new List<WDSRWrapper>();         
      }
  
      for(WDSRWrapper p : WDSRWrapperList ){
            p.SR.DR__c = WDReportId;
            WDSRList.add(p.SR);
      }
            
      if (WDSRList.size() > 0)
          upsert WDSRList ;
          
      if (deleteList.size() > 0)
          delete deleteList;
  }
  
   //CSTR
   public skedWDServicesReceive (){
      RecordTypeList = new List<SelectOption>();
      
      RecordTypeList.add(new SelectOption('','--None--'));
      RecordTypeList.add(new SelectOption('Operations','Operations'));
      RecordTypeList.add(new SelectOption('Hire/Additional','Hire/Additional')); 

  }

  //Done button
  public void AddWDSR(){
      if (WDSRWrapperList == null){
          WDSRWrapperList = new List<WDSRWrapper>();         
      }
      
      StartTime = null;
      FinishTime = null;
      
    try{
       if (selectedRecordType == 'Operations'){
            if (this.NewLineItem.Start_time__c != null && this.NewLineItem.Finish_time__c != null 
                && this.NewLineItem.Category__c != null){
                this.NewLineItem.RecordTypeId = getRecordID('Operations'); 
                StartTime = Time.newInstance(Integer.valueOf(this.NewLineItem.Start_time__c.substringBefore(':')), Integer.valueOf(this.NewLineItem.Start_time__c.substringAfter(':')), 0, 0);
                FinishTime = Time.newInstance(Integer.valueOf(this.NewLineItem.Finish_time__c.substringBefore(':')), Integer.valueOf(this.NewLineItem.Finish_time__c.substringAfter(':')), 0, 0);
                this.NewLineItem.Item_total__c = GetElapsedTime(StartTime, FinishTime).hour();
                       
                if (GetElapsedTime(StartTime, FinishTime).minute() > 0){
                    Decimal min = GetElapsedTime(StartTime, FinishTime).minute();
                    this.NewLineItem.Item_total__c += (min/60);   
                       
                }
            }else{throw new skedCustomException ('WD Service Received fields required.');}
        }
            
       if (selectedRecordType == 'Hire/Additional')           
           this.NewLineItem.RecordTypeId = getRecordID('Hire/Additional');
                      
        WDSRWrapper newItem = new WDSRWrapper();
        newItem.SR = this.NewLineItem;
         
        if (this.NewLineItem.Item__c != null){
            Services_Received__c item = getSRItem(this.NewLineItem.Item__c);  
            newItem.SR.Item_Rate__c = Decimal.valueOf(item.Rate__c);
            newItem.SR.Item_total__c = newItem.SR.Item_total__c == null ? 0 : newItem.SR.Item_total__c;
            newItem.SR.Total_Cost__c = newItem.SR.Item_total__c * newItem.SR.Item_Rate__c;
        }else{throw new skedCustomException ('WD Service Received fields required.');}
                  
        if (isEdit){WDSRWrapperList.remove(numberOfRowToEdit);}
       
        WDSRWrapperList.add(newItem);
        this.NewLineItem = new ServicesReceived__c();
        displayPopup = false;    
        isEdit = false;
      }catch(Exception e){showError = true;}
  
}//end AddWDSR
  
    // The method to remove an item from the list/table
    public PageReference removeNewObject(){
        WDSRWrapperList.remove(numberOfRowToRemove);  

        return null;
    }
    
    private List<ServicesReceived__c> deleteList = new List<ServicesReceived__c>();
    
// The method to peremanently delete an item from the database
    public PageReference deleteNewObject(){
        ServicesReceived__c srDelete = WDSRWrapperList.get(numberOfRowToRemove).SR; 
        deleteList.add(srDelete);
        WDSRWrapperList.remove(numberOfRowToRemove);  
        return null;
    }
    
    // The method to remove an item from the list/table
    public PageReference editNewObject(){
        
        isEdit = true;

        selectedRecordType =  WDSRWrapperList.get(numberOfRowToEdit).RecordTypeName;
        this.NewLineItem = WDSRWrapperList.get(numberOfRowToEdit).SR;   
        showPopup(); 
        
        

        return null;
    }
    
    //Helper method
    public static Time GetElapsedTime(Time startTime, Time endTime)
    {
        if(startTime == null || endTime == null)
            return Time.newInstance(0, 0, 0, 0);
    
        Integer elapsedHours = endTime.hour() - startTime.hour();
        Integer elapsedMinutes = endTime.minute() - startTime.minute();
        Integer elapsedSeconds = endTime.second() - startTime.second();
        Integer elapsedMiliseconds = endTime.millisecond() - startTime.millisecond();
    
        return Time.newInstance(elapsedHours, elapsedMinutes, elapsedSeconds, elapsedMiliseconds);
    }
  
}