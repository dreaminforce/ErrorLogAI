trigger ErrorLogTrigger on Error_Log__c (after insert) {
    for (Error_Log__c errorLog : Trigger.New) {
        // Call the Queueable class to handle the callout
        SendToOpenAIQueueable sendToOpenAI = new SendToOpenAIQueueable(errorLog.Id);
        System.enqueueJob(sendToOpenAI);
    }
}