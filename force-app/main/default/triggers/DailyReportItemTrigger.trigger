trigger DailyReportItemTrigger on Daily_Report_Item__c (before insert, after insert, after update, after delete) {


    /*****************************************************************************************
    * Code commented by: Kunal Jain
    * Reason: The handling of Per Day/Per Site Item is now being handled implicitly by visual
    * workflow "Auto Create DR Items & Active Personnels PB Flow".
    * It's also handled when the a Daily Site Job Item is being added.
    ******************************************************************************************/
    /*if(Trigger.isBefore){
        if(Trigger.isInsert){
            DailyReportItem_Handler.preventDailyReportItem(Trigger.new);
        }
    }*/

    if (Trigger.isAfter) {
        if ((Trigger.isInsert || Trigger.isUpdate) && !DailyReportItem_Handler.DailyReportItemTriggerRecursion) {
            DailyReportItem_Handler.addToNdt(Trigger.new);
        }

        if (Trigger.isDelete && !DailyReportItem_Handler.DailyReportItemTriggerRecursion) {
            DailyReportItem_Handler.addToNdt(Trigger.old);
        }
    }

}