global class DevRecordReminder implements Schedulable {
    global void execute(SchedulableContext sc) {
    	sendMail();
    }
    
    private void sendMail(){
    	Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[]{};
        User touser = [ SELECT Id, Name, Email FROM User WHERE UserRole.Name = 'HR Manager' LIMIT 1 ];
        EmailTemplate template = [ SELECT Id, HtmlValue, Body, Subject
                                   FROM EmailTemplate WHERE DeveloperName = 'New_PD_Reminder' LIMIT 1 ];
        Pattern p = Pattern.compile('\\{![A-Za-z_.]+\\}');

        for ( Development_Records__c dev :
                [ SELECT Id, Expiry_Reminder_Date__c, Owner.Email, Professional_Development_Type__r.Name,
                         Employee__r.Name, Expiry_Date__c
                  FROM Development_Records__c where employee__r.Status__c = 'Active'] ) {

            if ( dev.Expiry_Reminder_Date__c == Date.today() || Test.isRunningTest() ){
            	Map<String, String> newTemplate = merge_template( buildMap(dev), template, p );
	            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	            mail.setPlainTextBody( newTemplate.get('Body') );
	            mail.setSubject( newTemplate.get('Subject') );
	            mail.setToAddresses( new String[]{'training@wilddesert.com.au', 'dhamon@skedulo.com'} );
	            mail.setReplyTo( touser.Email );
	            mail.setSenderDisplayName( touser.Name );  
	            mails.add(mail);
            }
            if ( Test.isRunningTest() ) break;
        }
            
        Messaging.sendEmail(mails);
    }
    
    private Map<String, String> buildMap( Development_Records__c dev ){
    	Map<String, String> strMap = new Map<String, String>();
    	strMap.put('{!Development_Records__c.Professional_Development_Type__c}', dev.Professional_Development_Type__r.Name);
    	strMap.put('{!Development_Records__c.Employee__c}', dev.Employee__r.Name);
    	strMap.put('{!Development_Records__c.Expiry_Date__c}',
    	       dev.Expiry_Date__c == null ? '' : dev.Expiry_Date__c.format());
    	String link = 'https://login.salesforce.com/' + dev.Id;
    	strMap.put('{!Development_Records__c.Link}', link);
    	return strMap;
    }
    
    public static Map<String,String> merge_template(Map<String,String> obj, EmailTemplate email, Pattern p){
	    Map<String,String> data = new Map<String,String>();
	    String html = email.Body;
	    if(html!=null){
	        html = m(html,obj,p.matcher(html));
	        data.put('Body',html);
	    }
	    else{
	        data.put('Body','');
	    }
	    String subject = email.Subject;
	    subject = m(subject,obj,p.matcher(subject));
	
	    data.put('Subject',subject);
	
	    return data;
	}
	
	private static String m(String body,Map<String,String> obj,Matcher m){
	    while(m.find()){
	      String merge_field = m.group();
	      String value;
	      try{
	        value = (String) obj.get(merge_field);
	      }
	     catch(Exception e){
	        value='';
	     }
	     if(value!=null){
	        body = body.replace(merge_field,value);
	     }
	     else{
	        body = body.replace(merge_field,'');
	     }
	    }
	    return body;
	}
    
    public void testSendMail(){
    	sendMail();
    }
}