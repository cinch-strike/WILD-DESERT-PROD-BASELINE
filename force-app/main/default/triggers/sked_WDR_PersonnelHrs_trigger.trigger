trigger sked_WDR_PersonnelHrs_trigger on WD_Personnel__c (after insert, after update) {


Set<Id> WDIds = new Set<ID>();
for (WD_Personnel__c person : trigger.new){
    WDIds.add(person.DR__c);
}

List<WD_Personnel__c> PersonList = [Select DR__c, Total_Hours__c From WD_Personnel__c Where DR__c in :WDIds ];

Map<Id, List<WD_Personnel__c>> mapWDR_Person = new Map<Id, List<WD_Personnel__c>>();
for (Id wdrId : WDIds){
    List<WD_Personnel__c> liPerson = new List<WD_Personnel__c>();
    for (WD_Personnel__c p : PersonList ){
        if (p.DR__c == wdrId){
            liPerson.add(p);
        }
    }
    if(liPerson.size() > 0)
        mapWDR_Person.put(wdrId, liPerson);

}

Map<Id, WD_Report__c> WDRmap = new Map<Id, WD_Report__c>( [Select Personnel_Hrs__c
                            From WD_Report__c Where Id in :WDIds] );
                            
List<WD_Report__c> WDRList = new List<WD_Report__c>();
                           
skedComputePersonnelHrs compute = new skedComputePersonnelHrs();


for (Id wdrId : WDIds){
    List<WD_Personnel__c> mapValue = mapWDR_Person.get(wdrId);
    System.debug('***trigger '+ wdrId);
    if (mapValue.size() > 0){
        WD_Report__c returnValue =  compute.ReturnWDPersonnelHrs(mapValue, WDRmap.get(wdrId));
        if (returnValue.Id != null)
            WDRList.add(returnValue);
    }
}

if (WDRList.size() > 0)
update WDRList;




}