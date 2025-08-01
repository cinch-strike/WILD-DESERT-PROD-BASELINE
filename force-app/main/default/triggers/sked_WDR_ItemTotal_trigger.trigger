trigger sked_WDR_ItemTotal_trigger on ServicesReceived__c (before insert, before update) {
      
    public Time StartTime {get; set;}
    public Time FinishTime {get; set;}
    
  for (ServicesReceived__c sr : trigger.New){
      
                StartTime = null;
                FinishTime = null;  

                  string RecordTypeId = skedWDServicesReceive.getRecordID('Hire/Additional'); 
                  
                  if (sr.RecordTypeId == RecordTypeId){
                  
                      StartTime = Time.newInstance(Integer.valueOf(sr.Start_time__c.substringBefore(':')), Integer.valueOf(sr.Start_time__c.substringAfter(':')), 0, 0);
                       FinishTime = Time.newInstance(Integer.valueOf(sr.Finish_time__c.substringBefore(':')), Integer.valueOf(sr.Finish_time__c.substringAfter(':')), 0, 0);
                       sr.Item_total__c = skedWDServicesReceive.GetElapsedTime(StartTime, FinishTime).hour();
                       
                       if (skedWDServicesReceive.GetElapsedTime(StartTime, FinishTime).minute() > 0){
                          Decimal min = skedWDServicesReceive.GetElapsedTime(StartTime, FinishTime).minute();
                          sr.Item_total__c += (min/60);   
                       
                       }
                    }
            
            
                  
  }
  
  
  }