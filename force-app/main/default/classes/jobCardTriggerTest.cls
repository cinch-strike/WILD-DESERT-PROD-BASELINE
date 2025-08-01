//Test Class to test the use cases of "Job Card" object trigger "updateAppropriateAsset".
@isTest
public class jobCardTriggerTest{
    static Asset__c assetRecordOfLightVehicles ;
    static Asset__c assetRecordOfCranes;
    static Asset__c assetRecordOfDollies;
    static Asset__c parentAsset;
    static Asset__c childAsset;
    static Job_Cards__c jobCardOfAssetLightVehicle;
    static Job_Cards__c jobCardOfAssetCranes;
    static Job_Cards__c jobCardOfAssetDollies;
    static Account testAccountforSite;
    static Site__c testSite;
    static Unit__c testUnit;
    static Unit__c testUnit1;
    //Method to create the "Asset" object record. 
    private static void init(){
       assetRecordOfLightVehicles = InilitizeTestData.createAsset('testAsset','1234','Light Vehicles',1000,0);
       assetRecordOfCranes = InilitizeTestData.createAssetOfCranes('testasset','2345','Cranes',25,0);
       assetRecordOfDollies = InilitizeTestData.createAsset('testAsset1','2234','Dollies',2000,0);
       
       database.insert(assetRecordOfLightVehicles);
       database.insert(assetRecordOfCranes );
       database.insert(assetRecordOfDollies);
       testAccountforSite =InilitizeTestData.createAccount('testAccount');
       database.insert(testAccountforSite);
       
       testSite=InilitizeTestData.createSite('testSite',testAccountforSite.id);
       database.insert(testSite);
       testUnit = InilitizeTestData.createUnit('testUnit',testSite.id);
       database.insert(testUnit);
       testUnit1=InilitizeTestData.createUnit('testUnit1',testSite.id);
       database.insert(testUnit1);
       parentAsset=InilitizeTestData.createParentAssetRecord('parentasset','1234','Light Vehicles',testUnit.id);
       database.insert(parentAsset);
       childAsset=InilitizeTestData.createAssetChildRecord('childasset','2345','Light Vehicles',parentAsset.id);
       database.insert(childAsset);
       assetRecordOfLightVehicles.Current_Odometer_Reading__c=10000;
       assetRecordOfCranes.Engine_Hours__c=250;
       assetRecordOfDollies.Current_Odometer_Reading__c=20000;
       update assetRecordOfLightVehicles;
       update assetRecordOfCranes;
       update assetRecordOfDollies; 
    }
    //method to test all use cases.
    public static TestMethod void myUnitTest(){
        init();
        test.startTest();
        jobCardOfAssetLightVehicle=[select id,Status__c from Job_Cards__c where WD_Asset__c=:assetRecordOfLightVehicles.id];
        jobCardOfAssetCranes=[select id,Status__c from Job_Cards__c where WD_Asset__c=:assetRecordOfCranes.id];
        jobCardOfAssetDollies=[select id,Status__c from Job_Cards__c where WD_Asset__c=:assetRecordOfDollies.id];
        
        jobCardOfAssetLightVehicle.Status__c='Completed';
        update jobCardOfAssetLightVehicle;
        jobCardOfAssetCranes.Status__c='Completed';
        update jobCardOfAssetCranes;
        jobCardOfAssetDollies.Status__c='Completed';
        update jobCardOfAssetDollies;
        system.assertEquals([select Last_Service_Km__c from Asset__c where id=:assetRecordOfLightVehicles.id][0].Last_Service_Km__c,10000);
        system.assertEquals([select Last_Service_Hrs__c from Asset__c where id=:assetRecordOfCranes.id][0].Last_Service_Hrs__c ,250);
        system.assertEquals([select Last_Service_Km__c from Asset__c where id=:assetRecordOfDollies.id][0].Last_Service_Km__c,20000);
        system.assertEquals([select Unit__c from Asset__c where id=:parentAsset.id][0].Unit__c ,[select Unit__c from Asset__c where id=:childAsset.id][0].Unit__c);
        
        parentAsset.Unit__c =testUnit1.id;
        update parentAsset;
        system.assertEquals([select Unit__c from Asset__c where id=:parentAsset.id][0].Unit__c ,[select Unit__c from Asset__c where id=:childAsset.id][0].Unit__c);
        test.stopTest();
    }


}