/* Driver Assignment trigger main entry
 * All logic maintained in Driver Assignment Trigger Handler
 * Author: DBC, D Banez
 * Date: September 2020
*/
trigger DriverAssignmentTrigger on Driver_Assignment__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    // Call Driver Assignment Trigger Handler 
    DriverAssignmentTriggerHandler.mainEntry(
        Trigger.isBefore, Trigger.isAfter, 
        Trigger.isInsert, Trigger.isUpdate, 
        Trigger.isDelete, Trigger.isUnDelete,  
        Trigger.new, Trigger.old,
        Trigger.newMap, Trigger.oldMap 
    );
}