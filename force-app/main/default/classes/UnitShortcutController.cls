public with sharing class UnitShortcutController {
	@AuraEnabled
    public static Id getUnitId(){
        List<Unit__c> unitManagedList = [select Id from Unit__c where Unit_Manager__c = :UserInfo.getUserId() limit 1];
        return (unitManagedList.size() > 0) ? unitManagedList[0].Id : null;
    }
    
    @AuraEnabled
    public static String getUnitName(){
        List<Unit__c> unitManagedList = [select Id, Name from Unit__c where Unit_Manager__c = :UserInfo.getUserId() limit 1];
        return (unitManagedList.size() > 0) ? unitManagedList[0].Name : null;
    }
    
    @AuraEnabled
    public static String getActiveOnshiftEmployees(){
        List<Unit__c> unitManagedList = [select Id, Name, (select Id from Employees__r where Status__c ='Active' and On_Shift__c = true) 
                                         from Unit__c where Unit_Manager__c = :UserInfo.getUserId() limit 1];
        return (unitManagedList.size() > 0) ? String.valueOf(unitManagedList[0].Employees__r.size()) : '0';
        
    }
}