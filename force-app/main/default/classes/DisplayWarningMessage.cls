//CLASS CREATED TO BE EXECUTE DELETE FROM BUTTON JAVASCRIPT
global class DisplayWarningMessage{
    //METHOD TO GET ALL EMPLOYEES NAME UNDER THIS POSITION
    webservice static string getEmployees(Id positionId){
        
        List<Employees__c> employeesUnderPosition     ;
        employeesUnderPosition = new List<Employees__c>([select id ,name from Employees__c where PositionLookup__c=:positionId]); 
        if(employeesUnderPosition.size()>0){
        	return 'success';
        }
        else{
        	return null;
        }
    }
    //METHOD TO DELETE POSITION
    webservice static void deletePosition(Id positionId){
        Position__c toBeDeletePosition =[select id from Position__c where id=:positionId];
        delete toBeDeletePosition;
    }
    
}