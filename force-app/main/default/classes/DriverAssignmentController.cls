public with sharing class DriverAssignmentController {
    @AuraEnabled(cacheable=true)
    public static List<Driver_Assignment__c> getDriverAssignmentList(Id transportjob) {
        return [SELECT Id, Name, Driver__r.Name, Driver_Status__c, Is_Driver_Assignment_Accepted__c, Send_Notification__c, Start_Date_Time__c, End_Date_Time__c, Duration__c, Start_Time__c, End_Time__c, Configuration_Name__c, 
            Maintenance_Category__c, Configuration_pklist__c, Truck__c, Truck__r.Name, Quoted_Price_Job__c, Driver_Assignment_URL__c, Driver_Assignment_Date__c
            FROM Driver_Assignment__c
            WHERE Transport_Job__c = :transportjob  
            WITH SECURITY_ENFORCED
            ORDER BY Driver__r.Name
        ];
    }

    // 23 JUN 2023 [C+S] GET DRAFT DRIVER ASSIGNMENT WITH NO CONTACT JOB ITEMS 
    @AuraEnabled(cacheable=true)
    public static List<Driver_Assignment__c> getDriverAssignNoContactJobItem(Id transportjob) {
        return [SELECT Id
            FROM Driver_Assignment__c 
            WHERE Transport_Job__c = :transportjob  
            AND Configuration__c = ''
            //AND Driver_Status__c = 'Draft'
            WITH SECURITY_ENFORCED
        ];
    }

    // 23 JUN 2023 [C+S] GET DRAFT DRIVER ASSIGNMENT WITH NO CONTACT JOB ITEMS 
    @AuraEnabled(cacheable=true)
    public static List<Driver_Assignment__c> getDriverAssignNoConfiguration(Id transportjob) {
        return [SELECT Id
            FROM Driver_Assignment__c 
            WHERE Transport_Job__c = :transportjob  
            AND Configuration_pklist__c = ''
            //AND Driver_Status__c = 'Draft'
            WITH SECURITY_ENFORCED
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List < sObject > fetchLookUpValues(String searchKey,String fieldName, String ObjectName,String keyField) {
     List < sObject > returnList = new List < sObject > ();
       String sQuery =  'SELECT '+fieldName+','+keyField+ ' FROM '
       +ObjectName+' LIMIT 100' ;
       List < sObject > lstOfRecords = Database.query(sQuery);
       for (sObject obj: lstOfRecords) {
           returnList.add(obj);
       }
       return returnList;
   }

   @AuraEnabled(cacheable=true)
   public static List <Contract_Item__c> ConfigurationLookUp(Id transportJobID) {
    String sQuery =  'SELECT Name, Id FROM Contract_Item__c WHERE Unit_Type__c = \'Transport\'';
    Transport_Job__c[] unitID =  [SELECT Unit__c, Unit__r.Contract_New__c, Unit__r.Unit_Type__c, Site__r.Contract__c FROM Transport_Job__c WHERE iD = :transportJobID];
    
    //If Unit ID record found
    if (!unitID.Isempty()) {
        /*Id strUnitID = unitID[0].Unit__c;
        Id strSiteId = unitID[0].Site__c;
        List<Unit__c> contractNo = new List<Unit__c>();
        List<Site__c> siteNo = new List<Site__c>();*/
        Id strcontractNo = null;
        if (unitID[0].Unit__r.Unit_Type__c == 'Transport'){
            sQuery =  'SELECT Name, Id FROM Contract_Item__c WHERE Active__c = TRUE AND Unit_Type__c = \'Transport\' AND Contract__c =\'' + unitID[0].Site__r.Contract__c + '\'';
        }
        else {
            sQuery =  'SELECT Name, Id FROM Contract_Item__c WHERE Active__c = TRUE AND Unit_Type__c = \'Transport\' AND Contract__c =\'' + unitID[0].Unit__r.Contract_New__c + '\'';
        }
        


        /*//If Contract No record found
        if(!contractNo.Isempty()){
            sQuery =  'SELECT Name, Id FROM Contract_Item__c WHERE Unit_Type__c = \'Transport\' AND Contract__c =\'' + strcontractNo + '\'';
       }*/
    } 
      
    List < Contract_Item__c > returnList = new List < Contract_Item__c > ();  
	List < Contract_Item__c > lstOfRecords = Database.query(sQuery);
	for (Contract_Item__c obj: lstOfRecords) {
               returnList.add(obj);
           }       
       
	return returnList; 
  }

    // 18 SEPT 2023: Added Truck lookup
    @AuraEnabled(cacheable=true)
    public static List <Asset__c> TruckLookUp(Id transportJobID) {
        String sQuery =  'SELECT Name, Id FROM Asset__c WHERE Type__c = \'Transport\' AND Asset_Family__c = \'Prime Movers\' ORDER BY Name ASC';
            
        List < Asset__c > returnList = new List < Asset__c > ();  
        List < Asset__c > lstOfRecords = Database.query(sQuery);
        for (Asset__c obj: lstOfRecords) {
                    returnList.add(obj);
                }       
            
        return returnList; 
    }

  @AuraEnabled(cacheable=true)
  public static List <Employees__c> DriverNameLookUp() {
   
    //List of Active Employees
   String sQuery =  'SELECT Id, Name FROM Employees__c WHERE RecordType.Name = \'Active Employee\' AND On_Shift__c = TRUE AND Driver_User__c != NULL ORDER BY Name';
   
   List < Employees__c > returnList = new List < Employees__c > ();  
   List < Employees__c > lstOfRecords = Database.query(sQuery);
   for (Employees__c obj: lstOfRecords) {
              returnList.add(obj);
          }       
      
   return returnList; 
 }
}