public class DailySiteJob_Controller {
    
    public Daily_Report__c dailyReport { get; set; }
    public List<Active_Personnel__c> activePersonnelList { get; set; }
    //public List<Daily_Report_Item__c> dailyReportItemsList { get; set; }
    public Integer tabView { get; set; }
    public String dailyReportJobId;
    public Boolean saveReport { get; set; }
    public Integer nextTab { get; set; }
    public String source { get; set; }
    public boolean hasError { get; set; }
    public boolean showCancelPopup { get; set; }
    public String newHazardUrl { set; }
    public String newHseqUrl { set; }
    public String newWorkOrderUrl { set; }
    public String myReturnUrl;
    public Boolean displayLineField { get; set; }
    public Date reportDateParam { get; set; }
    public Id opsManagerId { get; set; }
    public String managerApprovalNotes {get;set;}
    
    public Boolean isReportDateEditable {
        get {
            //return (dailyReport.Id == null || dailyReport.Status__c == 'Open'); // Brought back to just being able to edit it on report creation
            return (dailyReport.Id == null);
        }
        set;
    }
    
    public Boolean approvalEnabled {
        get {
            Id currentUserId = UserInfo.getUserId(); //Manager_Ops_Sup__c Submitter__c Manager__c
            return (dailyReport.Status__c == 'Submitted' && currentUserId == dailyReport.Manager__c && !dailyReport.isLockedForUnitManager__c);
        }
        set;
    }
    public Boolean isRecordLocked {
        get {
            if (dailyReport.Id != null){
                Id currentUserId = UserInfo.getUserId(); //Manager_Ops_Sup__c Submitter__c Manager__c
                if (currentUserId == dailyReport.Submitter__c && currentUserId != dailyReport.Manager__c){ // if I am submitter but not manager
                    return dailyReport.isLockedForUnitStaff__c;    
                }
                else if (currentUserId == dailyReport.Manager__c){
                    return dailyReport.isLockedForUnitManager__c;
                }
                
                return false;
            }
            else return false;
        }
        set;
    }
    
    public PageReference approveDailySiteJob() {
        dailyReport.Status__c = 'Manager - Approved';
        dailyReport.Unit_Manager_Approval_Notes__c = managerApprovalNotes;
        update dailyReport;
        return new PageReference('/' + dailyReport.Id);
    }
    
    public PageReference rejectDailySiteJob() {
        dailyReport.Status__c = 'Rejected ';
        dailyReport.Unit_Manager_Approval_Notes__c = managerApprovalNotes;
        update dailyReport;
        return new PageReference('/' + dailyReport.Id);
    }
    
