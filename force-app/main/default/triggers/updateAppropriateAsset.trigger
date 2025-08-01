//Trigger to update "Job Card" record status to appropriate "Asset" Record.
trigger updateAppropriateAsset on Job_Cards__c (after update) {
    for(Job_Cards__c job:trigger.new){
        Integer count=0;
        string oldJobStatus= trigger.oldMap.get(job.Id).Status__c;
        //check the status of "Job Card" record.
        if((job.Status__c=='Completed')&&(job.Status__c!=oldJobStatus)){
            JobCardUtility.updateAppropriateAsset(trigger.new[count],trigger.old[count],job.Id);
        }
        count++; 
    }
}