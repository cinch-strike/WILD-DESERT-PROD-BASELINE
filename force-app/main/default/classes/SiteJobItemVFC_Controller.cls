public class SiteJobItemVFC_Controller {
    
    //public Daily_Report__c dr { get; set; }
    public string currentLookup { get; set; }
    //public string currentLookup2 {get;set;}
    public List<Contract_Item__c> contractItemsList { get; set; }
    public Boolean displayJobItemLookup { get; set; }
    public List<Daily_Report_Item__c> driList { get; set; }
    public Daily_Report_Item__c siteJobItem { get; set; }
    public String displayItemName { get; set; }
    public Boolean displayInputFields { get; set; }
    public Boolean displaySaveCancel { get; set; }
    public Id driItem;
    public List<Daily_Report_Item__c> driListFinal;
    //public String ContractItemId { get; set; }
    //public String ContractItemName { get; set; }
    public String ContractItemServiceType;
    public boolean intiatedConstructor = false;
    public Boolean showSaveNext { get; set; }
    public Set<Id> contractJobItemIdSetToRemove;
    public String contractJobItemIdStringToRemove { get; set; }
    public String source { get; set; }
    public Boolean showCancelPopup { get; set; }
    public Set<Id> contractJobItemId { get; set; }
    public Map<Id, String> contractJobItemIdFrequencyMap;
    public Boolean quantityHourErrorOccurred;
    public Map<Id, List<Daily_Report_Item__c>> contractJobItemIdDailyReportItemMap;
    public Boolean disableQuantity { get; set; }
    public Boolean disableHour { get; set; }
    public Boolean singleItemView { get; set; }
    //public Boolean hasRecordLocked { get; set; }
    public Integer displayInactiveContract { get; set; } 
    public Boolean userTypeGuest { get; set; }
    public List<Datetime> startDriDateTime {get; set;}
    //public List<Datetime> startDriDateTime {get; set;}
    
    public Id dailyReportId {
        get;
        set {
            dailyReportId = value;
            if (!intiatedConstructor) {
                SiteJobItemVFC_CustomConstructor();
                intiatedConstructor = true;
            }
        }
    }
    
    public SiteJobItemVFC_Controller() {
        this.userTypeGuest = UserInfo.getUserType() == 'Guest' ? true : false;
    }
    
    public Daily_Report__c dr {
        get {
            if (dr == null){
                dr = new Daily_Report__c();
                dr = [Select Id,OwnerId, Contract__c,Type__c,Site__c,Site__r.Name,Unit__c,Unit__r.Name,Status__c,Report_Date__c,Contract__r.Contract_Active__c,
                      isLockedForUnitStaff__c, isLockedForUnitManager__c, Manager__c, Submitter__c
                      from Daily_Report__c where Id = :dailyReportId];
            }
            return dr;
        }
        set;
    }
    
    public Boolean hasRecordLocked {
        get {
            Id currentUserId = UserInfo.getUserId();
            if (dr.Id != null){
                if (currentUserId == dr.Submitter__c && currentUserId != dr.Manager__c){ // if I am submitter but not manager
                    return dr.isLockedForUnitStaff__c;    
                }
                else if (currentUserId == dr.Manager__c){
                    return dr.isLockedForUnitManager__c;
                }
                
                return false;
            }
            else return false;
        }
    }
    
    public void SiteJobItemVFC_CustomConstructor() {
        try {
            displayInactiveContract = 0;
            singleItemView = false;
            setHourQuantityBooleanToFalse(false);
            contractJobItemIdStringToRemove = '(' + '\\\'' + '' +  '\\\')'; 
            contractJobItemIdFrequencyMap = new Map<Id, String>();
            contractJobItemIdDailyReportItemMap = new Map<Id, List<Daily_Report_Item__c>>();
            driItem = ApexPages.currentPage().getParameters().get('driItem');
            currentLookup = '';
            //ContractItemId = '';
            //ContractItemName = '';
            displayItemName = 'Select Item';
            displayJobItemLookup = showSaveNext;
            displayInputFields = showSaveNext;
            displaySaveCancel = false;
            contractJobItemId = new Set<Id>();
            contractJobItemIdSetToRemove = new Set<Id>();
            driListFinal = new List<Daily_Report_Item__c>();
            //dr = [Select Id,Contract__c,Type__c,Site__c,Site__r.Name,Unit__c,Unit__r.Name,Status__c,Report_Date__c,Contract__r.Contract_Active__c from Daily_Report__c where Id = :dailyReportId];
            //hasRecordLocked = Approval.isLocked(dr.Id);
            driList = new List<Daily_Report_Item__c>();
            getSiteJobItems();
            fetchContractJobItemsMap();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error: ' + e));
        }
    }
    
    public void setHourQuantityBooleanToFalse(Boolean boolVal) {
        quantityHourErrorOccurred = boolVal;
        disableHour = boolVal;
        disableQuantity = boolVal;
    }
    
    public void fetchContractJobItemsMap() {
        List<Contract_Item__c> contractItemList = [Select Id,Service_Type__c from Contract_Item__c where Contract__c = :dr.Contract__c AND Service_Type__c != null order by LastModifiedDate desc LIMIT 50000];
        if (!contractItemList.isEmpty()) {
            for (Contract_Item__c contrctItm : contractItemList) {
                contractJobItemIdFrequencyMap.put(contrctItm.Id, contrctItm.Service_Type__c);
            }
        }
    }
    
    
    public void getSiteJobItems() {
        
        if (driItem != null) {
            singleItemView = true;
            driList = [
                SELECT Id,Contract_Job_Item__c, Item_Name__c, Start_Time__c, End_Time__c, Number_of_Hours__c, Quantity__c, WD_Asset__c,RecordTypeId,Contract_Job_Item__r.Name,Daily_Report__c,
                Contract_Job_Item__r.Service_Type__c,Contract_Job_Item__r.Item_Name__r.Name,Description__c,StartTime__c,EndTime__c,Daily_Report__r.Report_Date__c,Daily_Report__r.Type__c,
                Daily_Report__r.Unit__r.Unit_Type__c, // 29 March - exclude Unit Type Transport
                Category__c // 16 Sept: New field added 
                FROM Daily_Report_Item__c
                where Daily_Report__c = :dailyReportId AND Id = :driItem
                ORDER BY Start_Time__c ASC NULLS LAST, End_Time__c ASC NULLS LAST
            ];
            for (Daily_Report_Item__c d : driList) {
                if (d.Start_Time__c != null || d.End_Time__c != null) {
                    if(d.Daily_Report__r.Type__c == 'Transport'){
                    	/*d.StartTime__c  =  d.Start_Time__c.Day()+'/'+ d.Start_Time__c.month()+'/'+d.Start_Time__c.year()+' '+d.Start_Time__c.hour()+':'+d.Start_Time__c.minute() +' AM'; //DateTime.newInstance(d.Daily_Report__r.Report_Date__c, d.Start_Time__c.time());
                    	d.EndTime__c = d.End_Time__c.Day()+'/'+ d.End_Time__c.month()+'/'+d.End_Time__c.year()+' '+d.End_Time__c.hour()+':'+d.End_Time__c.minute() +' AM';*/
                        d.StartTime__c = d.Start_Time__c.format('dd/MM/yyyy h:mm a');
                        d.EndTime__c = d.End_Time__c.format('dd/MM/yyyy h:mm a');
                    }else{
                    	d.StartTime__c = d.Start_Time__c.format('h:mm a');
                    	d.EndTime__c = d.End_Time__c.format('h:mm a');
                    }//d.End_Time__c = DateTime.newInstance(d.Daily_Report__r.Report_Date__c, d.End_Time__c.time());
                    //DateTime newDateTime = DateTime.newInstance(d.Daily_Report__r.Report_Date__c, d.Start_Time__c.time());
                    //driDateTime
                }
            }
            
        } else {
            driList = [
                SELECT Id,Contract_Job_Item__c, Item_Name__c, Start_Time__c, End_Time__c, Number_of_Hours__c, Quantity__c, WD_Asset__c,RecordTypeId,Contract_Job_Item__r.Name,Daily_Report__c,
                Contract_Job_Item__r.Service_Type__c,Contract_Job_Item__r.Item_Name__r.Name,Description__c,StartTime__c,EndTime__c,Daily_Report__r.Report_Date__c,Daily_Report__r.Type__c,
                Daily_Report__r.Unit__r.Unit_Type__c, // 29 March - exclude Unit Type Transport
                Category__c // 16 Sept: New field added 
                FROM Daily_Report_Item__c
                where Daily_Report__c = :dailyReportId
                ORDER BY Start_Time__c ASC NULLS LAST, End_Time__c ASC NULLS LAST
            ];
            for (Daily_Report_Item__c d : driList) {
                if (d.Start_Time__c != null || d.End_Time__c != null) {
                    if(d.Daily_Report__r.Type__c == 'Transport'){
                    	/*d.StartTime__c  =  d.Start_Time__c.Day()+'/'+ d.Start_Time__c.month()+'/'+d.Start_Time__c.year()+' '+d.Start_Time__c.hour()+':'+d.Start_Time__c.minute() +' AM'; //DateTime.newInstance(d.Daily_Report__r.Report_Date__c, d.Start_Time__c.time());
                    	d.EndTime__c = d.End_Time__c.Day()+'/'+ d.End_Time__c.month()+'/'+d.End_Time__c.year()+' '+d.End_Time__c.hour()+':'+d.End_Time__c.minute() +' AM';*/
                        d.StartTime__c = d.Start_Time__c.format('dd/MM/yyyy h:mm a');
                        d.EndTime__c = d.End_Time__c.format('dd/MM/yyyy h:mm a');
                    }else{
                    	d.StartTime__c = d.Start_Time__c.format('h:mm a');
                    	d.EndTime__c = d.End_Time__c.format('h:mm a');
                    }
                }
            }
        }
        
        if (!driList.isEmpty()) {
            for (Daily_Report_Item__c dailyRepItm : driList) {
                if (dailyRepItm.Contract_Job_Item__r.Service_Type__c != null && dailyRepItm.Contract_Job_Item__r.Service_Type__c.contains('Hour')) {
                    if (contractJobItemIdDailyReportItemMap.containsKey(dailyRepItm.Contract_Job_Item__c)) {
                        contractJobItemIdDailyReportItemMap.get(dailyRepItm.Contract_Job_Item__c).add(dailyRepItm);
                    } else {
                        contractJobItemIdDailyReportItemMap.put(dailyRepItm.Contract_Job_Item__c, new List<Daily_Report_Item__c>{
                            dailyRepItm
                                });
                    }
                }
                
            }
        }
        
        fetchContractJobItems();
        displayJobItemLookup = false;
    }
    
    public void createContractJobItemString(Set<Id> contractJobItemIdSet) {
        contractJobItemIdStringToRemove = '(';
        if (!contractJobItemIdSet.isEmpty()) {
            for (Id contractJobItemId : contractJobItemIdSet) {
                contractJobItemIdStringToRemove = contractJobItemIdStringToRemove + '\\\'' + contractJobItemId + '\\\',' ;
            }
        }
        contractJobItemIdStringToRemove = contractJobItemIdStringToRemove.removeEnd(',');
        contractJobItemIdStringToRemove = contractJobItemIdStringToRemove + ')';
        
    }
    
    
    public void fetchContractJobItems() {
        contractJobItemIdSetToRemove = new Set<Id>();
        contractJobItemIdDailyReportItemMap = new Map<Id, List<Daily_Report_Item__c>>();
        List<Daily_Report_Item__c> dailyReportItemList = [
            Select Id,Contract_Job_Item__c,Start_Time__c,End_Time__c,Contract_Job_Item__r.Name,Daily_Report__r.Report_Date__c,Daily_Report__r.Site__c,Item_Frequency__c,Contract_Job_Item__r.Service_Type__c
            from Daily_Report_Item__c
            where
            Daily_Report__r.Contract__c = :dr.Contract__c AND Daily_Report__r.Type__c = :dr.Type__c
        ];
        
        if (!dailyReportItemList.isEmpty()) {
            for (Daily_Report_Item__c dailyReportItm : dailyReportItemList) {
                if (dailyReportItm.Item_Frequency__c == 'Per Day' && dr.Report_Date__c == dailyReportItm.Daily_Report__r.Report_Date__c) {
                    contractJobItemIdSetToRemove.add(dailyReportItm.Contract_Job_Item__c);
                }
                if (dailyReportItm.Item_Frequency__c == 'Per Site' && dr.Site__c == dailyReportItm.Daily_Report__r.Site__c) {
                    contractJobItemIdSetToRemove.add(dailyReportItm.Contract_Job_Item__c);
                }
                
                if (dailyReportItm.Contract_Job_Item__r.Service_Type__c != null && dailyReportItm.Contract_Job_Item__r.Service_Type__c.contains('Hour') && dailyReportItm.Item_Frequency__c == 'Multi Per Day' && dr.Report_Date__c == dailyReportItm.Daily_Report__r.Report_Date__c) {
                    if (contractJobItemIdDailyReportItemMap.containsKey(dailyReportItm.Contract_Job_Item__c)) {
                        contractJobItemIdDailyReportItemMap.get(dailyReportItm.Contract_Job_Item__c).add(dailyReportItm);
                    } else {
                        contractJobItemIdDailyReportItemMap.put(dailyReportItm.Contract_Job_Item__c, new List<Daily_Report_Item__c>{
                            dailyReportItm
                                });
                    }
                }
            }
        }
        
        if (!contractJobItemIdSetToRemove.isEmpty()) {
            createContractJobItemString(contractJobItemIdSetToRemove);
        } else{
            contractJobItemIdStringToRemove = '(' + '\\\'' + '' +  '\\\')';
        } 
        displayJobItemLookup = true;
        List<Contract_Item__c> contractItems = [
            Select Id,Name,Unit_Type__c,Item_Name__c,Item_Name__r.Name,Item_Frequency__c,Group__c,Service_Type__c, WD_Asset__c, WD_Asset_Name__c
            from Contract_Item__c
            where Active__c = true AND Contract__c = :dr.Contract__c AND Id NOT IN :contractJobItemIdSetToRemove order by LastModifiedDate Desc LIMIT 10000 
        ];
        
        if (contractItems != null && !contractItems.isEmpty()) {
            contractItemsList = new List<Contract_Item__c>();
            for (Contract_Item__c citm : contractItems) {
                if (citm.Unit_Type__c != null && dr.Type__c == citm.Unit_Type__c) {
                    contractItemsList.add(citm);
                }
            }
        }
    }
    
    public void hideContractJobItemsModal() {
        displayJobItemLookup = false;
    }
    
    public void clearValues() {
        List<Daily_Report_Item__c> driListTemp = new List<Daily_Report_Item__c>();
        for (Daily_Report_Item__c dailyReportItem : driList) {
            if (dailyReportItem.Id != null) {
                driListTemp.add(dailyReportItem);
            }
        }
        driList.clear();
        driList = new List<Daily_Report_Item__c>();
        driList.addAll(driListTemp);
        
        addNewSiteJobItem();
    }
    
    
    public PageReference saveSiteJobItem() {
        try {
            retainDailyJobItemData();
            Id perHourRecordTypeId = [Select Id,Name from RecordType where SObjectType = 'Daily_Report_Item__c' AND DeveloperName = 'Per_Hour'].Id;
            Id perQuantityRecordTypeId = [Select Id,Name from RecordType where SObjectType = 'Daily_Report_Item__c' AND DeveloperName = 'Per_Quantity'].Id;
            Boolean quantityBool = false;
            Boolean dateBool = false;
            if (!driList.isEmpty()) {
                driListFinal = new List<Daily_Report_Item__c>();
                
                for (Daily_Report_Item__c dri : driList) {
                    if (dri.Contract_Job_Item__c != null) {
                        if ((dri.Contract_Job_Item__r.Service_Type__c != null && dri.Contract_Job_Item__r.Service_Type__c.contains('Hour')) ||
                            (contractJobItemIdFrequencyMap.containsKey(dri.Contract_Job_Item__c) && contractJobItemIdFrequencyMap.get(dri.Contract_Job_Item__c).contains('Hour'))) {
                                
                                if (dri.StartTime__c == null || dri.EndTime__c == null && dri.Daily_Report__r.Unit__r.Unit_Type__c != 'Transport') {
                                    quantityHourErrorOccurred = true;
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Oops! Please, enter values for Start Time / End Time.'));
                                    return null;
                                }
                                
                                if(dri.Start_Time__c != null && dri.End_Time__c != null && dri.Start_Time__c >= dri.End_Time__c && dri.Daily_Report__r.Unit__r.Unit_Type__c != 'Transport'){
                                    quantityHourErrorOccurred = true;
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Oops! Start Time must be greater than End time'));
                                    return null;
                                }
                                
                                if (contractJobItemIdDailyReportItemMap.containsKey(dri.Contract_Job_Item__c) && dri.Daily_Report__r.Unit__r.Unit_Type__c != 'Transport') {
                                    for (Daily_Report_Item__c tempDailyReportItm : contractJobItemIdDailyReportItemMap.get(dri.Contract_Job_Item__c)) {
                                        
                                        if ((dri.Id != null && dri.Id != tempDailyReportItm.Id) || dri.Id == null) {
                                            /*if ((tempDailyReportItm.Start_Time__c == dri.Start_Time__c || tempDailyReportItm.Start_Time__c == dri.End_Time__c)) {
                                                quantityHourErrorOccurred = true;
                                            }*/
                                            if ((tempDailyReportItm.Start_Time__c == dri.Start_Time__c || tempDailyReportItm.End_Time__c == dri.End_Time__c)) {
                                                quantityHourErrorOccurred = true;
                                            }
                                            else if ((dri.Start_Time__c >= tempDailyReportItm.Start_Time__c && dri.End_Time__c <= tempDailyReportItm.End_Time__c)) {
                                                quantityHourErrorOccurred = true;
                                            } else if (dri.Start_Time__c > tempDailyReportItm.Start_Time__c && dri.Start_Time__c < tempDailyReportItm.End_Time__c) {
                                                quantityHourErrorOccurred = true;
                                            } else if (dri.End_Time__c > tempDailyReportItm.Start_Time__c && dri.Start_Time__c < tempDailyReportItm.End_Time__c) {
                                                quantityHourErrorOccurred = true;
                                            }
                                            
                                            if (quantityHourErrorOccurred) {
                                                String errorMessage = '';
                                                if ((dri.Daily_Report__c == tempDailyReportItm.Daily_Report__c) || dri.Id == null) {
                                                    errorMessage = 'Oops! You cannot add same Start Time/End time for the same item. Or the timings cannot be in the time range of a previous added item. Item: ' + tempDailyReportItm.Contract_Job_Item__r.Name;
                                                } else {
                                                    errorMessage = 'Oops! Start/End time for one of the item is already added in the other Daily Site Job report. You cannot add same Start Time/End time for the same item. Or the timings cannot be in the time range of a previous added item. Item: ' + tempDailyReportItm.Contract_Job_Item__r.Name;
                                                }
                                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
                                                return null;
                                            }
                                        }
                                        
                                    }
                                }
                                dri.RecordTypeId = perHourRecordTypeId;
                                driListFinal.add(dri);
                            } else if ((dri.Contract_Job_Item__r.Service_Type__c != null && dri.Contract_Job_Item__r.Service_Type__c.contains('Quantity')) ||
                                       (contractJobItemIdFrequencyMap.get(dri.Contract_Job_Item__c).contains('Quantity'))) {
                                           if (dri.Quantity__c == null) {
                                               quantityHourErrorOccurred = true;
                                               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Oops! Please, enter values for Quantity.'));
                                               return null;
                                           }
                                           
                                           dri.RecordTypeId = perQuantityRecordTypeId;
                                           driListFinal.add(dri);
                                       } else {
                                           driListFinal.add(dri);
                                       }
                        
                    }
                }
                
                if (!driListFinal.isEmpty()) {
                    //if (dr.Status__c == 'Open') {
                    quantityHourErrorOccurred = false;
                    upsert driListFinal;
                    //}
                    
                }
            }
            
            if (source != null && source != '') {
                PageReference pg;
                String retUrl = ApexPages.currentPage().getParameters().get('retURL');
                retUrl = String.isNotBlank(retUrl) ? retUrl : '/' + dailyReportId;
                
                if (source == 'saveAndNext') {
                    pg = new PageReference('/apex/DailySiteJob_VF?siteJobId=' + dailyReportId + '&tabView=' + 3 + '&retUrl=' + retUrl);
                    pg.setRedirect(true);
                    setHourQuantityBooleanToFalse(true);
                    return pg;
                } else if (source == 'save') {
                    pg = new PageReference('/apex/DailySiteJob_VF?siteJobId=' + dailyReportId + '&tabView=' + 2 + '&retUrl=' + retUrl);
                    pg.setRedirect(true);
                    setHourQuantityBooleanToFalse(true);
                    return pg;
                } else if (source == 'saveAndClose') {
                    pg = new PageReference(retUrl);
                    pg.setRedirect(true);
                    setHourQuantityBooleanToFalse(true);
                    return pg;
                } else {
                    return null;
                }
            } else {
                displayInputFields = false;
                displaySaveCancel = false;
                setHourQuantityBooleanToFalse(true);
                getSiteJobItems();
                return null;
            }
        } catch (DMLException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, '' + e.getDmlMessage(0)));
            return null;
        }
    }
    
    public void resetItemList() {
        displayInputFields = false;
        displaySaveCancel = false;
        driList = new List<Daily_Report_Item__c>();
        getSiteJobItems();
    }
    
    public void deleteJobItem() {
        String itmId = ApexPages.currentPage().getParameters().get('itm');
        List<Daily_Report_Item__c> dailyReportItemTempList = new List<Daily_Report_Item__c>();
        driList = retainDailyJobItemData();
        for (Daily_Report_Item__c driItem : driList) {
            if (driItem.Id != null) {
                if (driItem.Id != itmId) {
                    dailyReportItemTempList.add(driItem);
                }
            } else {
                if (driItem.Id == null && driItem.Contract_Job_Item__c != null && contractJobItemIdFrequencyMap.containsKey(driItem.Contract_Job_Item__c)) {
                    if (contractJobItemIdFrequencyMap.get(driItem.Contract_Job_Item__c).contains('Hour')) {
                        disableHour = false;
                        disableQuantity = true;
                    } else if (contractJobItemIdFrequencyMap.get(driItem.Contract_Job_Item__c).contains('Quantity')) {
                        disableHour = true;
                        disableQuantity = false;
                    }
                }
                dailyReportItemTempList.add(driItem);
            }
            
        }
        delete new Daily_Report_Item__c(Id = itmId);
        driList.clear();
        driList = new List<Daily_Report_Item__c>();
        driList.addAll(dailyReportItemTempList);
        fetchContractJobItems();
    }
    
    public PageReference returnDailyReport() {
        PageReference pgRef = new PageReference('/' + dailyReportId);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public pagereference editInVf() {
        setHourQuantityBooleanToFalse(false);
        displayInputFields = true;
        displaySaveCancel = false;
        addNewSiteJobItem();
        return null;
    }
    
    public void addNewSiteJobItem() {
        if (!singleItemView) {
            retainDailyJobItemData();
            if (dr.Contract__r.Contract_Active__c) {
                siteJobItem = new Daily_Report_Item__c(Daily_Report__c = dailyReportId);
                driList.add(siteJobItem);
            } else {
                if(displayInactiveContract > 0) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Oops! Can\'t add a Site Job Item for an expired contract.'));
            }
        }
        displayInactiveContract += 1;
    }
    
    public void saveAndAdd() {
        source = 'saveAndAdd';
        saveSiteJobItem();
        if (!quantityHourErrorOccurred) {
            getSiteJobItems();
            editInVf();
        } else {
            quantityHourErrorOccurred = false;
        }
        
    }
    
    public List<Daily_Report_Item__c> retainDailyJobItemData() {
        List<Daily_Report_Item__c> driListTemp = new List<Daily_Report_Item__c>();
        for (Daily_Report_Item__c dailyReportItem : driList) {
            if (dailyReportItem.Id == null && dailyReportItem.Contract_Job_Item__c != null && contractJobItemIdFrequencyMap.containsKey(dailyReportItem.Contract_Job_Item__c)) {
                if (contractJobItemIdFrequencyMap.get(dailyReportItem.Contract_Job_Item__c).contains('Hour')) {
                    disableQuantity = true;
                } else if (contractJobItemIdFrequencyMap.get(dailyReportItem.Contract_Job_Item__c).contains('Quantity')) {
                    disableHour = true;
                }
            }
            driListTemp.add(dailyReportItem);
        }
        driList.clear();
        driList = new List<Daily_Report_Item__c>();
        driList.addAll(driListTemp);
        return driList;
    }
    
    public PageReference closeSiteJob() {
        Pagereference redirectToPage = new PageReference('/' + dailyReportId);
        redirectToPage.setRedirect(true);
        return redirectToPage;
    }
    
    public pageReference showCancelModal() {
        
        if (dr.Status__c == 'Open' || dr.Status__c == 'Rejected') {
            showCancelPopup = true;
            return null;
        } else {
            PageReference pgRef = new PageReference('/' + dr.Id);
            pgRef.setRedirect(true);
            return pgRef;
        }
        
    }
    
    
}