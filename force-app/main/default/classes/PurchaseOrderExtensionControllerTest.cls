/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PurchaseOrderExtensionControllerTest {

    private static List<Account> accountList = new List<Account>();
    private static List<Mandatory_Professional_Development__c> accDevRecList = new List<Mandatory_Professional_Development__c>();
    private static List<Site__c> siteList = new List<Site__c>();
    private static List<Unit__c> unitList = new List<Unit__c>();
    
    private static List<Employees__c> employeeList = new List<Employees__c>();
    public static database.saveResult[] employeeSaveResult;
    public static database.saveResult[] positionDevRecSaveResult;
    public static database.saveResult[] unitSaveResult;
    public static database.saveResult[] positionSaveResultList; 
    public static database.saveResult[] siteSaveResultList;
    private static List<Professional_Development__c>  pdtList = new List<Professional_Development__c>();
    private static List<Position__c> positionList = new List<Position__c>();
    private static List<Mandatory_Professional_Development__c > devRecList = new List<Mandatory_Professional_Development__c>();
    
    
    //static biz3__Purchase_Order__c testPO;
    
	
	static biz3__Purchase_Order__c po = new biz3__Purchase_Order__c();
	
    
    static testMethod void setupData() {
     
	
  		// Insert tax code 
  		biz3__Tax_Code__c taxcode = new biz3__Tax_code__c();
  		taxcode.biz3__UniqueName__c = 'G1';
  		taxcode.biz3__Tax_Rate__c = 10;
  		insert taxcode;
   
  		// Create some test accounts
  		Account acc = new Account();
  		acc.Name = 'Test Company';
  		insert acc;
		List<Account> accList = new List<Account>();
	
  
    	// Create some test contacts
       	Contact con = new Contact();
       	con.lastName = 'test';
       	con.AccountId = acc.Id;
        insert con;
        
        List<Contact> conList = new List<Contact>();
  
    	// Create some test Enquiries
  		biz3__Enquiry__c enq = new biz3__Enquiry__c();
  
    	// Create some test items
        biz3__Item__c item = new biz3__Item__c();
        item.biz3__Item_Code__c = 'itemcode';
        item.biz3__Type__c = 'Production';
        item.biz3__List_Price__c = 10;
        item.biz3__List_Tax_Code__c = taxcode.Id;
        item.biz3__I_Sell_This_Item__c = TRUE ;
        
        item.biz3__I_Buy_This_Item__c = TRUE ;
        item.biz3__Buy_Tax_Code__c = taxcode.Id;
        item.biz3__Buy_Price__c = 20;
        insert item;
  
 
    	// Create some test Quotes
    	biz3__Quote__c quote = new biz3__Quote__c();
        quote.biz3__Contact__c = con.id;
        insert quote;
  
  
    	// Create some test Quote Items
    	biz3__Quote_Item__c quoteitem = new biz3__Quote_Item__c();
       
        quoteitem.biz3__Master__c = quote.id;
        quoteitem.biz3__Item__c = item.id;
        quoteitem.biz3__Item_Class__c = 'Production';
        quoteitem.biz3__Item_Type__c = 'Production';
        quoteitem.biz3__Quantity__c = 2;
        insert quoteitem;
        pdtList.add(InilitizeTestData.createPersonalDevType('Test PrfessionalDevelopment1',10));
        pdtList.add(InilitizeTestData.createPersonalDevType('Test PrfessionalDevelopment2',20));
        
        database.saveResult[] profDevTypeSaveResultList = database.insert(pdtList);
        
        positionList.add(InilitizeTestData.createPosition('Test Position 1'));
        positionList.add(InilitizeTestData.createPosition('Test Position 2')); 
        
        positionSaveResultList = database.insert(positionList);
        System.debug('positionSaveResultList-----------:'+positionSaveResultList);
        
        devRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[0].getId(),'Test Mand Pos1',null,positionSaveResultList[0].getId()));
        devRecList.add(InilitizeTestData.createMandDevRecord(profDevTypeSaveResultList[1].getId(),'Test Mand Pos2',null,positionSaveResultList[1].getId()));
        
        positionDevRecSaveResult = database.insert(devRecList);
        
        accountList.add(InilitizeTestData.createAccount('Test Account1'));
        accountList.add(InilitizeTestData.createAccount('Test Account2'));
        
        database.saveResult[] accountSaveResultList = database.insert(accountList);
        
        
        
        siteList.add(InilitizeTestData.createSite('Test Site1',accountSaveResultList[0].getId()));
        siteList.add(InilitizeTestData.createSite('Test Site2',accountSaveResultList[1].getId()));
        
        //database.saveResult[] 
        siteSaveResultList = database.insert(siteList);
        
        unitList.add(InilitizeTestData.createUnit('Test Unit1',siteSaveResultList[0].getId()));
        unitList.add(InilitizeTestData.createUnit('Test Unit2',siteSaveResultList[1].getId()));
        
        unitSaveResult = database.insert(unitList);
        
        
  		Employees__c emp = new Employees__c(
  				Name = 'Test Employee', First_Name__c = 'Test', Last_Name__c = 'Employee',
  				Date_of_Birth__c = Date.valueOf('1970-01-01'), Phone_Number__c = '07 3456 7654',
  				Street_Address__c = '1 Railway St', City__c = 'Brisbane', Post_Code__c = '4000',
  				Personal_Email__c = 'test@example.com', Emergency_Contact__c = 'John Smith',
  				Emergency_Cont__c = '03 3454 3234', Relationship_to_Employee__c = 'Friend', Status__c = 'Active' );
        		emp.PositionLookup__c = positionSaveResultList[0].getId();
        		emp.Assigned_to_Unit__c  = unitSaveResult[0].getId(); 
        
  		insert emp;
  
    	// Create some test Purchase Orders
   		//biz3__Purchase_Order__c po = new biz3__Purchase_Order__c();
    	po.biz3__Contact__c = con.id;
    	po.biz3__Account__c = acc.Id;
    	po.PO_Requested_By__c = emp.Id;
    	insert po;
  
  
    	// Create some test Pruchase Order Items
    	biz3__PO_Item__c poitem = new biz3__PO_Item__c();
        poitem.biz3__Master__c = po.id;
        poitem.biz3__Item__c = item.id;
        poitem.biz3__Item_Class__c = 'Production';
        //poitem.biz3__Item_Type__c = 'Production';
        poitem.biz3__Quantity__c =2;
        insert poitem;
  
    }
 
 
       
    private static testmethod void testController1(){
        //BizTestUtil util = new BizTestUtil();
        setupData();
        
        PurchaseOrderExtensionController c = new PurchaseOrderExtensionController(new ApexPages.StandardController(po));
        
        system.assertEquals( 1, c.POItems.size());
        
        c.saveAll();
        system.assert( ApexPages.getMessages().size() == 0, ApexPages.getMessages() + '');
    }      
        
    private static testmethod void testController2(){
        setupData();
        PurchaseOrderExtensionController c = new PurchaseOrderExtensionController(new ApexPages.StandardController(po));
        
 		system.assertEquals( 1, c.POItems.size());
        
        PageReference pr = c.saveAllAndExit() ;
        system.assert( ApexPages.getMessages().size() == 0, ApexPages.getMessages() + '');
        system.assert( pr != null );
    }
    
    
    
}