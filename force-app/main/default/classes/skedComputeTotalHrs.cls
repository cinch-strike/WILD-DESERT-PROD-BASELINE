//Use by sked_WDR_TotalHrs_trigger
public with sharing class skedComputeTotalHrs {

public WD_Report__c ReturnWDR(List<ServicesReceived__c> listSR, WD_Report__c WDR){

        decimal OperatingHrs = 0;
        decimal RigHrs = 0;
        decimal SBWCHrs = 0;
        decimal SBWOCHrs = 0;
        decimal RepairHrs = 0;
        decimal PMSHrs = 0;
        decimal CrewTravelHrs = 0;
            
            System.debug('***'+listSR);
            for (ServicesReceived__c sr : listSR){
                
                 //Check if record type is not 'Hire/Daily'
                 if(sr.RecordTypeId != '01290000000iGtR'){
                      if (sr.Category__c == 'Operating'){                         
                                    OperatingHrs += sr.Item_total__c;
                      }

                        if (sr.Category__c == 'Rig Move'){
                                    RigHrs += sr.Item_total__c;
                      }

                      if (sr.Category__c == 'SBWC'){
                                   SBWCHrs  += sr.Item_total__c;
                      }
                    
                         if (sr.Category__c == 'SBWOC'){
                                    SBWOCHrs  += sr.Item_total__c;
                      }

                        if (sr.Category__c == 'Repair'){
                                    RepairHrs  += sr.Item_total__c;
                      }

                           if (sr.Category__c == 'Inspection/PMS'){
                                    PMSHrs  += sr.Item_total__c;
                      }

                       if (sr.Category__c == 'Crew Travel'){
                                    CrewTravelHrs  += sr.Item_total__c;
                      }
                 }
            }
            
            WDR.Operating_Hrs__c = OperatingHrs;
            WDR.Rig_Move_Hrs__c = RigHrs;
            WDR.Standby_WC_Hrs__c = SBWCHrs;
            WDR.Standby_WOC_Hrs__c = SBWOCHrs;
            WDR.Repair_Hrs__c = RepairHrs;
            WDR.Inspection_PMS_Hrs__c = PMSHrs;
            WDR.Travel_Hrs__c = CrewTravelHrs;
            
            
    return WDR;
}

}