public with sharing class ErrorLogMetadataUpdater {

    // Method to update error log metadata
    @AuraEnabled
    public static void updateErrorLogMetadata(String errorLogObjectApiName) {
        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(errorLogObjectApiName);
            Map<String, Schema.SObjectField> fieldsMap = sObjectType.getDescribe().fields.getMap();
            List<String> customFields = new List<String>();
            for (String fieldName : fieldsMap.keySet()) {
                if (fieldsMap.get(fieldName).getDescribe().isCustom()) {
                    customFields.add(fieldName);
                }
            }

            // Inserting Custom Metadata Record to Store Configs like Custom Fields
            String customFieldsStr = String.join(customFields, ',');
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            Metadata.CustomMetadata metadataInstance = new Metadata.CustomMetadata();
            metadataInstance.fullName = 'Error_Log_Metadata_Detail__mdt.ErrorLogFields';
            metadataInstance.label = 'ErrorLog Fields';

            // Adding custom fields to metadata record
            Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
            customField1.field = 'Fields__c';
            customField1.value = customFieldsStr;
            metadataInstance.values.add(customField1);

            mdContainer.addMetadata(metadataInstance);
            Metadata.Operations.enqueueDeployment(mdContainer, null);
        } catch (Exception e) {
            System.debug('Error while updating Error Log Metadata: ' + e.getMessage());
            Error_Log__c errorLog = new Error_Log__c(
                Application_Name__c = 'ErrorLogMetadataUpdater',
                Component_Name__c = 'updateErrorLogMetadata',
                Error_Description__c = e.getMessage(),
                Type__c = 'Exception'
            );
            insert errorLog;
        }
    }

    // Method to fetch all custom fields from Custom Error Log Object
    @AuraEnabled(cacheable=true)
    public static List<String> getCustomObjectApiNames() {
        List<String> customObjectApiNames = new List<String>();
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        for (String apiName : globalDescribeMap.keySet()) {
            if (apiName.endsWith('__c')) {
                customObjectApiNames.add(apiName);
            }
        }
        return customObjectApiNames;
    }

    // Method to update Sender List in Custom Metadata
    @AuraEnabled
    public static void updateSenderList(String emailList) {
        try {
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            Metadata.CustomMetadata metadataInstance = new Metadata.CustomMetadata();
            metadataInstance.fullName = 'Error_Log_Metadata_Detail__mdt.ErrorLogFields';
            metadataInstance.label = 'ErrorLog Fields';

            // Adding SenderList__c custom field value
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = 'SenderList__c';
            customField.value = emailList;
            metadataInstance.values.add(customField);
            mdContainer.addMetadata(metadataInstance);
            //deploying metadata
            Metadata.Operations.enqueueDeployment(mdContainer, null);
        } catch (Exception e) {
            System.debug('Error while updating Sender List: ' + e.getMessage());
            Error_Log__c errorLog = new Error_Log__c(
                Application_Name__c = 'ErrorLogMetadataUpdater',
                Component_Name__c = 'updateSenderList',
                Error_Description__c = e.getMessage(),
                Type__c = 'Exception'
            );
            insert errorLog;
        }
    }
}