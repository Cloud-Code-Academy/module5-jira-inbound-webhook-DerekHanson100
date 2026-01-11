/**
 * @description REST resource to handle incoming webhooks from various systems
 * Current implementation supports Jira webhooks at /webhook/jira
 * 
 * STUDENT TASK:
 * Complete the doPost method implementation to process incoming webhooks
 * 
 * IMPORTANT NOTE: without sharing is used to avoid sharing issues with the Jira_Issue__c and Jira_Project__c objects but it is not a good practice
 * 
 * @author Derek Hanson
 */
@RestResource(urlMapping='/webhook/*')
global without sharing class WebhookResource {
    
    /**
     * @description Handles POST requests from webhooks
     * @return Returns a simple success response
     * 
     * STUDENT TASK:
     * Implement this method to:
     * 1. Get the REST request and response objects
     * 2. Extract the webhook type from the URL path using getWebhookTypeFromPath
     * 3. Process the webhook using WebhookFactory.processWebhook
     * 4. Return an appropriate ResponseWrapper
     * 5. Add error handling using try-catch
     */
    @HttpPost
    global static ResponseWrapper doPost() {
        // TODO: Implement webhook processing logic
        RestRequest req = RestContext.request;

        // Step 1: Extract raw JSON body
        String rawBody = '';
        if (req.requestBody != null) {
            rawBody = req.requestBody.toString();
        }


        // Step 2: Extract webhook type from URL
        String path = req.requestURI;

        String webhookType = getWebhookTypeFromPath(path);
        System.debug('***Webhook type: ' + webhookType);

        // Step 3: Process the webhook via factory
        try {
            WebhookFactory.processWebhook(webhookType, req);
        } catch (Exception e) {
            System.debug('***Error in webhook processing: ' + e.getMessage());
            return new ResponseWrapper('error', e.getMessage());
        }

        // return new ResponseWrapper('error', 'Method not implemented');
        return new ResponseWrapper('success', 'Webhook processed');
    }
    
    /** DON'T TOUCH**
     * @description Extracts the webhook type from the URL path
     * @param path The request URI
     * @return The webhook type (e.g., "jira")
     */
    private static String getWebhookTypeFromPath(String path) {
        System.debug('***getWebhookTypeFromPath: ' + path);
        // Expected formats: /webhook/jira or /services/apexrest/webhook/jira
        if (path == null) {
            return '';
        }
        
        // Look for the webhook segment in the path
        Integer webhookIndex = path.indexOf('/webhook/');
        
        if (webhookIndex >= 0) {
            // Extract the part after /webhook/
            String remaining = path.substring(webhookIndex + 9);
            System.debug('***remaining: ' + remaining);
            
            // If there are additional slashes, only take the first segment
            Integer nextSlash = remaining.indexOf('/');
            if (nextSlash > 0) {
                System.debug('***nextSlash: ' + nextSlash);
                return remaining.substring(0, nextSlash).toLowerCase();
            }
            
            return remaining.toLowerCase();
        }
        
        return '';
    }
    
    /** DON'T TOUCH**
     * @description Response wrapper class for consistent response format
     */
    global class ResponseWrapper {
        public String status;
        public String message;
        
        public ResponseWrapper(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
} 