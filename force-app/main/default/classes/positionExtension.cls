public class positionExtension {

    public positionExtension() {

    }


    public positionExtension(ApexPages.StandardController controller) {

    }
    @remoteaction
    public static string getEmployees(Id positionId){
    
        List<Employees__c> employeesUnderPosition     ;
        employeesUnderPosition = new List<Employees__c>([select id ,name from Employees__c where PositionLookup__c=:positionId]); 
        if(employeesUnderPosition.size()>0){
            return 'success';
        }else{
            return null;
        }
    
    }

}