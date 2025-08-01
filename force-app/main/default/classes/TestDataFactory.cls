/**
 * Created by Captain America on 05-Dec-17.
 */

@isTest
public with sharing class TestDataFactory {

    public Account createAccount() {
        Id clientAccountRecord = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = clientAccountRecord;
        return acc;
    }

    public Contract__c createContract() {
        
        Contact contt = new Contact();
        contt.FirstName = 'FName';
        contt.LastName = 'LName';
        contt.Email = 'test@email.com';
        insert contt;
        
        Contract__c cont = new Contract__c();
        cont.Contract_Start_Date__c = Date.today().addDays(-5);
        cont.Contract_Term_months__c = 1;
        cont.Manager_Ops_Sup__c = UserInfo.getUserId();
        cont.Company_Manager__c = contt.Id;
        return cont;
    }

    public Unit__c createRigUnit() {
        Unit__c unit = new Unit__c();
        unit.Name = 'Test Rig';
        unit.Unit_Type__c = 'Field - Rig';
        unit.Unit_Manager__c = UserInfo.getUserId();
        unit.Manager__c = UserInfo.getUserId();
        return unit;
    }

    public Unit__c createCampUnit() {
        Unit__c unit = new Unit__c();
        unit.Name = 'Test Camp';
        unit.Unit_Type__c = 'Field - Camp';
        unit.Unit_Manager__c = UserInfo.getUserId();
        unit.Manager__c = UserInfo.getUserId();
        return unit;
    }

    public Site__c createSite() {
        Site__c site = new Site__c();
        site.Name = 'Test Site';
        site.State__c = 'QLD';
        site.Site_Active__c = true;
        return site;
    }

    public Daily_Report__c createRigDailyReport() {
        Daily_Report__c dailyReport = new Daily_Report__c();
        dailyReport.Type__c = 'Rig';
        dailyReport.Report_Date__c = System.today();
        dailyReport.Manager__c = UserInfo.getUserId();
        dailyReport.Water_Levels__c = 12;
        dailyReport.Fuel_Levels__c = 12;
        dailyReport.Septic_Levels__c = 12;
        dailyReport.Rubbish_Levels__c = 12;
        dailyReport.Weather__c = 'Great';
        dailyReport.Ops_Sup__c = UserInfo.getUserId();
        dailyReport.Auto_Create_Daily_Report_Items__c = false;
        return dailyReport;
    }
    
    

    public Daily_Report__c createCampDailyReport() {
        Daily_Report__c dailyReport = new Daily_Report__c();
        dailyReport.Type__c = 'Camp';
        dailyReport.Report_Date__c = System.today();
        dailyReport.Manager__c = UserInfo.getUserId();
        dailyReport.Water_Levels__c = 12;
        dailyReport.Fuel_Levels__c = 12;
        dailyReport.Septic_Levels__c = 12;
        dailyReport.Rubbish_Levels__c = 12;
        dailyReport.Weather__c = 'Great';
        dailyReport.Ops_Sup__c = UserInfo.getUserId();
        dailyReport.Auto_Create_Daily_Report_Items__c = false;
        return dailyReport;
    }

    public Item__c createItemCampStandy() {
        Item__c item = new Item__c();
        item.Name = 'Camp Standby';
        item.Active__c = true;
        item.Unit_Type__c = 'Camp';
        item.Service_Type__c = 'Fixed Price/Hour';
        item.Group__c = 'SBWC(Stand By with Crew)';
        item.UOM__c = 'Day';
        //item.Default_Rate_per_UOM__c = 1500.0;
        item.Item_Frequency__c = 'Per Day';
        return item;
    }

    public Item__c createItemRigOperating() {
        Item__c item = new Item__c();
        item.Name = 'Rig Operating';
        item.Active__c = true;
        item.Unit_Type__c = 'Rig';
        item.Service_Type__c = 'Fixed Price/Hour';
        item.Group__c = 'Operating';
        item.UOM__c = 'Hour';
        //item.Default_Rate_per_UOM__c = 1500.0;
        //item.Item_Frequency__c = 'Per Day';
        item.Add_to_NDT__c = true;
        return item;
    }

    public Contract_Item__c createContractJobItem() {
        Contract_Item__c contractJobItem = new Contract_Item__c();
        //Contract__c = cont.Id,
        //contractJobItem.Rate_per_UOM__c = 1500;
        contractJobItem.Rate__c = 1500;
        contractJobItem.Unit_Type__c = 'Camp';
        contractJobItem.UOM__c = 'Litre';
        contractJobItem.Auto_Populate_in_Daily_Report__c = true;
        //contractJobItem.Item_Name__c = item.Id;
        contractJobItem.Service_Type__c = 'Flexi Price/Quantity';
        contractJobItem.Group__c = 'Camp Operations';
        contractJobItem.Item_Frequency__c = 'Per Day';
        contractJobItem.Job_Item_Description__c = 'Recharges for Fuel.  Charge per per well, as litres used on daily reports';
        return contractJobItem;
    }

    public Hazard_Card__c createHazardCard() {
        Hazard_Card__c hazardCard = new Hazard_Card__c(
                Name = '16762',
                Follow_Up_Action__c = 'N/A',
                //Unit__c = '',
                Date__c = System.today(),
                //Reported_By__c = insertemployeeid,
                //Unit_Manager__c = insertemployeeid,
                Hazard_Description__c = 'BOP skid spotted off centre causing kill spool to contact fire extinguisher mounted on skid.',
                Imediate_Actions_Taken__c = 'TBM with crew to explain correct orientation of BOP on skid.',
                Status__c = 'Open',
                Associated_Risks__c = 'Possible damage to fire extinguisher.',
                Operations_at_Time__c = 'Rig Up/Down - Rig',
                Frequency__c = 'Possible',
                Consequence__c = 'Minor',
                Risk_Rating__c = '2',
                Hazard_Type__c = 'Equipment',
                Hazard_Locations__c = 'Other',
                //Site__c = 'a170k0000009tCQAAY',
                Unit_Manager_Report__c = 'The use of a spotter is essential for all loading and unloading operations, to prevent any unnecessary damage, the loader operator cannot see everything.',
                Hazard_Potential__c = 'Equipment Damage'
                //Daily_Site_Job__c = insertDailyjobId
        );

        return hazardCard;
    }

    public HSEQ_Forms__c createHseqForm() {
        HSEQ_Forms__c hseqForm = new HSEQ_Forms__c(
                Date__c = System.today(),
                Attendees__c = 'The Avengers',
                Forms_Attached__c = false,
                Description__c = 'Weekly safety meeting',
                //Unit__c = insertUnitId,
                Comments__c = 'see attachment for R/M comments',
                //Inducted_By__c = insertEmployeeId,
                New_to_Rig__c = false,
                New_to_WD__c = false,
                Visitor__c = false,
                Contractor__c = false,
                sample_test_passed__c = false,
                Client_Inducted__c = false,
                //Site__c = insertSiteId,
                X3rd_Party_Checklist__c = false,
                New_to_Camp__c = false,
                WD_Employee__c = false
                //Daily_Site_Job__c = 'insertDailySIteJobId'
        );
        return hseqForm;
    }

    public Employees__c createEmployee() {
        Employees__c employee = new Employees__c(
            	On_Shift__c = true,
            
                Name = 'Bruce Banner',
                First_Name__c = 'Bruce',
                Last_Name__c = 'Banner',
                Date_of_Birth__c = Date.newInstance(1980, 08, 16),
                Gender__c = 'Male',
                Street_Address__c = 'Str',
                City__c = 'Cit',
                Post_Code__c = '400',
                Mobile__c = '9876543210',
                Personal_Email__c = 'doug@wd.com',
                Emergency_Contact__c = 'EC1',
                Emergency_Cont__c = 'EC3',
                Has_Medical_Condition__c = false,
                Position__c = 'Floorhand',
                Is_Bizlinc_User__c = false,
                X2nd_Emergency_Contact__c = 'EC4',
                X2nd_Emergency_Contact_Number__c = 'EC6',
                EC_1_Mobile__c = 'EC2',
                EC_2_Mobile__c = 'EC5',
                Has_Allergy__c = false,
                Condition_Requires_Medication__c = false,
                Allergy_Requires_Medication__c = false,
                //Assigned_to_Unit__c = campUnit.Id,
                Status__c = 'Active',
                Start_Date__c = Date.newInstance(2017, 08, 01),
                //PositionLookup__c = position.Id,
                State__c = 'QLD',
                Relationship_EC1__c = 'Partner',
                Relationship_EC2__c = 'Partner',
                Pre_employment_Medical__c = false,
                PID_Letter_Uploaded__c = false,
                Shift__c = 'Night');

        return employee;
    }

}