    public Boolean isApprovalStatusPending {
        get {
            if (dailyReportJobId != null) {
                List<ProcessInstance> processInstanceList = [SELECT Id,Status, TargetObjectId,CreatedDate FROM ProcessInstance where TargetObjectId = :dailyReportJobId ORDER BY CREATEDDATE DESC];
                if (!processInstanceList.isEmpty()) {
                    Boolean approvalStatus = false;
                    approvalStatus = (processInstanceList[0].Status == 'Approved' || processInstanceList[0].Status == 'Rejected' || processInstanceList[0].Status == 'Removed') ? false : true;
                    return approvalStatus;
                } else {
                    return false;
                }
            } else {
                return false;
            }
            
        }
    }
    
    
    public DailySiteJob_Controller() {
        system.debug('--DailySiteJob_Controller Start--');
        dailyReportJobId = ApexPages.currentPage().getParameters().get('siteJobId');
        String tabV = ApexPages.currentPage().getParameters().get('tabView');
        tabView = tabV != null && tabV != '' ? Integer.valueOf(tabV) : 1;
        managerApprovalNotes = null;
        myReturnUrl = ApexPages.currentPage().getParameters().get('retURL');
        system.debug('myReturnUrl: ' + myReturnUrl);
        if (String.isNotBlank(myReturnUrl) && myReturnUrl.contains('visual.force.com/')) {
            system.debug('contains visual.force.com');
            Integer indexOfRetUrl = myReturnUrl.indexOf('com/');
            myReturnUrl = myReturnUrl.substring(indexOfRetUrl + 4);
        }
        
        /*String originalReturnUrl = ApexPages.currentPage().getParameters().get('originalRetUrl');
        system.debug('originalReturnUrl: ' + originalReturnUrl);
        if(String.isNotBlank(originalReturnUrl)){
        myReturnUrl = originalReturnUrl;
        }*/
        
        if (String.isBlank(myReturnUrl)) {
            system.debug('myReturnUrl blank');
            myReturnUrl = dailyReportJobId;
        }
        
        validateRetURL();
        
        system.debug('myReturnUrl: ' + myReturnUrl);
        
        if (dailyReportJobId == 'none' || dailyReportJobId == null) {
            reportDateParam = System.today();
            dailyReport = new Daily_Report__c();
            dailyReport.Status__c = 'Open';
            dailyReport.Auto_Create_Daily_Report_Items__c = true;
            //dailyReport.Report_Date__c = System.today();
            String siteId = ApexPages.currentPage().getParameters().get('siteId');
            if (siteId != 'null') {
                dailyReport.Site__c = siteId;
                Site__c siteRecord = [Select Id,Job_Description__c,No_of_KM_s_from_Previous_Site__c,Previous_Site__c from Site__c where Id =:siteId LIMIT 1];
                dailyReport.Description__c = siteRecord.Job_Description__c;
                dailyReport.No_of_KM_s_from_Previous_Site__c = siteRecord.No_of_KM_s_from_Previous_Site__c;
                dailyReport.Previous_Site__c = siteRecord.Previous_Site__c;
            }
            String contractId = ApexPages.currentPage().getParameters().get('contractId');
            if (contractId != 'null') {
                dailyReport.Contract__c = contractId;
            }
            String unitId = ApexPages.currentPage().getParameters().get('unitId');
            if (unitId != 'null') {
                dailyReport.Unit__c = unitId;
            }
            String unitType = ApexPages.currentPage().getParameters().get('unitType');
            if (unitType != 'null') {
                dailyReport.Type__c = unitType;
            }
            Id unitManagerId = UserInfo.getUserId();
            List<Unit__c> unitList = [Select Id,Unit_Manager__c,UnitType__c,Site__c,Contract_New__c from Unit__c where Unit_Manager__c = :unitManagerId];
            if (unitList != null && unitList.size() == 1) {
                dailyReport.Unit__c = unitList[0].Id;
                dailyReport.Type__c = unitList[0].UnitType__c != null && unitList[0].UnitType__c != '' ? unitList[0].UnitType__c : null;
                dailyReport.Contract__c = unitList[0].Contract_New__c != null ? unitList[0].Contract_New__c : null;
                dailyReport.Site__c = unitList[0].Site__c != null ? unitList[0].Site__c : null;
            }
            
        } else {
            dailyReport = [
                SELECT Auto_Create_Daily_Report_Items__c,Contract__c,Contract__r.Manager_Ops_Sup__c, Description__c,Id,Incident_Notes__c,Site__r.Name,Site__r.Id,Unit__r.Name,Unit__r.Id,
                Incident_Occurred__c,Line_on_Spool__c,Line_Slipped__c,Name,No_of_KM_s_from_Previous_Site__c,Contract__r.Contract_Active__c,Daily_Summary_Report__c,Previous_Site__c,
                Daily_Summary_Report__r.Status__c, Report_Date__c,Site__c,Status__c,Type__c,Unit__c,Weather__c,Total_Fuel_Used__c,Water_Levels__c,Fuel_Levels__c,Fuel_Delivered__c, Septic_Levels__c,Rubbish_Levels__c,
                OwnerId, isLockedForUnitManager__c, isLockedForUnitStaff__c, Manager__c, Submitter__c, Site_ID__c, Unit_ID__c
                FROM Daily_Report__c
                where Id = :dailyReportJobId
            ];
            
            fetchActivePersonnels();
            opsManagerId = dailyReport.Contract__r.Manager_Ops_Sup__c;
        }
        
        if (opsManagerId == null && dailyReport.Contract__c != null) {
            opsManagerId = [Select Id,Manager_Ops_Sup__c from Contract__c where Id = :dailyReport.Contract__c].Manager_Ops_Sup__c;
        }
        displayLineFields();
    }
    
