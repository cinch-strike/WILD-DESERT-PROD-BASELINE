trigger sked_WDR_TotalHrs_trigger on ServicesReceived__c (after insert, after update) {


Set<Id> WDIds = new Set<ID>();
for (ServicesReceived__c sr : trigger.new){
    WDIds.add(sr.DR__c);
}

    system.debug(LoggingLevel.DEBUG, '## sr DR id: ' + WDIds);
List<ServicesReceived__c> SRList = [Select DR__c, RecordTypeId, Item_total__c, Category__c From ServicesReceived__c Where DR__c in :WDIds 
                                   limit 50000];
	system.debug(LoggingLevel.DEBUG, '## sr DR id: ' + SRList.size());
Map<Id, List<ServicesReceived__c>> mapWDR_SR = new Map<Id, List<ServicesReceived__c>>();
for (Id wdrId : WDIds){
    List<ServicesReceived__c> liSR = new List<ServicesReceived__c>();
    for (ServicesReceived__c sr : SRList){
        if (sr.DR__c == wdrId){
            liSR.add(sr);
        }
    }
    if(liSR.size() > 0)
        mapWDR_SR.put(wdrId, liSR);

}

Map<Id, WD_Report__c> WDRmap = new Map<Id, WD_Report__c>( [Select Operating_Hrs__c, Rig_Move_Hrs__c, Standby_WC_Hrs__c, Standby_WOC_Hrs__c, Repair_Hrs__c, Inspection_PMS_Hrs__c, Travel_Hrs__c
                            From WD_Report__c Where Id in :WDIds] );
                            
List<WD_Report__c> WDRList = new List<WD_Report__c>();
                           
skedComputeTotalHrs compute = new skedComputeTotalHrs();


for (Id wdrId : WDIds){
    List<ServicesReceived__c> mapValue = mapWDR_SR.get(wdrId);
    
    if (mapValue.size() > 0){
    System.debug('***'+mapValue);
        if (WDRmap.get(wdrId) != null){
            WD_Report__c returnValue = compute.ReturnWDR(mapValue, WDRmap.get(wdrId));
            WDRList.add(returnValue);
        }
    }
}

if (WDRList.size() > 0)
update WDRList;


}