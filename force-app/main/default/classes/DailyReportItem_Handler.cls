/******************************************************************************
* @author        Kunal Jain
* @date         
* @description   This is a handler class for DailyReportItemTrigger
* @TestClass     DailyReportItemTrigger_Test
******************************************************************************/

public class DailyReportItem_Handler {
    
    public static Boolean DailyReportItemTriggerRecursion = false;
    
    /***********************************************************************************************
* @description: This method prevents a Daily Report Item from being added if a
* Daily Report for the day has already been created and item's Frequency is per day or per site
************************************************************************************************/
    /*****************************************************************************************
* Code commented by: Kunal Jain
* Reason: The handling of Per Day/Per Site Item is now being handled implicitly by visual
* workflow "Auto Create DR Items & Active Personnels PB Flow".
* It's also handled when the a Daily Site Job Item is being added.
******************************************************************************************/
    /*public static void preventDailyReportItem(List<Daily_Report_Item__c> triggernew){

try{
Set<Id> dailyReportIdSet = new Set<Id>();
Set<Id> contractIdSet = new Set<Id>();
Map<Id,List<Daily_Report__c>> dailyReportsMap = new Map<Id,List<Daily_Report__c>>();

for(Daily_Report_Item__c dri: triggernew){
if(dri.Daily_Report__c != null && dri.Contract_Job_Item__c != null && (dri.Item_Frequency__c == 'Per Day' || dri.Item_Frequency__c == 'Per Site')){
dailyReportIdSet.add(dri.Daily_Report__c);
}
}

List<Daily_Report__c> dailyReportsList = [Select Id,Site__c,Type__c,Contract__c,Unit__c,Auto_Create_Daily_Report_Items__c,Report_Date__c from Daily_Report__c where Id IN: dailyReportIdSet AND
Contract__c != null];

if(dailyReportsList != null && !dailyReportsList.isEmpty()){
for(Daily_Report__c dr: dailyReportsList){
contractIdSet.add(dr.Contract__c);
}

if(contractIdSet != null && !contractIdSet.isEmpty()){
List<Daily_Report__c> dailyReportsListOther = [Select Id,Site__c,Type__c,Contract__c,Unit__c,Auto_Create_Daily_Report_Items__c,Report_Date__c from Daily_Report__c where Contract__c IN: contractIdSet AND
Contract__c != null];

if(dailyReportsListOther != null && !dailyReportsListOther.isEmpty()){
for(Daily_Report__c dr: dailyReportsListOther){
if(dailyReportsMap.containsKey(dr.Contract__c) && dailyReportsMap.get(dr.Contract__c) != null){
dailyReportsMap.get(dr.Contract__c).add(dr);
}
else{
dailyReportsMap.put(dr.Contract__c, new List<Daily_Report__c>{dr});
}
}
}
}

for(Daily_Report_Item__c dri: triggernew){
for(Daily_Report__c dr: dailyReportsList){
if(dri.Daily_Report__c == dr.Id){
if(dailyReportsMap.containsKey(dr.Contract__c) && dailyReportsMap.get(dr.Contract__c) != null){

for(Daily_Report__c drc: dailyReportsMap.get(dr.Contract__c)){

//To check for Per Day
if(dri.Item_Frequency__c == 'Per Day' && dr.Id != drc.Id && dr.Report_Date__c == drc.Report_Date__c && dr.Unit__c == drc.Unit__c && dr.Type__c == drc.Type__c){
dri.addError('This item whose frequency is per day has already been added for the day. You cannot add it again for the same day.');
}

//To check for Per Site
if(dri.Item_Frequency__c == 'Per Site' && dr.Id != drc.Id && dr.Type__c == drc.Type__c && dr.Site__c == drc.Site__c){
dri.addError('This item whose frequency is per site has already been added for the site. You cannot add it again for another site.');
}
}
}
}
}
}
}
}
catch(Exception e){
System.debug('At '+e.getLineNumber()+'. Cause: '+e.getCause()+'. ErrorMessage: '+e.getMessage());
}
}*/
    
    
    
    
    /***********************************************************************************
* @description: This method Totals up the Hours from the Daily Report Item and
* add it to the report's related Unit
************************************************************************************/
    public static void addToNdt(List<Daily_Report_Item__c> triggernew){
        DailyReportItem_Handler.DailyReportItemTriggerRecursion = true;
        Set<Id> dailyReportIdSet = new Set<Id>();
        Set<Id> unitIdSet = new set<Id>();
        
        for(Daily_Report_Item__c dailyReportItem: triggernew){
            dailyReportIdSet.add(dailyReportItem.Daily_Report__c);
        }
        
        List<Daily_Report__c> dailyReportList = [Select Id,Name,Unit__c,Report_Date__c from Daily_Report__c where Id IN :dailyReportIdSet LIMIT 50000];
        for(Daily_Report__c dailyReport: dailyReportList){
            if(dailyReport.Unit__c != null){
                unitIdSet.add(dailyReport.Unit__c);
            }
        }
        
        if(!unitIdSet.isEmpty()){
            
            Map<Id,Decimal> unitNdtHoursMap = new Map<Id,Decimal>();
            
            List<Daily_Report__c> dailyReportMainList = [Select Id,Name,Unit__c,Report_Date__c,(Select Id,Name,Number_of_Hours__c,Contract_Job_Item__r.Add_to_NDT__c,Daily_Report__r.Unit__c
                                                                                                from Daily_Report_Items__r where Number_of_Hours__c != null AND
                                                                                                Contract_Job_Item__r.Add_to_NDT__c = true LIMIT 50000)
                                                         from Daily_Report__c where Unit__c IN: unitIdSet LIMIT 50000];
            
            Map<Id,Unit__c> unitMap = new Map<Id,Unit__c>([Select Id,Name,NDT_Hours__c,Date_Last_ndt__c from Unit__c where Id in :unitIdSet LIMIT 50000]);
            
            for(Daily_Report__c dailyReport: dailyReportMainList){
                if(!dailyReport.Daily_Report_Items__r.isEmpty()){
                    for(Daily_Report_Item__c dailyReportItem: dailyReport.Daily_Report_Items__r){
                        Unit__c unit = unitMap.get(dailyReport.Unit__c);
                        Decimal oldNdtHours = 0;
                        
                        if(unitNdtHoursMap.containsKey(unit.Id)){
                            oldNdtHours = unitNdtHoursMap.get(unit.Id);
                        }
                        
                        if(unit.Date_Last_ndt__c != null){
                            if(dailyReport.Report_Date__c >= unit.Date_Last_ndt__c){
                                oldNdtHours += dailyReportItem.Number_of_Hours__c;    
                            }                            
                        } else {
                            oldNdtHours += dailyReportItem.Number_of_Hours__c;
                        }
                        
                        unitNdtHoursMap.put(unit.Id,oldNdtHours);
                    }
                }
            }
            
            if(!unitNdtHoursMap.isEmpty()){
                DailyReportItem_Handler.DailyReportItemTriggerRecursion = true;
                List<Unit__c> unitUpdateList = new List<Unit__c>();
                for(Id unitId: unitNdtHoursMap.keyset()){
                    Unit__c unit = new Unit__c();
                    unit.Id = unitId;
                    unit.NDT_Hours__c = unitNdtHoursMap.get(unitId);
                    unitUpdateList.add(unit);
                }
                
                
                update unitUpdateList;
            }
            
            
        }
        
        
    }
    
}