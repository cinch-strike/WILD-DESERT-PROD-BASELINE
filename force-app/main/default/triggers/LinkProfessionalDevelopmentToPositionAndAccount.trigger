//THIS TRIGGER IS WRITTEN TO LINK THE PROFESSIONAL DEVELOPMENT TYPE TO POSITIONS(ALL) AND ACCOUNT(MENTIONED IN RECORD)
trigger LinkProfessionalDevelopmentToPositionAndAccount on Professional_Development__c (after insert,after update) {
    //VARIABLES TO PREPROCESSING THE NECESSARY DATA 
    public List<Professional_Development__c> positionCompulsoryProfDevRecords = new List<Professional_Development__c>();
    public List<Professional_Development__c> accountCompulsoryProfDevRecords = new List<Professional_Development__c>();
    public List<Professional_Development__c> accountCompulsoryNonDuplicateProfDevRecords = new List<Professional_Development__c>();
    public List<Mandatory_Professional_Development__c> compulsoryProfDevRecords = new List<Mandatory_Professional_Development__c>();
    public List<Mandatory_Professional_Development__c> accountProfDevRecords = new List<Mandatory_Professional_Development__c>();
    public List<Position__c> allPositionList = new List<Position__c>([select id from Position__c]);
    public Map<Id,List<Mandatory_Professional_Development__c>> allPositionMandatoryProfDevs = new Map<Id,List<Mandatory_Professional_Development__c>>();
    public Map<Id,Professional_Development__c> tobeCreatedMandatoryProfDevs = new Map<Id,Professional_Development__c>();
    public Map<Id,List<Mandatory_Professional_Development__c>> accountMandProfDevs = new Map<Id,List<Mandatory_Professional_Development__c>>();
    //INSERT TRIGGER LOGIC
    if(Trigger.isInsert){
        //CHECK THE POSITION CONDITION TYPE AND ACCOUNT NAME AND LINK PROFESSIONAL DEVELOPMENT RECORD.
        for(Professional_Development__c pdt:trigger.new){
            if((pdt.Requirement_Type__c =='Compulsory - All')&&(pdt.Required_By__c==null)){
                positionCompulsoryProfDevRecords.add(pdt);  
            }
           /* if(pdt.Required_By__c!=null){
                accountCompulsoryProfDevRecords.add(pdt);
            }*/
            
        }
        //CREATING MANDATORY DEVELOPMENT RECORDS UNDER POSITONS
        for(Professional_Development__c profDev:positionCompulsoryProfDevRecords){
            for(Position__c position:allPositionList){
                Mandatory_Professional_Development__c newMandateProfDevRecord = new Mandatory_Professional_Development__c();
                newMandateProfDevRecord.Position__c = position.id;
                newMandateProfDevRecord.Professional_Development__c = profDev.id;
                newMandateProfDevRecord.name = profDev.name;
                compulsoryProfDevRecords.add(newMandateProfDevRecord);
            }
        }
        //CREATING MANDATORY DEVELOPMENT RECORDS UNDER ACCOUNT
       /* for(Professional_Development__c profDev:accountCompulsoryProfDevRecords){
            Mandatory_Professional_Development__c newMandateProfDevRecord = new Mandatory_Professional_Development__c();
            newMandateProfDevRecord.Account__c = profDev.Required_By__c;
            newMandateProfDevRecord.Professional_Development__c = profDev.id;
            newMandateProfDevRecord.name = profDev.name;
            compulsoryProfDevRecords.add(newMandateProfDevRecord);  
        }*/
        //INSERTING MANDATORY DEVELOPMENT RECORDS IN DATABASE
        try{
            database.insert(compulsoryProfDevRecords);
        }catch(DMlException de){
            
        }
        
    }
    //UPDATE TRIGGER LOGIC
    if(Trigger.isUpdate){
        //GETTING ALL THE POSITIONS WITH THEIR MANDATORY DEVELOPMENT TYPE RECORDS
        for(Position__c position:[select id,(select id,Professional_Development__c from  Position__r) from Position__c]){
            allPositionMandatoryProfDevs.put(position.Id,position.Position__r);
        }
        //GETTING ALL THE ACCOUNTS WITH THEIR MANDATORY DEVELOPMENT TYPE RECORDS
        for(Account acc:[select id,(select id,Account__c,Professional_Development__c from Mandatory_Professional_Developments__r) from Account]){
            accountMandProfDevs.put(acc.id,acc.Mandatory_Professional_Developments__r);
        }
        //system.assertEquals(allPositionMandatoryProfDevs,null);
        //CHECKING FOR REQUIREMENT TYPE AND ACCOUNT
        for(Professional_Development__c profdev:trigger.new){
            if(((trigger.newMap.get(profdev.Id).Requirement_Type__c !=trigger.oldMap.get(profdev.Id).Requirement_Type__c)&&(trigger.newMap.get(profdev.Id).Requirement_Type__c =='Compulsory - All'))&&(trigger.newMap.get(profdev.Id).Required_By__c ==null) ){
                positionCompulsoryProfDevRecords.add(profdev);
            }
            /*if((trigger.newMap.get(profdev.Id).Required_By__c !=trigger.oldMap.get(profdev.Id).Required_By__c)&&(trigger.newMap.get(profdev.Id).Required_By__c !=null)){
                accountCompulsoryProfDevRecords.add(profdev);   
            }*/
        }
        //AVOIDING DUPLICATE MANDATORY DEVELOPMENT RECORDS UNDER POSITION
        for(Position__c position:allPositionList){
            
            for(Professional_Development__c profDev:positionCompulsoryProfDevRecords){
                Integer Flag =0;
                for(Mandatory_Professional_Development__c posProfDev:allPositionMandatoryProfDevs.get(position.Id)){
                    if(posProfDev.Professional_Development__c == profDev.Id){
                        flag++;
                    }
                }
                if(flag==0){
                    tobeCreatedMandatoryProfDevs.put(position.Id,profDev);  
                }
                
            }       
        }
        //AVOIDING DUPLICATE MANDATORY DEVELOPMENT RECORDS UNDER ACCOUNT
      /*  for(Professional_Development__c profDev:accountCompulsoryProfDevRecords){
            Integer flag =0;
            for(Mandatory_Professional_Development__c mandDevRecs:accountMandProfDevs.get(profDev.Required_By__c)){
                if(mandDevRecs.Professional_Development__c == profDev.Id){
                    flag++;
                }
            }
            if(flag==0){
                accountCompulsoryNonDuplicateProfDevRecords.add(profDev);
            }
            
        }*/
        //CREATING MANDATORY DEVELOPMENT RECORDS UNDER POSITION
        for(Id posId:tobeCreatedMandatoryProfDevs.keySet()){
             Mandatory_Professional_Development__c newMandateProfDevRecord = new Mandatory_Professional_Development__c();
                newMandateProfDevRecord.Position__c = posId;
                newMandateProfDevRecord.Professional_Development__c = tobeCreatedMandatoryProfDevs.get(posId).Id;
                newMandateProfDevRecord.name =  tobeCreatedMandatoryProfDevs.get(posId).name;
                compulsoryProfDevRecords.add(newMandateProfDevRecord);  
        }
        //CREATING MANDATORY DEVELOPMENT RECORDS UNDER ACCOUNT
       /* for(Professional_Development__c profDev:accountCompulsoryNonDuplicateProfDevRecords){
             Mandatory_Professional_Development__c newMandateProfDevRecord = new Mandatory_Professional_Development__c();
             newMandateProfDevRecord.Professional_Development__c = profDev.Id;
             newMandateProfDevRecord.name = profDev.name;
             newMandateProfDevRecord.Account__c = profDev.Required_By__c;
            accountProfDevRecords.add(newMandateProfDevRecord);
        }*/
        //INSERTING MANDATORY DEVELOPMENT RECORDS
        try{
           /* if(accountProfDevRecords.size()>0){
                database.insert(accountProfDevRecords);
            }*/
            if(compulsoryProfDevRecords.size()>0){
                database.insert(compulsoryProfDevRecords);
            }
            
        }catch(DMLException de){
        
        }
        
    }
}