public class SiteJobItemSpecific_Controller {
    
    private final Daily_Report_Item__c dri;
    public Daily_Report_Item__c dritm;
    public SiteJobItemSpecific_Controller(ApexPages.StandardController stdController){
        this.dri = (Daily_Report_Item__c) stdController.getRecord();
    }
    
    public PageReference siteJobItemSpecific(){
        dritm = [select Id,Daily_Report__c from Daily_Report_Item__c where Id =: dri.Id];
        PageReference pgRef = new PageReference('/apex/SiteJobItem_VF?id='+dritm.Daily_Report__c+'&driItem='+dritm.Id);
        pgRef.setRedirect(true);
        return pgRef;
    }

}