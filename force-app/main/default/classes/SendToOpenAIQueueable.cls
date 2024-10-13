public with sharing class SendToOpenAIQueueable implements Queueable, Database.AllowsCallouts {
    private Id errorLogId;
	public static String API_KEY = Meta_Assistant__mdt.getInstance('Configs').OpenAI_API_Key__c;
    public SendToOpenAIQueueable(Id errorLogId) {
        this.errorLogId = errorLogId;
    }

    public void execute(QueueableContext context) {
        // Retrieve the error log record
        Error_Log__c errorLog = [SELECT Id, Application_Name__c,AI_Suggestions__c, Component_Name__c, Error_Description__c, Log__c, Related_Record__c, Type__c 
                                 FROM Error_Log__c 
                                 WHERE Id = :errorLogId];

        // Prepare JSON request payload for ChatCompletion using Maps
        Map<String, Object> systemMessage = new Map<String, Object>{
            'role' => 'system',
            'content' => 'You are an assistant that helps debug Salesforce errors.'
        };
        Map<String, Object> userMessage = new Map<String, Object>{
            'role' => 'user',
            'content' => 'Application: ' + errorLog.Application_Name__c + ', Component: ' + errorLog.Component_Name__c + ', Error: ' + errorLog.Error_Description__c + ', Log: ' + errorLog.Log__c
        };

        List<Map<String, Object>> messages = new List<Map<String, Object>>{systemMessage, userMessage};

        Map<String, Object> requestPayload = new Map<String, Object>{
            'model' => 'gpt-4o-mini',
            'messages' => messages
        };

        String requestBody = JSON.serialize(requestPayload);

        // Prepare HTTP request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.openai.com/v1/chat/completions');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        request.setHeader('Authorization', 'Bearer '+API_KEY); 
        request.setBody(requestBody);

        try {
            // Make HTTP callout
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                // Parse the response from OpenAI
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> choices = (List<Object>) responseMap.get('choices');
                String openAiResponse = '';
                if (!choices.isEmpty()) {
                    Map<String, Object> choice = (Map<String, Object>) choices[0];
                    Map<String, Object> message = (Map<String, Object>) choice.get('message');
                    openAiResponse = (String) message.get('content');
                }

                // Update the error log record with OpenAI response
                errorLog.AI_Suggestions__c = openAiResponse;
                update errorLog;

                // Send email to admin
                sendEmailToAdmin(errorLog);
            }
        } catch (Exception e) {
            System.debug('Error while calling OpenAI API: ' + e.getMessage());
            createErrorLogRecord(e.getMessage());
        }
    }

    // Helper method to send an email to the admin
    private void sendEmailToAdmin(Error_Log__c errorLog) {
        // Get admin email from the Org (can be hardcoded or fetched from Custom Settings)
        String adminEmail = 'kamal.thakur.dev16@gmail.com'; // Replace with actual admin email

        // Create email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { adminEmail });
        email.setSubject('New Error Log Created: ' + errorLog.Application_Name__c);
        email.setPlainTextBody('A new error log has been created. Details: ' + 
                               '\nApplication Name: ' + errorLog.Application_Name__c +
                               '\nComponent Name: ' + errorLog.Component_Name__c +
                               '\nError Description: ' + errorLog.Error_Description__c +
                               '\nError Log: ' + errorLog.Log__c +
                               '\nResponse from OpenAI: ' + errorLog.AI_Suggestions__c);
        // Send email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }

    // Helper method to create an error log record
    private void createErrorLogRecord(String errorMessage) {
        Error_Log__c errorLog = new Error_Log__c(
            Application_Name__c = 'OpenAI Integration',
            Component_Name__c = 'SendToOpenAIQueueable',
            Error_Description__c = errorMessage,
            Type__c = 'Exception'
        );
        insert errorLog;
    }
}