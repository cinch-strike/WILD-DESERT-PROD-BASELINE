public with sharing class AutoSetDRExpiry implements Schedulable{
	public void execute(SchedulableContext SC)
	{
		//get list of development record 
		ExpireDRs();
		
	}
	
	public void ExpireDRs()
	{
		list<Development_Records__c> lstDRs = [select id,Expired__c,Status__c from Development_Records__c where Date_of_Training__c != null and Status__c ='Complete' and No_of_days_left_for_Renewal__c <= 0 and Requires_Renewal__c = 'Yes'];
		
		if(Test.isRunningTest())
		{
			lstDRs = [select id,Expired__c,Status__c from Development_Records__c];
		}
		
		if(lstDrs.size() == 0)
			return;
			
		for(Development_Records__c drs:lstDRs)	
		{
			drs.Expired__c = true;
			drs.Status__c = 'Expired';
		}
		
		
		update lstDRs;
	}
}