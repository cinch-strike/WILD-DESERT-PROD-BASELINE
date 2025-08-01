@IsTest(SeeAllData=true)
public without sharing class AssetAssignmentControllerTest {
    
    static testmethod void testMethodLookup() {
        
        Transport_Job__c transjob = [SELECT Id FROM Transport_Job__c limit 1];
            
        Test.startTest();
        AssetAssignmentController.getAssetAssignmentList('a0M3H0000002GOZUA2');
        AssetAssignmentController.AssetLookUp('a0M3H0000002GOZUA2');
        AssetAssignmentController.getOdometerReading('a0M3H0000002GOZUA2');
        AssetAssignmentController.getDailyPrestart('a0M3H0000002GOZUA2');
        AssetAssignmentController.getOwnerUnit(transjob.Id);
        AssetAssignmentController.UnitLookUp();
        AssetAssignmentController.AssetOdometerLookUp();
        Test.stopTest();  
        
    }
    
    static testmethod void queryAsCommunityUser(){
        List<Asset_Odometer_Reading__c> assetList = AssetAssignmentController.getOdometerReading(UserInfo.getUserId());
        system.debug(LoggingLevel.DEBUG, '## size ran by admin user: ' + assetList.size());
        List<Asset_Odometer_Reading__c> rawQueryList = [SELECT Id, Asset__c, Asset__r.Name, Current_Odometer__c, Odometer_Today__c, Blank_Odometer_Today_formula__c 
                FROM Asset_Odometer_Reading__c WHERE OwnerId = :UserInfo.getUserId()];
        system.debug(LoggingLevel.DEBUG, '## admin user info get user id: ' + UserInfo.getUserId() );
        system.debug(LoggingLevel.DEBUG, '## size ran by admin user raw query: ' + rawQueryList.size());
        /*User commUser = [select Id from User where IsActive = true and UserType = 'PowerCustomerSuccess' limit 1];
        system.runAs(commUser){
            assetList = AssetAssignmentController.getOdometerReading(commUser.Id);
            system.debug(LoggingLevel.DEBUG, '## size ran by comm user: ' + assetList.size());
            system.debug(LoggingLevel.DEBUG, '## comm user info get user id: ' + UserInfo.getUserId() );
            rawQueryList = [SELECT Id, WD_Asset__c, WD_Asset__r.Name, WD_Asset__r.Current_Odometer_Reading__c, Odometer_Reading__c 
                FROM Asset_Driver_Assignment__c WHERE Driver_Assignment__r.OwnerId = :UserInfo.getUserId()
                AND  Driver_Assignment__r.Driver_Status__c IN ('Assigned','In Progress')];
            
            system.debug(LoggingLevel.DEBUG, '## size ran by comm  user raw query: ' + rawQueryList.size());
        }*/
    }
}