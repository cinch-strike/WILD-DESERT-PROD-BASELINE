//Test class to test the use cases of "Asset" object trigger "CreateJobCard". 
@isTest
public class AssetTriggerTest{
    static Asset__c assetRecordOfLightVehicles ;
    static Asset__c assetRecordOfCranes;
    static Asset__c assetRecordOfDollies;
    //Method to create the "Asset" object record 
    private static void init(){
       assetRecordOfLightVehicles = InilitizeTestData.createAsset('testAsset','1234','Light Vehicles',1000,0);
       assetRecordOfCranes = InilitizeTestData.createAssetOfCranes('testasset','2345','Cranes',100,0);
       assetRecordOfDollies = InilitizeTestData.createAsset('testAsset1','2234','Dollies',2000,0);
       database.insert(assetRecordOfLightVehicles);
       database.insert(assetRecordOfCranes );
       database.insert(assetRecordOfDollies);
    }
    //method to test all use cases.
    private static Testmethod void myUnitTest(){
        init();
        Test.startTest();
            assetRecordOfLightVehicles.Current_Odometer_Reading__c=9000;
            update assetRecordOfLightVehicles;
        
            assetRecordOfCranes.Engine_Hours__c=250;
            update assetRecordOfCranes;
            system.assertEquals([select Type_of_Maintenance__c,Record_Count_Cranes__c  from Job_Cards__c where WD_Asset__c=:assetRecordOfCranes.id order by CreatedDate desc ][0].Record_Count_Cranes__c,1);
            
            assetRecordOfDollies.Current_Odometer_Reading__c=20000;
            update assetRecordOfDollies;
       
            assetRecordOfCranes.Engine_Hours__c=500;
            update assetRecordOfCranes;
            //system.assertEquals([select Type_of_Maintenance__c,Record_Count_Cranes__c  from Job_Cards__c where WD_Asset__c=:assetRecordOfCranes.id order by CreatedDate desc ][0].Record_Count_Cranes__c,1);
           
            assetRecordOfDollies.Current_Odometer_Reading__c=50000;
            update assetRecordOfDollies;
            
            assetRecordOfCranes.Engine_Hours__c=750;
            update assetRecordOfCranes;
            
            
            system.assertNotEquals(createJobCardUtility.latestJobCardRecordOfCranes('testid'),null);
            system.assertNotEquals(createJobCardUtility.latestJobCardRecordOfDollies('testid'),null);
          
    
        Test.stopTest();
    }

}