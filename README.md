# Salesforce Error Logging & OpenAI Integration

This project aims to automate Salesforce error debugging by integrating Salesforce with the OpenAI API to generate suggestions for errors recorded in the `Error_Log__c` custom object. It also includes a functionality to email the admin with details of new errors and a metadata management tool for storing configuration details.

## Features

### 1. Error Log Trigger & Queueable Job
- **Trigger** (`ErrorLogTrigger`): This trigger executes after a new `Error_Log__c` record is inserted. It enqueues a `Queueable` job (`SendToOpenAIQueueable`) that handles the processing of the error log.
- **Queueable Job** (`SendToOpenAIQueueable`): The Queueable class retrieves the newly created error log, sends a detailed request to the OpenAI API, and updates the error log with AI-generated suggestions.

### 2. Integration with OpenAI API
- The `SendToOpenAIQueueable` class sends an HTTP POST request to the OpenAI API endpoint to get debugging suggestions for an error.
- The request includes error details such as `Application Name`, `Component`, `Error Description`, and `Log`.
- Once a response is received, the AI-generated content is added to the `AI_Suggestions__c` field of the error log.
- The API key is fetched from the custom metadata type (`Meta_Assistant__mdt`).

### 3. Email Notifications
- After successfully receiving a response from the OpenAI API, an email is sent to the administrators.
- Admin email addresses are configured using a custom metadata type (`Error_Log_Metadata_Detail__mdt`).

### 4. Error Handling
- If any exceptions are thrown while calling the OpenAI API, they are logged in the `Error_Log__c` object.
- Errors in metadata updates are also recorded in `Error_Log__c` for transparency and ease of debugging.

### 5. Error Log Metadata Updater
- **Update Metadata** (`ErrorLogMetadataUpdater.updateErrorLogMetadata`): This method updates the custom metadata type with the list of all custom fields for a given object. This helps to store configurations such as custom fields for the error logging process.
- **Get Custom Object API Names** (`ErrorLogMetadataUpdater.getCustomObjectApiNames`): This method fetches all custom object API names in the org.
- **Deployment**: The metadata deployment leverages `Metadata.DeployContainer` to update the metadata configuration details.

## Code Structure
- **Trigger**: `ErrorLogTrigger` - Initiates the process whenever an `Error_Log__c` record is created.
- **Queueable Class**: `SendToOpenAIQueueable` - Handles callouts to OpenAI API and updates error logs.
- **Metadata Updater Class**: `ErrorLogMetadataUpdater` - Manages metadata configurations for error logging.

## Custom Metadata Types
- **Meta_Assistant__mdt**: Stores OpenAI API configuration (like `OpenAI_API_Key__c`).
- **Error_Log_Metadata_Detail__mdt**: Stores configuration for the error logging process (like `SenderList__c`, `Fields__c`).

## Prerequisites
- **OpenAI API Key**: You need to have an OpenAI API key to connect to OpenAI services. This key should be stored in `Meta_Assistant__mdt` under the field `OpenAI_API_Key__c`.
- **Custom Metadata Types**: The following custom metadata types need to be set up before deploying the code:
  - `Meta_Assistant__mdt` with `OpenAI_API_Key__c` field.
  - `Error_Log_Metadata_Detail__mdt` with fields like `SenderList__c`, `Fields__c`.
- **Custom Object**: The `Error_Log__c` custom object is required, and it should have fields like `Application_Name__c`, `Component_Name__c`, `Error_Description__c`, `Log__c`, `AI_Suggestions__c`.

## Deployment Instructions
1. **Custom Metadata Setup**: Add `Meta_Assistant__mdt` and `Error_Log_Metadata_Detail__mdt` to store configuration values such as API keys and admin email addresses.
2. **Deploy Classes and Trigger**: Deploy the Apex classes (`SendToOpenAIQueueable`, `ErrorLogMetadataUpdater`) and the trigger (`ErrorLogTrigger`) to your Salesforce org.
3. **Update Metadata Configuration**: Execute the `ErrorLogMetadataUpdater.updateErrorLogMetadata()` method to automatically update the `Error_Log_Metadata_Detail__mdt` with the custom fields from the error log.

## Usage
- When a new `Error_Log__c` record is created, it triggers a callout to OpenAI, which provides debugging suggestions based on the error data.
- Admins receive an email notification with the details of the error and the AI-generated suggestions.
- This solution can be used for automated assistance in debugging issues more effectively, saving time for the support and engineering teams.

## Error Handling
- **API Call Failures**: Errors related to callouts to OpenAI are logged into the `Error_Log__c` object.
- **Metadata Deployment Errors**: Errors during the metadata deployment process are also logged for easy troubleshooting.

## License
This project is licensed under the [MIT License](LICENSE).

## Contributing
Contributions are welcome! Please submit a pull request or create an issue for discussion.

## Contact
For any questions or support, please reach out to the project maintainer.

