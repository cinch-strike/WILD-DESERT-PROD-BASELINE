//Apex Utility Class written to handle the complexity of "CreateJobCard" trigger on "Asset" object.
public class CreateJobCardUtility {
    static String jobCreationStatus = 'No';

    //Method to create "Job Card" Record if the record tyoe of "Asset" is "Light Vehicle"
    public static String createJobCardForLightVechiles(Asset__c newRecordValue,Asset__c oldRecordValue,Id assetRecordID){
        List<Job_Cards__c> jobs = new  List<Job_Cards__c>();
        jobs=[select id from Job_Cards__c where WD_Asset__c =:assetRecordID ];
        jobCreationStatus = 'No';
        
        if(newRecordValue.Current_Odometer_Reading__c >= newRecordValue.Next_Job_Card_creation_reading__c && newRecordValue.Do_Not_Create_Work_Order__c == False) {
            Job_Cards__c newJob = new Job_Cards__c();
            newJob.RecordTypeId =createJobCardUtility.recordTypeIdOfName('Scheduled Service');
            newJob.Date_Created__c = system.today();
            newJob.Type_of_Maintenance__c = 'KM Service';
            newJob.WD_Asset__c=assetRecordID;
            newJob.Odometer__c=newRecordValue.Current_Odometer_Reading__c;
            newJob.OwnerId = newRecordValue.ownerId;
            database.insert(newJob);
            jobCreationStatus = 'Yes';
        }
        return jobCreationStatus;
    }
    //Method to create "Job Card" Record if the record tyoe of "Asset" is "Cranes","Non-Vehicle Assets" "Rigs","Forklifts","Loaders".
    public static string createJobCardForCrenes(Asset__c newRecordValue,Asset__c oldRecordValue,Id assetRecordID){
        Integer maxRecordCountValue;
        maxRecordCountValue = createJobCardUtility.latestJobCardRecordOfCranes(assetRecordID);
        jobCreationStatus = 'No';
        
        if( newRecordValue.Engine_Hours__c>= newRecordValue.Next_Job_Card_creation_reading__c && newRecordValue.Do_Not_Create_Work_Order__c == False){   
            
            Job_Cards__c newJob = new Job_Cards__c();
            newJob.RecordTypeId =createJobCardUtility.recordTypeIdOfName('Scheduled Service');
            newJob.Date_Created__c = system.today();
            newJob.WD_Asset__c=assetRecordID;
            newJob.Engine_Hours__c =newRecordValue.Engine_Hours__c;
            newJob.OwnerId = newRecordValue.ownerId;
            if(math.mod(maxRecordCountValue,8)==0){
                newJob.Record_Count_Cranes__c = 1;
                newJob.Type_of_Maintenance__c='Type 1 - 250Hrs';
            }
            if(math.mod(maxRecordCountValue,8)==1){
                newJob.Record_Count_Cranes__c = 2;
                newJob.Type_of_Maintenance__c='Type 2 - 500Hrs';
            }
            if(math.mod(maxRecordCountValue,8)==2){
                newJob.Record_Count_Cranes__c = 3;
                newJob.Type_of_Maintenance__c='Type 1 - 250Hrs';
            }
            if(math.mod(maxRecordCountValue,8)==3){
                newJob.Record_Count_Cranes__c = 4;
                newJob.Type_of_Maintenance__c='Type 3 - 1000Hrs';
            }
            if(math.mod(maxRecordCountValue,8)==4){
                newJob.Record_Count_Cranes__c = 5;
                newJob.Type_of_Maintenance__c='Type 1 - 250Hrs';
            }
            if(math.mod(maxRecordCountValue,8)==5){
                newJob.Record_Count_Cranes__c = 6;
                newJob.Type_of_Maintenance__c='Type 2 - 500Hrs';
            }
            if(math.mod(maxRecordCountValue,8)==6){
                newJob.Record_Count_Cranes__c = 7;
                newJob.Type_of_Maintenance__c='Type 1 - 250Hrs';
            }
           if(math.mod(maxRecordCountValue,8)==7){
               newJob.Record_Count_Cranes__c = 8;
               newJob.Type_of_Maintenance__c='Type 4 - 2000Hrs';
            }
            database.insert(newJob);
            jobCreationStatus = 'Yes';
        }
        return jobCreationStatus; 
    }
    //Method to create "Job Card" Record if the record tyoe of "Asset" is "Dollies","Prime Movers","Trailer".
    public static string createJobCardForDollies(Asset__c newRecordValue,Asset__c oldRecordValue,Id assetRecordID){
        Integer maxRecordCountValue;
        maxRecordCountValue = createJobCardUtility.latestJobCardRecordOfDollies(assetRecordID);
        jobCreationStatus = 'No';
        
        if( newRecordValue.Current_Odometer_Reading__c>= newRecordValue.Next_Job_Card_creation_reading__c && newRecordValue.Do_Not_Create_Work_Order__c == False){     
            Job_Cards__c newJob = new Job_Cards__c();
            newJob.RecordTypeId =createJobCardUtility.recordTypeIdOfName('Scheduled Service');
            newJob.Date_Created__c = system.today();
            newJob.WD_Asset__c=assetRecordID;
            newJob.Odometer__c=newRecordValue.Current_Odometer_Reading__c;
            newJob.OwnerId = newRecordValue.ownerId;
            if(math.mod(maxRecordCountValue,4)==0){
                newJob.Record_Count_Dollies__c = 1;
                newJob.Type_of_Maintenance__c='Truck/Trailer/Dolly A';
            }
            if(math.mod(maxRecordCountValue,4)==1){
                newJob.Record_Count_Dollies__c = 2;
                newJob.Type_of_Maintenance__c='Truck/Trailer/Dolly B';
            }
            if(math.mod(maxRecordCountValue,4)==2){
                newJob.Record_Count_Dollies__c = 3;
                newJob.Type_of_Maintenance__c='Truck/Trailer/Dolly A';
            }
            if(math.mod(maxRecordCountValue,4)==3){
                newJob.Record_Count_Dollies__c = 4;
                newJob.Type_of_Maintenance__c='Truck/Trailer/Dolly C';
            }
           
            database.insert(newJob);
            jobCreationStatus = 'Yes';       
        }
        return jobCreationStatus;   
    }
    //Method returns record type id by passing record type name of "Asset" object.
    public static string recordTypeIdOfName(String recordTypeName){
        Schema.DescribeSObjectResult jobCardSchema = Schema.SObjectType.Job_Cards__c; 
        Map<String,Schema.RecordTypeInfo> jobCardRecordTypeInfo = jobCardSchema.getRecordTypeInfosByName();
        return jobCardRecordTypeInfo.get(recordTypeName).getRecordTypeId();
    }
    //Method returns the order of "Job Card" record under particular "Asset" record of record type "Cranes","Non-Vehicle Assets" "Rigs" .
    public static Integer latestJobCardRecordOfCranes(string assetId){
        Integer recordCountValue;
        List<Job_Cards__c> listLatestRecords = new List<Job_Cards__c>();
        listLatestRecords = [select Record_Count_Cranes__c from Job_Cards__c where WD_Asset__c=:assetId order by CreatedDate desc  ] ;
        if(!listLatestRecords.isEmpty()){
            recordCountValue =Integer.valueOf(listLatestRecords[0].Record_Count_Cranes__c);
            return recordCountValue;    
        }
        else{
            return 0;
        }
    }
    //Method returns the order of "Job Card" record under particular "Asset" record of record type "Dollies","Prime Movers","Trailer" .
    public static Integer latestJobCardRecordOfDollies(string assetId){
        Integer recordCountValue;
        List<Job_Cards__c> listLatestRecords = new List<Job_Cards__c>();
        listLatestRecords = [select Record_Count_Dollies__c from Job_Cards__c where WD_Asset__c=:assetId order by CreatedDate desc  ] ;
        if(!listLatestRecords.isEmpty()){
            recordCountValue =Integer.valueOf(listLatestRecords[0].Record_Count_Dollies__c);
            return recordCountValue;    
        }
        else{
            return 0;
        }
    }
   

}