public with sharing class skedWDPersonnel extends skedComponentControllerBase {

    //Use in table rows. 
    public Integer rowNumber{ get; set; }
    public Integer numberOfRowToRemove { get; set; }
    public Integer numberOfRowToEdit { get; set; }
    
    //Required fields error 
    public boolean showError {get; set;}   
    
    //Use in modal pop-up
    public boolean displayPopup {get; set;}   
    
    public boolean isEdit {get{ if (isEdit == null) isEdit = false; return isEdit;} set;}    
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {      
        if (isEdit == null) {isEdit = false;}
        System.debug('**before '+displayPopup);
        showError = false;
        displayPopup = true;    
        System.debug('**after '+displayPopup);
    }

    //WD Report Id from the page
    public ID WDReportId {
          get;
          set {
              if (value != null) {
                WDReportId  = value;}
              }
     }
     
   //Pay Ending from the WDR page
    public string PayEndingDate {
          get;
          set {
              if (value != null) {
                PayEndingDate = value;}
              }
     }
   
    //WD Unit from the page
    public ID WDUnit {
          get;
          set {
              if (value != null) {
                WDUnit = value;}
              }
    }
   
   //Place holder of the inputs from the pop-up
   public WD_Personnel__c NewPersonnel {
    get{ 
       if (NewPersonnel == null){
              NewPersonnel = new WD_Personnel__c();      
              NewPersonnel.Date_Created__c = System.Today();
                isEdit = false;
          }      
                return NewPersonnel ;
    }  
    set;}
  
    //Table Data
    public List<WD_Personnel__c> WDPList {get; set;}
    
   //Method for saving the list of WD Personnel
    public void SaveWDPersonnel() {
                
  
      if (WDPList == null){
          WDPList = new List<WD_Personnel__c>();         
      }
  
      for(WD_Personnel__c p : WDPList){
            p.DR__c = WDReportId;
            p.WD_Unit__c = WDUnit;
            p.Pay_Ending__c = PayEndingDate;
      }
            
      if (WDPList.size() > 0)
          upsert WDPList;
      
      if (deleteList.size() > 0)
          delete deleteList;
    }
  
   // The method to remove an item from the list
    public PageReference removeNewObject(){
        WDPList.remove(numberOfRowToRemove);  
        return null;
    }
    
     // The method to edit an item from the list
    public PageReference editNewObject(){
        if (WDPList.size() > 0){
            isEdit = true;
            System.debug('***WDPList '+WDPList);
            this.NewPersonnel = WDPList.get(numberOfRowToEdit);  
            showPopup();
        }
        
        return null;
    }
    
    private List<WD_Personnel__c> deleteList = new List<WD_Personnel__c>();
    
// The method to peremanently delete an item from the database
    public PageReference deleteNewObject(){
        if (WDPList.size() > 0){
            WD_Personnel__c personDelete = WDPList.get(numberOfRowToRemove);
            deleteList.add(personDelete);
            WDPList.remove(numberOfRowToRemove);  
        }
        return null;
    }
  
  
  
  public void AddWDP(){
  
      if (WDPList == null){
          WDPList = new List<WD_Personnel__c>();         
      }
      try{
      System.debug('**this.NewPersonnel.Position__c '+retrievePositionId(this.NewPersonnel.Name__c));
          if (this.NewPersonnel.Name__c != null && this.NewPersonnel.Total_Hours__c != null){
              this.NewPersonnel.Position__c = retrievePositionId(this.NewPersonnel.Name__c);
              
              if (isEdit){
                  if (WDPList != null)
                    WDPList.remove(numberOfRowToEdit); 
                  }
              
              WDPList.add(this.NewPersonnel);
              this.NewPersonnel = new WD_Personnel__c();
              displayPopup = false;    
              isEdit = false;
          }
            else      {
                throw new skedCustomException ('WD Personnel fields required.');
                
            }
      }catch(Exception e){showError = true;}
      
      System.debug('**showError '+ showError);
  }
  
    public Id retrievePositionId(Id EmployeeId){
     System.debug('component class eid '+EmployeeId);
    Employees__c emp = [Select PositionLookup__c From Employees__c Where Id = :EmployeeId];
    System.debug('component class return '+emp.PositionLookup__c);
    return emp.PositionLookup__c;
    
    }
    
    
    
}