    public void validateRetURL() {
        try {
            system.debug('myReturnUrl: ' + myReturnUrl);
            if(myReturnUrl.indexOf('/',0) != -1){
                system.debug('contains /');
                myReturnUrl = myReturnUrl.removeStart('/');
                system.debug('myReturnUrl: ' + myReturnUrl);
            }
            //Id.valueof(myReturnUrl);
            //myReturnUrl = '/' + myReturnUrl;
        } catch (Exception e) {
            System.debug('In apex class DailySiteJob_Controller. At line ' + e.getLineNumber() + '. Cause: ' + e.getCause() + '. ErrorMessage: ' + e.getMessage());
        }
    }
    public PageReference saveSiteJob() {
        
        hasError = false;
        try {
            Integer currentTabView = ApexPages.currentPage().getParameters().get('tabView') != null ? Integer.valueOf(ApexPages.currentPage().getParameters().get('tabView')) : 1;
            if (saveReport == true) {
                //If saveReport is true and dailyreport is not null then redirect to daily report standard page
                if (dailyReportJobId != null) {
                    try {
                        if (currentTabView == 1) {
                            if (dailyReport.Status__c == 'Submitted' || !isRecordLocked){
                                upsert dailyReport;
                            }
                            else if (dailyReport.Status__c == 'Open' || dailyReport.Status__c == 'Rejected') {
                                upsert dailyReport;
                            }
                            
                            
                        } /*else if (currentTabView == 2) {

                    }*/ else if (currentTabView == 3) {
                        
                        if (activePersonnelList != null && !activePersonnelList.isEmpty()) {
                            List<Active_Personnel__c> activePersonnelListFinal = new List<Active_Personnel__c>();
                            for (Active_Personnel__c ap : activePersonnelList) {
                                if (ap.Employees__c != null) {
                                    activePersonnelListFinal.add(ap);
                                }
                            }
                            if (!activePersonnelListFinal.isEmpty()) {
                                if (dailyReport.Status__c == 'Open' || dailyReport.Status__c == 'Rejected') {
                                    upsert activePersonnelListFinal;
                                }
                            }
                        }
                    } else if (currentTabView == 4) {
                        if (dailyReport.Status__c == 'Open' || dailyReport.Status__c == 'Rejected') {
                            upsert dailyReport;
                        }
                    }
                        if (source == 'saveandClose') {
                            
                        } else {
                            PageReference pg = new PageReference('/apex/DailySiteJob_VF?siteJobId=' + dailyReport.Id + '&tabView=' + currentTabView + '&retURL=' + myReturnUrl);
                            pg.setRedirect(true);
                            return pg;
                        }
                    } catch (DMLException e) {
                        hasError = true; getErrorMessage(e.getDmlMessage(0));
                    } catch (Exception e) {
                        hasError = true; ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + e));
                    }
                }
                // saveReport is true and dailyReport id is null then insert report and redirect to vf page's first tab
                else {
                    try {
                        insert dailyReport;
                        if (opsManagerId == null && dailyReport.Contract__c != null) {
                            opsManagerId = [Select Id,Manager_Ops_Sup__c from Contract__c where Id = :dailyReport.Contract__c].Manager_Ops_Sup__c;
                        }
                        dailyReportJobId = dailyReport.Id;
                        if (source != 'saveandClose' && source != 'saveandSubmit') {
                            PageReference pg = new PageReference('/apex/DailySiteJob_VF?siteJobId=' + dailyReport.Id + '&tabView=' + currentTabView + '&retURL=' + myReturnUrl);
                            pg.setRedirect(true);
                            return pg;
                        }
                    } catch (DMLException e) {
                        hasError = true; getErrorMessage(e.getDmlMessage(0));
                    } catch (Exception e) {
                        hasError = true; ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + e));
                    }
                }
            }
        } catch (Exception e) {
            hasError = true; ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + e));
        } return null;
    }
    
    private void getErrorMessage(string message) {
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        
        boolean b = false;
        for (Apexpages.Message msg : msgs) {
            if (msg.getDetail().contains(message)) {
                b = true;
                break;
            }
        }
        if (!b) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + message));
        }
        
    }
    
    public PageReference SaveandNext() {
        try {
            hasError = false;
            if (saveReport == false) {
                saveReport = true;
                saveSiteJob();
                if (!hasError) {
                    Integer currentTabView = ApexPages.currentPage().getParameters().get('tabView') != null ? Integer.valueOf(ApexPages.currentPage().getParameters().get('tabView')) : 1;
                    Integer nextTabview = source == 'tab' ? nextTab : currentTabView + 1;
                    PageReference redirectToPage = new PageReference('/apex/DailySiteJob_VF?siteJobId=' + dailyReport.Id + '&tabView=' + nextTabview + '&retURL=' + myReturnUrl);
                    redirectToPage.setRedirect(true);
                    return redirectToPage;
                }
            }
        } catch (Exception e) {
            hasError = true; ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + e));
        } return null;
    }
    
    public PageReference SaveandClose() {
        try {
            hasError = false;
            saveSiteJob();
            if (!hasError) {
                PageReference pgRef = new PageReference(myReturnUrl);
                pgRef.setRedirect(true);
                return pgRef;
            }
        } catch (Exception e) {
            hasError = true; ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + e));
        } return null;
    }
    
    public Boolean validateJobItemInputField(){
        Boolean valid = true;
        List<Daily_Report_Item__c> dailyReportItemList = [Select Id,Contract_Job_Item__c,StartTime__c,EndTime__c,Contract_Job_Item__r.Service_Type__c,Quantity__c from Daily_Report_Item__c where Daily_Report__c = :dailyReportJobId AND Contract_Job_Item__c != null AND Contract_Job_Item__r.Service_Type__c != null];
        if(!dailyReportItemList.isEmpty()){
            for(Daily_Report_Item__c item: dailyReportItemList){
                if(item.Contract_Job_Item__r.Service_Type__c.contains('Hour')){
                    if(item.StartTime__c == null || item.EndTime__c == null){
                        valid = false; break;}
                } else if(item.Contract_Job_Item__r.Service_Type__c.contains('Quantity')){
                    if(item.Quantity__c == null){
                        valid = false; break; }
                }
            }
        } else { valid = false;}
        return valid;
    }
    
    public PageReference SaveandSubmit() {
        String dailyReportStatusPriorValue;
        try {
            system.debug('valid: ' + validateJobItemInputField());
            if(!validateJobItemInputField()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Oops! Its mandatory to fill in the Start Time, End Time or Quantity for the Site Job Items before the report can be Submitted for Approval.'));
                return null;
            }
            hasError = false;
            dailyReportStatusPriorValue = dailyReport.Status__c;
            system.debug(LoggingLevel.ERROR, '## water levels: ' + dailyReport.Water_Levels__c);
            if (!isApprovalStatusPending && !isRecordLocked && (dailyReport.Status__c == 'Open' || dailyReport.Status__c == 'Rejected')) dailyReport.Status__c = 'Submitted';
            upsert dailyReport;
            if (!hasError) {
                //PageReference pgRef = new PageReference(myReturnUrl); pgRef.setRedirect(true); return null;
                PageReference pRef = Page.DailySiteJob_VF;
                pRef.getParameters().put('siteJobId', dailyReport.Id);
                pRef.getParameters().put('tabView', '6');
                
                pRef.setRedirect(true);
                return pRef;
            }
        } catch (DMLException e) { dailyReport.Status__c = dailyReportStatusPriorValue; hasError = true; getErrorMessage(e.getDmlMessage(0));} return null;
    }
    
    public String fetchDailySummaryReportStatus(){
        String dailyReportStatus = '';
        List<Daily_Summary_Report__c> dailySummaryReport = [Select Id,Status__c from Daily_Summary_Report__c where Summary_Report_Date__c =: dailyReport.Report_Date__c AND Contract__c =: dailyReport.Contract__c AND Site__c =: dailyReport.Site__c];
        if(!dailySummaryReport.isEmpty()){ dailyReportStatus = dailySummaryReport[0].Status__c; }
        return dailyReportStatus;
    }
    
    public PageReference closeSiteJob() {
        system.debug('closeSiteJob called');
        try {
            Pagereference redirectToPage;
            if (dailyReportJobId != null) {
                redirectToPage = new PageReference(myReturnUrl);
            } else {
                Schema.DescribeSObjectResult anySObjectSchema = Daily_Report__c.SObjectType.getDescribe();
                String objectIdPrefix = anySObjectSchema.getKeyPrefix();
                redirectToPage = new PageReference(myReturnUrl);
            }
            redirectToPage.setRedirect(true);
            return redirectToPage;
        } catch (Exception e) {
            system.debug('Error: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + e));
            return null;
        } 
    }
    
    public pageReference showCancelModal() {
        if (dailyReport.Status__c == 'Open' || dailyReport.Status__c == 'Rejected') {
            showCancelPopup = true;
            return null;
        } else {
            //PageReference pgRef = new PageReference(myReturnUrl);
            PageReference pgRef = new PageReference('/' + dailyReport.Id);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
    }
    
    public void fetchActivePersonnels() {
        try {
            if (dailyReport != null && dailyReport.Id != null) {
                activePersonnelList = new List<Active_Personnel__c>();
                activePersonnelList = [
                SELECT Id, Name, Crew_Change__c, Locale__c, Daily_Report__c, Employees__c, Position__c,Position__r.Name, Employees__r.Shift__c, Employees__r.Name, Personnel_Name__c, Shift__c,Travel_Hrs__c, Work_Hrs__c, RM_Notes__c
                    FROM Active_Personnel__c
                    where Daily_Report__c = :dailyReport.Id
                ];
                if ( (dailyReport.Status__c == 'Open' || dailyReport.Status__c == 'Rejected') && dailyReport.Contract__r.Contract_Active__c) {
                    Active_Personnel__c ap = new Active_Personnel__c();
                    ap.Daily_Report__c = dailyReportJobId;
                    activePersonnelList.add(ap);
                }
            }
        } catch (Exception e) {
            hasError = true; ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + e));
        }
        
    }
    
    public void deleteSelectedActivePersonnel() {
        hasError = false;
        String personId = ApexPages.currentPage().getParameters().get('personnelId');
        try {
            delete new Active_Personnel__c(Id = personId);
        } catch (DMLException e) { hasError = true; getErrorMessage(e.getDmlMessage(0)); } 
        catch (Exception e) { hasError = true; ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + e)); }
        fetchActivePersonnels();
    }
    
    public String getNewHazardUrl() {
        String currentTabView = ApexPages.currentPage().getParameters().get('tabView');
        String UrlToBeRedirectedTo = '/apex/DailySiteJob_VF?siteJobId=' + dailyReport.Id + '&tabView=' + currentTabView + '&retURL=' + myReturnUrl;
        UrlToBeRedirectedTo = EncodingUtil.urlEncode(UrlToBeRedirectedTo, 'UTF-8');
        
        if(UserInfo.getUiThemeDisplayed() == 'Theme2' || UserInfo.getUiThemeDisplayed() == 'Theme3' ){
            String newHazardUrlTemp = 'a19/e?retURL=/a19/o';
            if (dailyReport != null && dailyReport.Id != null) {
                newHazardUrlTemp = 'a19/e?' + Label.HazardCard_UnitField + '=' + dailyReport.Unit__r.Name + '&' + Label.HazardCard_UnitField + '_lkid=' + dailyReport.Unit__c + '&' + Label.HazardCard_DailySiteJobField + '=' + dailyReport.Name + '&' + Label.HazardCard_DailySiteJobField + '_lkid=' + dailyReport.Id + '&' + Label.HazardCard_SiteField + '=' + dailyReport.Site__r.Name + '&' + Label.HazardCard_SiteField + '_lkid=' + dailyReport.Site__c + '&retURL=' + UrlToBeRedirectedTo + '&saveURL=' + UrlToBeRedirectedTo + '&cancelURL=' + UrlToBeRedirectedTo;
                newHazardUrlTemp = newHazardUrlTemp.contains('#') ? newHazardUrlTemp.replace('#','%23') : newHazardUrlTemp;
                return newHazardUrlTemp;
            } else {
                return newHazardUrlTemp;
            }
        }
        else{
            if (dailyReport != null && dailyReport.Id != null) {
                String newHseqUrlTemp = 'lightning/o/Hazard_Card__c/new?nooverride=1&useRecordTypeCheck=1&navigationLocation=RELATED_LIST&backgroundContext=/lightning/r/Daily_Report__c%2F'+dailyReport.Id+'%2Fview'+'&defaultFieldValues=Daily_Site_Job__c='+dailyReport.Id+','+'Unit__c='+dailyReport.Unit__c+','+'Site__c='+dailyReport.Site__c;
                return newHseqUrlTemp;
            } else {
                String newHseqUrlTemp = 'lightning/o/Hazard_Card__c/new?useRecordTypeCheck=1';
                return newHseqUrlTemp;
            }
            
        }
        return null;
    }
    
    public String getNewHseqUrl() {
        String attendeesList = '';
        if (activePersonnelList != null && !activePersonnelList.isEmpty()) {
            List<Active_Personnel__c> activePersonelListTemp = [Select Id,Employees__c,Employees__r.Name from Active_Personnel__c where Id IN :activePersonnelList];
            for (Active_Personnel__c activePersonel : activePersonelListTemp) {
                attendeesList = attendeesList + activePersonel.Employees__r.Name + ';';
            }
        }
        
        String currentTabView = ApexPages.currentPage().getParameters().get('tabView');
        String UrlToBeRedirectedTo = '/apex/DailySiteJob_VF?siteJobId=' + dailyReport.Id + '&tabView=' + currentTabView + '&retURL=' + myReturnUrl;
        UrlToBeRedirectedTo = EncodingUtil.urlEncode(UrlToBeRedirectedTo, 'UTF-8');
        
        if(UserInfo.getUiThemeDisplayed() == 'Theme2' || UserInfo.getUiThemeDisplayed() == 'Theme3' ){
            String newHseqUrlTemp = 'a1L/e?retURL=/a1L/o';
            if (dailyReport != null && dailyReport.Id != null) {
                String tempRecordTypeSelection = 'setup/ui/recordtypeselect.jsp?ent=' + Label.HSEQCustomObjectId + '&retURL=' + UrlToBeRedirectedTo + '&save_new_url=' + EncodingUtil.urlEncode('/a1L/e?' + '&retURL=' + UrlToBeRedirectedTo + '&saveURL=' + UrlToBeRedirectedTo + '&cancelURL=' + UrlToBeRedirectedTo, 'UTF-8');
                String reportDateString = dailyReport.Report_Date__c.day() + '/' + dailyReport.Report_Date__c.month() + '/' + dailyReport.Report_Date__c.year();
                newHseqUrlTemp = tempRecordTypeSelection + '&' + Label.Hseq_UnitField + '=' + dailyReport.Unit__r.Name + '&' + Label.Hseq_UnitField + '_lkid=' + dailyReport.Unit__c + '&' + Label.Hseq_DailySiteJobField + '=' + dailyReport.Name + '&' + Label.Hseq_DailySiteJobField + '_lkid=' + dailyReport.Id + '&' + Label.Hseq_SiteField + '=' + dailyReport.Site__r.Name + '&' + Label.Hseq_SiteField + '_lkid=' + dailyReport.Site__c + '&' + Label.HSEQAttendeesCustomField + '=' + attendeesList + '&00N9000000BEr31=' + reportDateString ;
                newHseqUrlTemp = newHseqUrlTemp.contains('#') ? newHseqUrlTemp.replace('#','%23') : newHseqUrlTemp;
                return newHseqUrlTemp;
            } else {
                return newHseqUrlTemp;
            }
        }
        else{
            if (dailyReport != null && dailyReport.Id != null) {
                String reportDateString = dailyReport.Report_Date__c.day() + '/' + dailyReport.Report_Date__c.month() + '/' + dailyReport.Report_Date__c.year();
                String newHseqUrlTemp = 'lightning/o/HSEQ_Forms__c/new?nooverride=1&useRecordTypeCheck=1&navigationLocation=RELATED_LIST&backgroundContext=/lightning/r/Daily_Report__c%2F'+dailyReport.Id+'%2Fview'+'&defaultFieldValues=Daily_Site_Job__c='+dailyReport.Id+','+'Unit__c='+dailyReport.Unit__c+','+'Site__c='+dailyReport.Site__c + ','+'Attendees__c='+attendeesList +','+'Date__c=' + dailyReport.Report_Date__c;
                return newHseqUrlTemp;
            } else {
                String newHseqUrlTemp = 'lightning/o/HSEQ_Forms__c/new?useRecordTypeCheck=1';
                return newHseqUrlTemp;
            }
            
        }
        return null;
    }
    
    public String getNewWorkOrderUrl() {
        String currentTabView = ApexPages.currentPage().getParameters().get('tabView');
        String UrlToBeRedirectedTo = '/apex/DailySiteJob_VF?siteJobId=' + dailyReport.Id + '&tabView=' + currentTabView + '&retURL=' + myReturnUrl;
        UrlToBeRedirectedTo = EncodingUtil.urlEncode(UrlToBeRedirectedTo, 'UTF-8');
        
        if(UserInfo.getUiThemeDisplayed() == 'Theme2' || UserInfo.getUiThemeDisplayed() == 'Theme3' ){
            String newWorkOrderUrlTemp = 'a1D/e?retURL=/a1D/o';
            if (dailyReport != null && dailyReport.Id != null) {
                String tempRecordTypeSelection = 'setup/ui/recordtypeselect.jsp?ent=' + Label.WorkOrderCustomObjectId + '&retURL=' + UrlToBeRedirectedTo + '&save_new_url=' + EncodingUtil.urlEncode('a1D/e?' + '&retURL=' + UrlToBeRedirectedTo + '&saveURL=' + UrlToBeRedirectedTo + '&cancelURL=' + UrlToBeRedirectedTo, 'UTF-8') ;
                newWorkOrderUrlTemp = tempRecordTypeSelection + '&' + Label.WorkOrder_UnitField + '=' + dailyReport.Unit__r.Name + '&' + Label.WorkOrder_UnitField + '_lkid=' + dailyReport.Unit__c + '&' + Label.WorkOrder_DailySiteJobField + '=' + dailyReport.Name + '&' + Label.WorkOrder_DailySiteJobField + '_lkid=' + dailyReport.Id + '&' + Label.WorkOrder_SiteField + '=' + dailyReport.Site__r.Name + '&' + Label.WorkOrder_SiteField + '_lkid=' + dailyReport.Site__c;
                newWorkOrderUrlTemp = newWorkOrderUrlTemp.contains('#') ? newWorkOrderUrlTemp.replace('#','%23') : newWorkOrderUrlTemp;
                return newWorkOrderUrlTemp;
            } else {
                return newWorkOrderUrlTemp;
            }
        }
        else{
            if (dailyReport != null && dailyReport.Id != null) {
                String newHseqUrlTemp = 'lightning/o/Job_Cards__c/new?nooverride=1&useRecordTypeCheck=1&navigationLocation=RELATED_LIST&backgroundContext=/lightning/r/Daily_Report__c%2F'+dailyReport.Id+'%2Fview'+'&defaultFieldValues=Daily_Site_Job__c='+dailyReport.Id+','+'Unit__c='+dailyReport.Unit__c+','+'Site__c='+dailyReport.Site__c;
                return newHseqUrlTemp;
            } else {
                String newHseqUrlTemp = 'lightning/o/Job_Cards__c/new?useRecordTypeCheck=1';
                return newHseqUrlTemp;
            }
        }
        return null;
    }
    
    
    public void displayLineFields() {
        displayLineField = dailyReport.Type__c != null && dailyReport.Type__c == 'Rig' ? true : false;
    }
    
}