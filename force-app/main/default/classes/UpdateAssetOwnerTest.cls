// Test class for UpdateAssetOwner trigger written on Unit
@isTest
public class UpdateAssetOwnerTest{
    private static Testmethod void testMethodForUnitTrigger(){
        Unit__c unt = new Unit__c(Name='Test Unit');
        insert unt;
        Asset__c ast = new Asset__c(Name='Test Asset',Unit__c=unt.Id);
        insert ast;
    }
}