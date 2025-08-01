//This class is written to handle all the complexity of AutoPopulateDevelopmentRecord  trigger.
public class AutoPopulateDevelopmentRecordsUtility{
    //This method handle all the newely employee insert requests.
    public static void createDevRecordOnEmployeeInsert(List<Employees__c > emloyeeNewList,Map<Id,Id> unitIdAndAccountIdMap,
    Map<Id,List<Mandatory_Professional_Development__c>> accountIdAndMandDevelopmentRecordId ,Map<Id,List<Mandatory_Professional_Development__c>> positionMandDevRecords ){
        
        Map<Id,Map<string,Development_Records__c>> uniqueDevRecUnderEmployee = new Map<Id,Map<string,Development_Records__c >>(); 
        Map<string,Development_Records__c> dumpMap; 
        
        List<Development_Records__c> devRecUnderEmployee = new List<Development_Records__c>();
        
        for(Employees__c emp:emloyeeNewList){
            if(emp.PositionLookup__c!=null||emp.Assigned_to_Unit__c!=null){
               dumpMap = new Map<string,Development_Records__c>();
               if(emp.Assigned_to_Unit__c!=null){
               for(Mandatory_Professional_Development__c d:accountIdAndMandDevelopmentRecordId.get(unitIdAndAccountIdMap.get(emp.Id))) {
                   Development_Records__c devClone = new Development_Records__c();
                    devClone.Professional_Development_Type__c= d.Professional_Development__c;
                    devClone.Employee__c= emp.Id;
                 /*  
                   devClone.Date_of_Training__c=d.Date_of_Training__c;
                   devClone.Date_Renewal_Required__c=d.Date_Renewal_Required__c;
                  
                   devClone.PD_Type_Text__c= d.PD_Type_Text__c;
                  
                   devClone.Status__c = d.Status__c;
                   devClone.Days_for_renewal_required__c = d.Professional_Development_Type__r.Days_until_renewal_is_required__c;
                   devClone.Unit_Id__c = emp.Assigned_to_Unit__c;
                  */
                   //devClone.Expiry_Status__c=d.Professional_Development_Type__r.Expiry_Status__c;
                   dumpMap.put(devClone.Professional_Development_Type__c,devClone);
                   system.debug('------------------Inside LOOP 1-------------------------------'+dumpMap);
               }
               }
               for(Mandatory_Professional_Development__c d1:positionMandDevRecords.get(emp.PositionLookup__c)){
                   Development_Records__c devClone1 = new Development_Records__c();
                   devClone1.Professional_Development_Type__c= d1.Professional_Development__c;
                   devClone1.Employee__c= emp.Id;
                   /*
                   devClone1.Date_of_Training__c=d1.Date_of_Training__c;
                   devClone1.Date_Renewal_Required__c=d1.Date_Renewal_Required__c;
                   
                   
                   devClone1.Status__c = d1.Status__c;
                   devClone1.Days_for_renewal_required__c = d1.Professional_Development_Type__r.Days_until_renewal_is_required__c;
                   devClone1.Position_Id__c = emp.PositionLookup__c;
                   */
                   //devClone1.Expiry_Status__c=d1.Professional_Development_Type__r.Expiry_Status__c;
                   dumpMap.put(devClone1.Professional_Development_Type__c,devClone1);
                    system.debug('------------------Inside LOOP 2-------------------------------'+dumpMap);
               }
               system.debug('------------------start-------------------------------'+dumpMap);
             uniqueDevRecUnderEmployee.put(emp.Id,dumpMap);
                          
            }
       }
     
       
           for(Map<string,Development_Records__c> mp:uniqueDevRecUnderEmployee.Values()){
               for(Development_Records__c d:mp.values()){
                   devRecUnderEmployee.add(d);
               }       
           }
       
       
           database.insert(devRecUnderEmployee);
     
           
       
    }
    //This method handles all the employee update requests.
    public static void updateDevRecordsUnderEmployee(Map<Id,Employees__c> oldEmpMap,List<Employees__c > emloyeeNewList,List<Employees__c > emloyeeOldList,
    Map<Id,Id> unitIdAndAccountIdMap,Map<Id,List<Mandatory_Professional_Development__c>> accountIdAndDevelopmentRecordId,
    Map<Id,List<Mandatory_Professional_Development__c>> positionMandDevRecords,Map<Id,List<Development_Records__c>> oldEmpDevRecords){
    Map<Id,Set<Id>> setprofessionalDevMap = new Map<Id,Set<Id>>();
        Map<Id,List<Mandatory_Professional_Development__c>> newPositionMandDevelopmentRec = new Map<Id,List<Mandatory_Professional_Development__c>>();
        Map<Id,List<Mandatory_Professional_Development__c>> newUnitMandDevelopmentRec = new Map<Id,List<Mandatory_Professional_Development__c>>();
        
        Map<Id,Map<string,Mandatory_Professional_Development__c>> mapNewUniqueMandDevRecords = new Map<Id,Map<string,Mandatory_Professional_Development__c>>();
        Map<string,Mandatory_Professional_Development__c> dumpMaptoUniq;
        
        for(Employees__c emp:emloyeeNewList){
            //if((emp.PositionLookup__c!=oldEmpMap.get(emp.Id).PositionLookup__c)||(emp.Assigned_to_Unit__c!=oldEmpMap.get(emp.Id).Assigned_to_Unit__c)){
                newPositionMandDevelopmentRec.put(emp.Id,positionMandDevRecords.get(emp.PositionLookup__c)); 
                newUnitMandDevelopmentRec.put(emp.Id,accountIdAndDevelopmentRecordId.get(unitIdAndAccountIdMap.get(emp.Id)));          
            //}
        } 
        system.debug('----------------------New Position Dev Records------------'+newPositionMandDevelopmentRec);  
        system.debug('----------------------New Unit Dev Records------------'+newUnitMandDevelopmentRec); 
        system.debug('----------------------Already existing devRecords------------'+oldEmpDevRecords);
       
        for(Employees__c emp:emloyeeNewList){
            dumpMaptoUniq = new Map<string,Mandatory_Professional_Development__c>();
            if(emp.PositionLookup__c!=null){
                for(Mandatory_Professional_Development__c dev:newPositionMandDevelopmentRec.get(emp.Id)){
                    dumpMaptoUniq.put(dev.Professional_Development__c,dev);
                }
            }
            if(emp.Assigned_to_Unit__c!=null){
                for(Mandatory_Professional_Development__c dev:newUnitMandDevelopmentRec.get(emp.Id)){
                    dumpMaptoUniq.put(dev.Professional_Development__c,dev);
                }
            }
            mapNewUniqueMandDevRecords.put(emp.Id,dumpMaptoUniq);    
        
        }
        
        system.debug('---111111111111111111-------Unique New------------'+mapNewUniqueMandDevRecords); 
        //To avoid duplicates and from new records 
        for(Employees__c emp:emloyeeNewList){
           for(string s :mapNewUniqueMandDevRecords.get(emp.Id).keySet()){
               Integer flag =0;
               for(Development_Records__c dev:oldEmpDevRecords.get(emp.Id)){
                   if(dev.Professional_Development_Type__c == s){
                       flag++;
                   }
               } 
               if(flag>0){
                   mapNewUniqueMandDevRecords.get(emp.Id).remove(s);
               }   
           }
        }
   
       system.debug('----2222222222222222222-------Unique New------------'+mapNewUniqueMandDevRecords); 
     
     //Copy new records from unique development records
     List<Development_Records__c> newDevRecords = new List<Development_Records__c>(); 
     for(Employees__c emp:emloyeeNewList){
         if((emp.PositionLookup__c!=oldEmpMap.get(emp.Id).PositionLookup__c)&&(emp.Assigned_to_Unit__c!=oldEmpMap.get(emp.Id).Assigned_to_Unit__c)){
              for(Mandatory_Professional_Development__c d:mapNewUniqueMandDevRecords.get(emp.Id).values()){
                  Development_Records__c dNew = new Development_Records__c();
                  dNew.Professional_Development_Type__c= d.Professional_Development__c;
                  dNew.Employee__c= emp.Id;
                 /* 
                  dNew.Date_of_Training__c=d.Date_of_Training__c;
                  dNew.Date_Renewal_Required__c=d.Date_Renewal_Required__c;
                  
                  
                  dNew.Status__c = d.Status__c;
                  dNew.Unit_Id__c = emp.Assigned_to_Unit__c;
                  dNew.Position_Id__c = emp.PositionLookup__c;
                  dNew.Days_for_renewal_required__c = d.Professional_Development_Type__r.Days_until_renewal_is_required__c;
                 */
                  //dNew.Expiry_Status__c=d.Professional_Development_Type__r.Expiry_Status__c;
                  newDevRecords.add(dNew);
             }
         }
        else if(emp.PositionLookup__c!=oldEmpMap.get(emp.Id).PositionLookup__c){
             for(Mandatory_Professional_Development__c d:mapNewUniqueMandDevRecords.get(emp.Id).values()){
                  Development_Records__c dNew = new Development_Records__c();
                  dNew.Professional_Development_Type__c= d.Professional_Development__c;
                  dNew.Employee__c= emp.Id;
                 /*
                  dNew.Date_of_Training__c=d.Date_of_Training__c;
                  dNew.Date_Renewal_Required__c=d.Date_Renewal_Required__c;
                  
                  dNew.Professional_Development_Type__c= d.Professional_Development_Type__c;
                  dNew.Status__c = d.Status__c;
                  dNew.Position_Id__c = emp.PositionLookup__c;
                  dNew.Days_for_renewal_required__c = d.Professional_Development_Type__r.Days_until_renewal_is_required__c;
                  */
                  //dNew.Expiry_Status__c=d.Professional_Development_Type__r.Expiry_Status__c;
                  newDevRecords.add(dNew);
             }
         }
         else if(emp.Assigned_to_Unit__c!=oldEmpMap.get(emp.Id).Assigned_to_Unit__c){
             for(Mandatory_Professional_Development__c d:mapNewUniqueMandDevRecords.get(emp.Id).values()){
                  Development_Records__c dNew = new Development_Records__c();
                  dNew.Professional_Development_Type__c= d.Professional_Development__c;
                  dNew.Employee__c= emp.Id;
                  /*
                  dNew.Date_of_Training__c=d.Date_of_Training__c;
                  dNew.Date_Renewal_Required__c=d.Date_Renewal_Required__c;
                  
                 
                  dNew.Status__c = d.Status__c;
                  dNew.Unit_Id__c = emp.Assigned_to_Unit__c;
                  dNew.Days_for_renewal_required__c = d.Professional_Development_Type__r.Days_until_renewal_is_required__c;
                  */
                  //dNew.Expiry_Status__c=d.Professional_Development_Type__r.Expiry_Status__c;
                  newDevRecords.add(dNew);
             }
         }
        
        
     }
    
         database.insert(newDevRecords);
    
 }   
    
    
    
    
    
    
}