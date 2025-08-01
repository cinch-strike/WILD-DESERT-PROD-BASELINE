//Utility class to Create sample records for various test classes.
public class InilitizeTestData{
    //Method to find record type id of "Asset" records by passing record type name.
    public static Id findRecordTypeId(string recordTypeName){
        Schema.DescribeSObjectResult assetSchema = Schema.SObjectType.Asset__c; 
        Map<String,Schema.RecordTypeInfo> AssetRecordTypeInfo = assetSchema.getRecordTypeInfosByName();
        return AssetRecordTypeInfo.get(recordTypeName).getRecordTypeId();
    }
    //Method to create asset record of record type "Light Vehicles","Cranes","Non-Vehicle Engine","Rigs".
    public static Asset__c createAsset(string assetName,string Id,string recordtypename,Integer odometerReading,Integer lastServiceKm ){
        Asset__c asset = new Asset__c();
        asset.Name=assetName;
        asset.Asset_ID_Number__c=Id;
        asset.RecordTypeId =findRecordTypeId(recordtypename);
        asset.Current_Odometer_Reading__c=odometerReading;
        asset.Last_Service_Km__c=lastServiceKm ;
        return asset;
    }
    //Method to create asset record of record type "Dollies","Forklifts","Loaders","Prime Mover","Trailer".
    public static Asset__c createAssetOfCranes(string assetName,string Id,string recordtypename,Integer engineHrs,Integer lastServicHrs ){
        Asset__c asset = new Asset__c();
        asset.Name=assetName;
        asset.Asset_ID_Number__c=Id;
        asset.RecordTypeId =findRecordTypeId(recordtypename);
        asset.Engine_Hours__c=engineHrs;
        asset.Last_Service_Hrs__c=lastServicHrs ;
        return asset;
    }
    public static Asset__c createAssetChildRecord(string assetName,string Id,string recordtypename,Id parentId){
        Asset__c asset = new Asset__c();
        asset.Name=assetName;
        asset.Asset_ID_Number__c=Id;
        asset.RecordTypeId =findRecordTypeId(recordtypename);
        asset.Parent_Asset__c = parentId;
        return asset;
    }
    public static Asset__c createParentAssetRecord(string assetName,string Id,string recordtypename,Id unitId){
        Asset__c asset = new Asset__c();
        asset.Name=assetName;
        asset.Asset_ID_Number__c=Id;
        asset.RecordTypeId =findRecordTypeId(recordtypename);
        asset.Unit__c=unitId;
        return asset;
    }
    public static Account createAccount(string name){
        Schema.DescribeSObjectResult assetSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = assetSchema.getRecordTypeInfosByName();
        Account acc = new Account();
        acc.name=name;
        acc.RecordTypeId=AccountRecordTypeInfo.get('Client').getRecordTypeId();
        return acc;
    }
    public static Site__c createSite(string siteName,string relatedClient){
        Site__c testSite = new Site__c();
        testSite.Name= siteName;
        testSite.Account__c = relatedClient;
        return testSite;
    }
    public static Unit__c createUnit(string unitName,string relatedSite){
        Unit__c unit = new Unit__c ();
        unit.Name=unitName;
        unit.Site__c=relatedSite;
        return unit;
    }
    
    //Additional test data creator methods added for wild desert HR module impletations.
    
    public static Position__c createPosition(string posName){
        Position__c p= new Position__c();
        p.Name = posName;
        return p;
    }
    public static Professional_Development__c createPersonalDevType(string pdtName,Integer daysUntilRenewalReq){
        Professional_Development__c  pdt = new Professional_Development__c ();
        pdt.Name =pdtName;
        pdt.Days_until_renewal_is_required__c =daysUntilRenewalReq;
        return pdt; 
         
    }
    public static Professional_Development__c createProfDevRecord(string pdtName,string accountId){
    	 Professional_Development__c  pdt = new Professional_Development__c ();
         pdt.Name =pdtName;
         pdt.Required_By__c = accountId;
         pdt.Requirement_Type__c ='Compulsory - All';
         return pdt;
    }
    public static Development_Records__c createDevRecord(string pdtId,string posId,string accId){
        Development_Records__c  newDev = new Development_Records__c();
        newDev.Professional_Development_Type__c = pdtId;
        //newDev.Position__c = posId;
        //newDev.Client__c = accId;
        newDev.Status__c ='Incomplete';
        return newDev;
    }
     public static Development_Records__c createDevRecordForCloning(string pdtId,string posId,string accId){
        Development_Records__c  newDev = new Development_Records__c();
        newDev.Professional_Development_Type__c = pdtId;
        //newDev.Position__c = posId;
       // newDev.Client__c = accId;
        newDev.Expired__c = false;
        newDev.Status__c ='Complete';
        return newDev;
    }
    public static Employees__c createEmployee(string posId,string unitId,string empName){
        Employees__c  emp = new Employees__c();
        emp.Name = empName;
        emp.PositionLookup__c = posId;
        emp.Assigned_to_Unit__c = unitId;
        emp.First_Name__c ='Test First Name';
        emp.Last_Name__c = 'Test Last Name';
        return emp;    
    
    }
    public static Employees__c createEmployeeForNewTest(string posId,string empName){
    	Employees__c  emp = new Employees__c();
        emp.Name = empName;
        emp.PositionLookup__c =posId;
        emp.First_Name__c='Test First Name';
        emp.Last_Name__c= 'Test Last Name';
        return emp;
    }
    public static Mandatory_Professional_Development__c createMandDevRecord(String pdType,string mandName,String accId,String posId){
        Mandatory_Professional_Development__c  mandDev = new Mandatory_Professional_Development__c ();
        mandDev.Name = mandName;
        mandDev.Account__c =accId;
        mandDev.Position__c =posId;
        mandDev.Professional_Development__c =pdType;
        return mandDev;
    }


}