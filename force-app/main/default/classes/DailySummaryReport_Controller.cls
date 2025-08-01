/**********************************************************************************
* @author        Kunal Jain
* @date         
* @description   This is a controller for DailySummaryReport_Pdf visualforce page,
				 DailySummaryReport_Pdf
* @TestClass     DailySummaryReport_Controller_Test
***********************************************************************************/
public class DailySummaryReport_Controller {
    
    private final Daily_Summary_Report__c dsrt;
    public Daily_Summary_Report__c dsr;
    public Map<String, List<SiteWrapper>> siteWrapperMap { get; set; }
    public SiteWrapper swrap { get; set; }
    public List<SiteWrapper> swList { get; set; }
    public Decimal totalCost { get; set; }
    public Boolean displayCost { get; set; }
    public Map<String,List<Active_Personnel__c>> activePersonalsMap { get; set; }
    public Map<String,List<Active_Personnel__c>> activePersonalsMap2 { get; set; }
    public Map<String,String> mapItemNameUOM { get; set; }
    public Map<String,Integer> hseqRollupMap { get; set; }
    public Integer hazardCount { get; set; }
    public List<Daily_Report__c> rigDailyReport { get; set; }
    public Set<Id> unitIdSet;
    public String unitsAssigned { get; set; }
    public String weatherData { get; set; }
    public Map<Id, Daily_Report__c> drMap { get; set; }
    public Map<Id, List<SiteWrapperPdf>> siteWrapperMapPDF { get; set; }
    public SiteWrapperPdf swrap2 {get;set;}
    
    
    public DailySummaryReport_Controller(ApexPages.StandardController stdController) {
        
        try {
            mapItemNameUOM = new Map<String,String>();
            siteWrapperMap = new Map<String, List<SiteWrapper>>();
            siteWrapperMapPDF = new Map<Id, List<SiteWrapperPdf>>();
            activePersonalsMap = new Map<String,List<Active_Personnel__c>>();
            activePersonalsMap2 = new Map<String,List<Active_Personnel__c>>();
            hseqRollupMap = new Map<String,Integer>(); 
            unitIdSet = new Set<Id>();
            rigDailyReport = new List<Daily_Report__c>();
            this.dsrt = (Daily_Summary_Report__c) stdController.getRecord();
            totalCost = 0;
            hazardCount = 0;
            unitsAssigned = '';
            weatherData = '';
            Id systemAdminProfileId = [Select Id,Name from Profile where Name = 'System Administrator'].Id;
            Id userProfileId = UserInfo.getProfileId();
            displayCost = (systemAdminProfileId == userProfileId) ? true : false;
            
            
            List<String> hseqRecordTypeLabels = Label.Rig_Hseq_RecordTypes.split(';');
            
            Map<Id,RecordType> hseqRecordTypeMap = new Map<Id,RecordType>([Select Id,DeveloperName,Name from RecordType where SObjectType='HSEQ_Forms__c' AND DeveloperName IN: hseqRecordTypeLabels]);
            
            if(hseqRecordTypeMap.values() != null && !hseqRecordTypeMap.isEmpty()){
                for(RecordType rt: hseqRecordTypeMap.values()){
                    String recordTypeName = rt.DeveloperName == 'Safe_Operation_Procedure' ? 'SOP Review' : rt.Name;
                    hseqRollupMap.put(recordTypeName,0);
                }
            }
            
            dsr = [Select Id,Name,Contract__c,Summary_Report_Date__c,Site__c from Daily_Summary_Report__c where Id =: dsrt.Id];
            rigDailyReport = [Select Id,Weather__c,No_of_KM_s_from_Previous_Site__c,Line_on_Spool__c,Line_Slipped__c,Previous_Site__c
                              from Daily_Report__c where Report_Date__c =: dsr.Summary_Report_Date__c AND Type__c = 'Rig' 
                              AND Daily_Summary_Report__c =: dsr.Id];
            
            if (dsr != null && dsr.Contract__c != null && dsr.Summary_Report_Date__c != null) {
                drMap = new Map<Id, Daily_Report__c>([
                    Select Id,Name,Site__c,Site__r.Account__c,Type__c,Report_Date__c,Daily_Summary_Report__c,Unit__c,Unit__r.Name,Weather__c,Incident_Occurred__c,
                    (Select Id,Name,Personnel_Name__c,Shift__c,Locale__c, Crew__c, Crew_Change__c,Position__c,Position__r.Name from Active_Personnels__r where Employees__c != null)
                    from Daily_Report__c
                    where Site__r.Contract__c = :dsr.Contract__c AND Daily_Summary_Report__c = :dsr.Id AND Site__c = :dsr.Site__c
                    ORDER BY Type__c ASC
                ]);
                
                if(drMap.values() != null && !drMap.values().isEmpty()){
                    for(Daily_Report__c dr: drMap.values()){
                        unitIdSet.add(dr.Unit__c);
                        unitsAssigned = unitsAssigned + dr.Unit__r.Name + ';';
                        if(dr.Type__c == 'Rig' && dr.Weather__c != null && weatherData == ''){
                            weatherData = dr.Weather__c;
                        }
                        else if(dr.Type__c == 'Camp' && dr.Weather__c != null && weatherData == ''){
                            weatherData = dr.Weather__c;
                        }
                    }
                    if(unitsAssigned.contains(';')){
                        unitsAssigned = unitsAssigned.removeEnd(';');
                    }
                }
                
                if (drMap != null && drMap.keySet() != null) {
                    
                    List<HSEQ_Forms__c> hseqFormsList = [Select Id,RecordTypeId,RecordType.Name,Date__c,RecordType.DeveloperName from HSEQ_Forms__c where Date__c =: dsr.Summary_Report_Date__c AND Daily_Site_Job__c IN: drMap.keySet() AND RecordTypeId IN: hseqRecordTypeMap.keyset()];
                    List<Hazard_Card__c> hazardCardList = [Select Id,Name from Hazard_Card__c where Date__c =: dsr.Summary_Report_Date__c AND Daily_Site_Job__c IN: drMap.keySet()];
                    List<Daily_Report_Item__c> dailyReportItemsList = [Select Id,Daily_Report__c,Quantity__c,Number_of_Hours__c,Rate__c,Total_Cost_Hour__c,Total_Cost_Quantity__c,Item_Name__c,
                                                                       Contract_Job_Item__c,Contract_Job_Item__r.Service_Type__c,Description__c
                                                                       from Daily_Report_Item__c where Contract_Job_Item__c != null and Daily_Site_Job_Summary__c = :dsr.Id and Daily_Report__c IN:drMap.keySet()];
                    
                    List<AggregateResult> driListItemName = [
                        Select Daily_Report__r.Site__r.Name siteName,SUM(Number_of_Hours__c) totalHours,SUM(Quantity__c) totalQuantity, Contract_Job_Item__r.Name itemName, SUM(Total_Cost_Hour__c) totalHoursCost, SUM( Total_Cost_Quantity__c) totalQuantityCost
                        from Daily_Report_Item__c
                        where Daily_Report__c IN:drMap.keySet() AND Contract_Job_Item__c != null
                        GROUP BY Daily_Report__r.Site__r.Name, Contract_Job_Item__r.Name
                    ];
                                        
                    if (drMap.values() != null && !drMap.values().isEmpty()) {
                        for (Daily_Report__c dr: drMap.values()) {
                            if (dr.Active_Personnels__r != null && !drMap.keySet().isEmpty()) {
                                for (Active_Personnel__c ap: dr.Active_Personnels__r) {
                                    if (activePersonalsMap.containsKey(dr.Type__c) && activePersonalsMap.get(dr.Type__c) != null) {
                                        activePersonalsMap.get(dr.Type__c).add(ap);
                                    } else {
                                        activePersonalsMap.put(dr.Type__c, new List<Active_Personnel__c>{ap});
                                    }
                                }
                                activePersonalsMap2.put(dr.Id,dr.Active_Personnels__r);
                            }
                        }
                    }
                    
                    if (driListItemName != null && !driListItemName.isEmpty()) {
                        for (AggregateResult aggr: driListItemName) {
                            system.debug(
                                    'Aggr: '  + aggr
                            );
                            if (siteWrapperMap.containsKey(String.valueOf(aggr.get('siteName'))) && siteWrapperMap.get(String.valueOf(aggr.get('siteName'))) != null) {
                                swrap = new SiteWrapper();
                                swrap.groupName = String.valueOf(aggr.get('itemName'));
                                if((Decimal) aggr.get('totalHours') != null){
                                    swrap.totalQuantity  = (Decimal) aggr.get('totalHours');
                                }
                                else if((Decimal) aggr.get('totalQuantity') != null){
                                    swrap.totalQuantity  = (Decimal) aggr.get('totalQuantity');
                                }
                                else{
                                    swrap.totalQuantity = 0;
                                }
                                if((Decimal) aggr.get('totalHoursCost') != null){
                                    swrap.totalCostGroup = (Decimal) aggr.get('totalHoursCost');
                                    totalCost = totalCost + (Decimal) aggr.get('totalHoursCost');
                                }
                                else if((Decimal) aggr.get('totalQuantityCost') != null){
                                    swrap.totalCostGroup = (Decimal) aggr.get('totalQuantityCost');
                                    totalCost = totalCost + (Decimal) aggr.get('totalQuantityCost');
                                }
                                else{
                                    swrap.totalCostGroup = 0;
                                }
                                siteWrapperMap.get(String.valueOf(aggr.get('siteName'))).add(swrap);
                            } else {
                                swList = new List<SiteWrapper>();
                                swrap = new SiteWrapper();
                                swrap.groupName = String.valueOf(aggr.get('itemName'));
                                if((Decimal) aggr.get('totalHours') != null){
                                    swrap.totalQuantity  = (Decimal) aggr.get('totalHours');
                                }
                                else if((Decimal) aggr.get('totalQuantity') != null){
                                    swrap.totalQuantity  = (Decimal) aggr.get('totalQuantity');
                                }
                                else{
                                    swrap.totalQuantity = 0;
                                }
                                if((Decimal) aggr.get('totalHoursCost') != null){
                                    swrap.totalCostGroup = (Decimal) aggr.get('totalHoursCost');
                                    totalCost = totalCost + (Decimal) aggr.get('totalHoursCost');
                                }
                                else if((Decimal) aggr.get('totalQuantityCost') != null){
                                    swrap.totalCostGroup = (Decimal) aggr.get('totalQuantityCost');
                                    totalCost = totalCost + (Decimal) aggr.get('totalQuantityCost');
                                }
                                else{
                                    swrap.totalCostGroup = 0;
                                }
                                swList.add(swrap);
                                siteWrapperMap.put(String.valueOf(aggr.get('siteName')), swList);
                            }
                        }
                    }
                    
                    //For Site Wrapper PDF
                    if(dailyReportItemsList != null && !dailyReportItemsList.isEmpty() && (Test.isRunningTest() || ApexPages.currentPage().getUrl().containsIgnoreCase('pdf'))){
                        for(Daily_Report_Item__c dritm: dailyReportItemsList){
                            swrap2 = new SiteWrapperPdf();
                            if(dritm.Contract_Job_Item__c != null){
                                if(siteWrapperMapPDF.containsKey(dritm.Daily_Report__c) && siteWrapperMapPDF.get(dritm.Daily_Report__c) != null){
                                    swrap2.itemName = dritm.Item_Name__c;
                                    swrap2.rate = dritm.Rate__c;
                                    swrap2.description = dritm.Description__c;
                                    if(dritm.Contract_Job_Item__r.Service_Type__c.containsIgnoreCase('hour')){
                                        swrap2.quantity = dritm.Number_of_Hours__c;
                                    }
                                    else{
                                        swrap2.quantity = dritm.Quantity__c;
                                    }
                                    siteWrapperMapPDF.get(dritm.Daily_Report__c).add(swrap2);
                                }
                                else{
                                    swrap2.itemName = dritm.Item_Name__c;
                                    swrap2.rate = dritm.Rate__c;
                                    swrap2.description = dritm.Description__c;
                                    if(dritm.Contract_Job_Item__r.Service_Type__c.containsIgnoreCase('hour')){
                                        swrap2.quantity = dritm.Number_of_Hours__c;
                                    }
                                    else{
                                        swrap2.quantity = dritm.Quantity__c;
                                    }
                                    siteWrapperMapPDF.put(dritm.Daily_Report__c, new List<SiteWrapperPdf>{swrap2});
                                }
                            }

                        }
                    }
                    
                    //For Site Wrapper PDF
                    if(hseqFormsList != null && !hseqFormsList.isEmpty()){
                        for(HSEQ_Forms__c hsq: hseqFormsList){
                            String recordTypeName = hsq.RecordType.DeveloperName == 'Safe_Operation_Procedure' ? 'SOP Review' : hsq.RecordType.Name;
                            if(hseqRollupMap.containsKey(recordTypeName) && hseqRollupMap.get(recordTypeName) != null){
                                Integer temp = hseqRollupMap.get(recordTypeName) + 1;
                                hseqRollupMap.put(recordTypeName,temp);
                            }
                            else{
                                hseqRollupMap.put(recordTypeName,1);
                            }
                        }
                    }


                    hazardCount =  (hazardCardList != null && hazardCardList.size() > 0) ? hazardCardList.size() : 0 ;
                }
            }
        } catch (Exception e) {
            System.debug('In DailySummaryReport_Controller. At line: ' + e.getLineNumber() + '. Cause: ' + e.getCause() + '. ErrorMessage: ' + e.getMessage());
        }
    }
    
    public class SiteWrapper {
        
        public String groupName { get; set; }
        public Decimal totalQuantity { get; set; }
        //public Decimal totalHours { get; set; }
        public Decimal totalCostGroup { get; set; }
        
    }
    
    public class SiteWrapperPdf {
        
        public String itemName { get; set; }
        public Decimal rate { get; set; }
        public Decimal quantity{ get; set; }
        public String description { get; set; }
        
    }
    
}