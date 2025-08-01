public class AssetAssignmentController {
    @AuraEnabled(cacheable=true)
    public static List<Asset_Driver_Assignment__c> getAssetAssignmentList(Id driverAssign) {
        return [SELECT Id, Driver_Assignment__c, WD_Asset__r.Name, WD_Asset__r.Asset_Family__c, WD_Asset__r.Registration_Number__c, WD_Asset__r.Serial_Number__c, 
                WD_Asset__r.Asset_ID_Number__c, WD_Asset__r.Unit__c, WD_Asset__r.Inventory_Item__c, WD_Asset__r.RecordTypeId
                FROM Asset_Driver_Assignment__c
                WHERE Driver_Assignment__c = :driverAssign  
                WITH SECURITY_ENFORCED
        ];
    }


    @AuraEnabled(cacheable=true)
    public static List <Asset__c> AssetLookUp(Id unitID) {
     /*String sQuery =  'SELECT Id, Name FROM Asset__c ORDER BY Name LIMIT 0';
     Transport_Job__c[] ownerID =  [SELECT OwnerId FROM Transport_Job__c WHERE iD = :transportJobID];
 
     //If Owner ID record found
     if (!ownerID.Isempty()) {
        Id strOwnerID = ownerID[0].OwnerId;
         Unit__c[] unitID = [SELECT Id FROM Unit__c WHERE Unit_Type__c = 'Transport' AND Unit_Manager__r.Id = :strOwnerID];
 
         //If Unit Id record found
        if(!unitID.Isempty()){
            Id strUnitID = unitID[0].Id;

             sQuery =  'SELECT Id, Name_and_Rego_Number__c FROM Asset__c WHERE Unit__c = \'' + strUnitID + '\' ORDER BY Name';
        }
     } */

        //If Unit Id record found
        string sQuery;
        //if(unitID <> 'null') {
            sQuery =  'SELECT Id, Name_and_Rego_Number__c FROM Asset__c WHERE Unit__c = \'' + unitID + '\' ORDER BY Name';
        //} else {
        //    sQuery =  'SELECT Id, Name FROM Asset__c ORDER BY Name LIMIT 0';
        //}
        
       
     List < Asset__c > returnList = new List < Asset__c > ();  
     List < Asset__c > lstOfRecords = Database.query(sQuery);
     for (Asset__c obj: lstOfRecords) {
                returnList.add(obj);
            }       
        
     return returnList; 
   }

    @AuraEnabled(cacheable=true)
    public static List <Asset__c> AssetOdometerLookUp() {
     
        //09 OCT 2023: C+S - This lookup will be used for LWC driverAssetOdometerReading
        string sQuery;
        sQuery =  'SELECT Id, Name_and_Rego_Number__c FROM Asset__c WHERE NHVAS_Accredited__c = TRUE ORDER BY Name';
       
       
     List < Asset__c > returnList = new List < Asset__c > ();  
     List < Asset__c > lstOfRecords = Database.query(sQuery);
     for (Asset__c obj: lstOfRecords) {
                returnList.add(obj);
            }       
        
     return returnList; 
   }

   @AuraEnabled(cacheable=true)
   public static List<Unit__c> getOwnerUnit(Id transportJobID) {
       String sQuery;
       Transport_Job__c[] ownerID =  [SELECT OwnerId FROM Transport_Job__c WHERE iD = :transportJobID];
    
        //If owner ID record found
        if (!ownerID.Isempty()) {
            Id strOwnerID = ownerID[0].OwnerId;
            sQuery = 'SELECT Id, Name FROM Unit__c WHERE Unit_Type__c = \'Transport\' AND Unit_Manager__r.Id =\'' + strOwnerID + '\'';
        } 
        
        List < Unit__c > returnList = new List < Unit__c > ();  
        List < Unit__c > lstOfRecords = Database.query(sQuery);
        for (Unit__c obj: lstOfRecords) {
                returnList.add(obj);
            }       
        
        return returnList; 
   }

   @AuraEnabled(cacheable=true)
   public static List <Unit__c> UnitLookUp() {
    String sQuery =  'SELECT Id, Name, UnitType__c from Unit__c WHERE Status__c = \'Active\' AND UnitType__c IN (\'Rig\', \'Camp\', \'Transport\') ORDER BY Name';
      
    List < Unit__c > returnList = new List < Unit__c > ();  
    List < Unit__c > lstOfRecords = Database.query(sQuery);
    for (Unit__c obj: lstOfRecords) {
               returnList.add(obj);
           }       
       
    return returnList; 
  }


   @AuraEnabled(cacheable=true)
   public static List<Asset_Odometer_Reading__c> getOdometerReading(Id ownerId) {

        // 09 OCT 2023: C+S - Changed the query to the new Asset Odometer Reading
       /*return [SELECT Id, WD_Asset__c, WD_Asset__r.Name, WD_Asset__r.Current_Odometer_Reading__c, Odometer_Reading__c 
                FROM Asset_Driver_Assignment__c WHERE Driver_Assignment__r.OwnerId = :ownerId 
                AND  Driver_Assignment__r.Driver_Status__c IN ('Assigned','In Progress') AND Transport_Job_Date__c = TODAY
                WITH SECURITY_ENFORCED
       ];*/
       return [SELECT Id, Asset__c, Asset__r.Name, Current_Odometer__c, Odometer_Today__c, Blank_Odometer_Today_formula__c 
       FROM Asset_Odometer_Reading__c WHERE OwnerId = :ownerId 
       AND CreatedDate = TODAY 
       WITH SECURITY_ENFORCED ORDER BY CreatedDate];
   }

   @AuraEnabled(cacheable=true)
   public static List<Daily_Pre_Start__c> getDailyPrestart(Id assetdriverid) {
       return [SELECT Id FROM Daily_Pre_Start__c WHERE Asset_Driver_Assignment__c = :assetdriverid 
                WITH SECURITY_ENFORCED
       ];
   }
}