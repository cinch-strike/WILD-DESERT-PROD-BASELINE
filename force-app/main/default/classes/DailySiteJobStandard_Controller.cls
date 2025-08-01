/**********************************************************************************
* @author        Kunal Jain
* @date         
* @description   This is a controller for DailySiteJobStandard_VF visualforce page
* @TestClass     DailySiteJobStandard_Controller_Test
***********************************************************************************/
public class DailySiteJobStandard_Controller{
    
    String siteJobId;
    Id dailySiteJobId;
    
    public DailySiteJobStandard_Controller(ApexPages.StandardController controller){
        dailySiteJobId = controller.getId();
        siteJobId = dailySiteJobId;
    }
    
    public pageReference init(){
        Daily_Report__c dailyReport;
        String contractIdParam;
        String siteIdParam;
        String unitIdParam;
        String unitTypeParam;
        String retUrl;
        
        if(dailySiteJobId != null){
            dailyReport = [Select Id,Unit__c,Unit__r.UnitType__c,Type__c,Contract__c,Site__c from Daily_Report__c where Id = : dailySiteJobId];
            contractIdParam = dailyReport.Contract__c;
            siteIdParam = dailyReport.Site__c;
            unitIdParam = dailyReport.Unit__c;
            unitTypeParam = dailyReport.Unit__r.UnitType__c;
            retUrl = dailyReport.Id;
            
            
        }else{
            contractIdParam = ApexPages.currentPage().getParameters().get('contractId');
            siteIdParam = ApexPages.currentPage().getParameters().get('siteId');
            unitIdParam = ApexPages.currentPage().getParameters().get('unitId');
            unitTypeParam = ApexPages.currentPage().getParameters().get('unitType');
            retUrl = ApexPages.currentPage().getParameters().get('retURL');
            if(String.isNotBlank(retUrl)){
                Integer indexOfRetUrl = retUrl.indexOf('com/');
                retUrl = retUrl.substring(indexOfRetUrl + 4);
            }
        }
        
        system.debug('--DailySiteJobStandard_Controller Start--');
        system.debug('retUrl: ' + retUrl);
        system.debug('--DailySiteJobStandard_Controller End--');
        PageReference redirectToPage;
        if(siteJobId != null){
            redirectToPage = new PageReference('/apex/DailySiteJob_VF?siteJobId='+siteJobId+'&tabView=1'+'&retURL='+retUrl);
        }
        else{
            redirectToPage = new PageReference('/apex/DailySiteJob_VF?unitId='+unitIdParam+'&siteId='+siteIdParam+'&contractId='+contractIdParam+'&unitType='+unitTypeParam+'&retURL='+retUrl);
        }
        redirectToPage.setRedirect(true);
        return redirectToPage;
        
    }
}