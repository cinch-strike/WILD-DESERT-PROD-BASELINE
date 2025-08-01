/* Daily Site Job trigger main entry
 * All logic maintained in DailySiteJob Trigger Handler
 * Author: DBC, D Banez
 * Date: April 2020
*/
trigger DailySiteJobTrigger on Daily_Report__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    // Call Daily Site Job Trigger Handler 
    DailySiteJobTriggerHandler.mainEntry(
        Trigger.isBefore, Trigger.isAfter, 
        Trigger.isInsert, Trigger.isUpdate, 
        Trigger.isDelete, Trigger.isUnDelete,  
        Trigger.new, Trigger.old,
        Trigger.newMap, Trigger.oldMap 
    );
}