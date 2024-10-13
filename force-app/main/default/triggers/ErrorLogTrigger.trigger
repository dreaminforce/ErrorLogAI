trigger ErrorLogTrigger on Error_Log__c (after insert) {
    for (Error_Log__c errorLog : Trigger.New) {
        SendToOpenAIQueueable sendToOpenAI = new SendToOpenAIQueueable(errorLog.Id);
        System.enqueueJob(sendToOpenAI);
    }
}