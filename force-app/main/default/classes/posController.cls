//THIS CLASS IS WRITTEN TO HANDLE THE POSITION POSITION DELETION WARNING EVENTS
public class posController {
    //PROPERTIES USED IN THECONTROLLER
    public List<Employees__c> employeesUnderPosition{get;set;}
    public boolean showEmployees{get;set;}
    public pagereference refreshPage{get;set;}
    public posController (){}
    //PUBLIC METHOD TO DELETE THE POSITION ONCE CONFIRMED
    public pagereference deletePosition(){
        position__c pos =[select id from position__c  where id=:ApexPages.currentPage().getParameters().get('id')];
        delete pos;
        pagereference  page = new  pagereference('/');
        return page ;
    }
    //PUBLIC METHOD TO REDIRECT USER TO DETAIL PAGE ON CANCAL ACTION
    public pagereference cancelPosition(){
        pagereference  page = new  pagereference('/'+ApexPages.currentPage().getParameters().get('id'));
        
        return page;
    }
    //AUTO-DELETE THE POSITION if NO EMPLOYEES ARE ASSOCIATED WITH POSITION
    public pagereference autoDelete(){
        employeesUnderPosition = new List<Employees__c>([select id ,name from Employees__c where PositionLookup__c = :ApexPages.currentPage().getParameters().get('id')]);
        if(employeesUnderPosition.size()>0){
            showEmployees = true;
            return null;
        }
        else{
            position__c pos =[select id from position__c  where id=:ApexPages.currentPage().getParameters().get('id')];
            delete pos;
            pagereference  page = new  pagereference('/');
            return page ;
        }
    }
    
    
    
}