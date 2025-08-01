//Utility class to handle the complexity of "updateAppropriateAsset" trigger on "Job Card" object.
public class JobCardUtility{
    //Method to update related "Asset" record when "Job Card" record's status is set "Completed"
    public static void updateAppropriateAsset(Job_Cards__c newValues,Job_Cards__c oldValues,string jobCardId){
        string relatedAssetId;
        string relatedAssetRecordTypeName;
        relatedAssetId = JobCardUtility.findRelatedAssetId(jobCardId);
       
        if(relatedAssetId!= null){
            relatedAssetRecordTypeName=JobCardUtility.findRelatedAssetRecordTypeName(relatedAssetId);
            List<Asset__c> relatedAssetData = new List<Asset__c>();
          
            //Update Values in related "Asset" record if related "Asset" record type is "Light Vehicles".
            if(relatedAssetRecordTypeName=='Light Vehicles'){
                relatedAssetData=[select Last_Service_Km__c,Date_Of_Last_Service__c,Last_Service_Type__c from Asset__c where Id=:relatedAssetId ];
                relatedAssetData[0].Last_Service_Km__c = newValues.Odometer__c;
                relatedAssetData[0].Date_Of_Last_Service__c = System.Today();
                relatedAssetData[0].Last_Service_Type__c = newValues.Type_of_Maintenance__c;
                database.update(relatedAssetData);
            }
            //Update Values in related "Asset" record if related "Asset" record type is "Cranes","Non-Vehicle Engine","Rigs","Forklifts","Loaders".
            if(relatedAssetRecordTypeName=='Cranes'||relatedAssetRecordTypeName=='Forklifts'||relatedAssetRecordTypeName=='Loaders'||relatedAssetRecordTypeName=='Non-Vehicle Engine'||relatedAssetRecordTypeName=='Rigs'){
                relatedAssetData=[select Last_Service_Hrs__c,Date_Of_Last_Service__c,Last_Service_Type__c from Asset__c where Id=:relatedAssetId ];    
                relatedAssetData[0].Last_Service_Hrs__c = newValues.Engine_Hours__c; 
                relatedAssetData[0].Date_Of_Last_Service__c = System.Today();
                relatedAssetData[0].Last_Service_Type__c = newValues.Type_of_Maintenance__c;
                database.update(relatedAssetData);
            }
            //Update Values in related "Asset" record if related "Asset" record type is "Dollies","Prime Mover","Trailer".
            if(relatedAssetRecordTypeName=='Dollies'||relatedAssetRecordTypeName=='Prime Mover'||relatedAssetRecordTypeName=='Trailer'){
                relatedAssetData=[select Last_Service_Km__c,Date_Of_Last_Service__c,Last_Service_Type__c from Asset__c where Id=:relatedAssetId ];
                relatedAssetData[0].Last_Service_Km__c =newValues.Odometer__c;
                relatedAssetData[0].Date_Of_Last_Service__c = System.Today();
                relatedAssetData[0].Last_Service_Type__c = newValues.Type_of_Maintenance__c;
                database.update(relatedAssetData);
          
            }
       
       }
    
    }
    //Method to find "Asset" rcord id related with "Job Card" Record.
    public static string findRelatedAssetId(string jobCardId){
        List<Job_Cards__c> relatedJobCardAssetId = new List<Job_Cards__c>();
        relatedJobCardAssetId =[select WD_Asset__c from Job_Cards__c where Id=:jobCardId];
        return relatedJobCardAssetId [0].WD_Asset__c;
    }
    //Method to find "Asset" record's Record type name.
    public static string findRelatedAssetRecordTypeName(string relatedAssetId){
        List<Asset__c> relatedAssetInfo = new List<Asset__c>();
        relatedAssetInfo =[select RecordType.name from Asset__c where Id=:relatedAssetId];
        return relatedAssetInfo[0].RecordType.name;
    } 


}