//Use by sked_WDR_PersonnelHrs_trigger   
public with sharing class skedComputePersonnelHrs{

    public WD_Report__c ReturnWDPersonnelHrs(List<WD_Personnel__c> listPersonnel, WD_Report__c WDR){

        try{    
            decimal PersonnelHrs = 0;
                
                for (WD_Personnel__c p : listPersonnel){
                          PersonnelHrs += p.Total_Hours__c;
                }
                
                WDR.Personnel_Hrs__c = PersonnelHrs;
                    
        }catch(Exception e){}
        
        return WDR;
                                
    }
}