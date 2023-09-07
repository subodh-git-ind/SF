trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    try{
        if(Trigger.isBefore && Trigger.isInsert){
            AccountTriggerService.isAccountActivated(Trigger.New);
        }
        
        if(Trigger.isBefore && Trigger.isUpdate){
            AccountTriggerService.checkActivatedAccount(Trigger.New);
        }
        
        if(Trigger.isAfter && Trigger.isInsert){
            AccountTriggerService.createTeamMember(Trigger.New);
        }
    }
    catch(Exception e){
        System.debug('Exception while processing Account: '+e.getMessage()+ ' at line number: '+e.getLineNumber());
    }
}