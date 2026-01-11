/**
 * @description Processor for Jira webhooks
 * Handles issue and project events from Jira
 * 
 * STUDENT TASK:
 * Implement the IWebhookProcessor interface to handle Jira webhook events
 * You'll need to process various events like issue/project creation, updates, and deletions
 * 
 * IMPORTANT NOTE: without sharing is used to avoid sharing issues with the Jira_Issue__c and Jira_Project__c objects but it is not a good practice
 * 
 * @author Derek Hanson
 */
public without sharing class JiraWebhookProcessor implements IWebhookProcessor {
    
    // Constants for webhook event types
    private static final String EVENT_ISSUE_CREATED = 'jira:issue_created';
    private static final String EVENT_ISSUE_UPDATED = 'jira:issue_updated';
    private static final String EVENT_ISSUE_DELETED = 'jira:issue_deleted';
    private static final String EVENT_PROJECT_CREATED = 'project_created';
    private static final String EVENT_PROJECT_UPDATED = 'project_updated';
    private static final String EVENT_PROJECT_DELETED = 'project_deleted';
    
    /**
     * @description Validates the incoming Jira webhook request
     * @param request The REST request containing the webhook payload
     * @return Boolean True if the request is valid, false otherwise
     * 
     * STUDENT TASK:
     * Implement validation logic for Jira webhooks
     * - Check for valid JSON by deserializing the request body
     * - Verify the 'webhookEvent' field exists in the payload
     * - You can add further validation like checking for specific headers
     * - Return true if valid, false otherwise
     * 
     * HINT:
     * 1. Use try-catch to handle JSON deserialization errors
     * 2. Cast the deserialized JSON to Map<String, Object>
     * 3. Check if required keys exist using containsKey()
     * 4. Example: if (!payload.containsKey('webhookEvent')) { return false; }
     */
    public Boolean validate(RestRequest request) {
        try {
            // TODO: Implement validation logic
            if (request == null || request.requestBody == null) {
                System.debug('***JiraWebhookProcessor.validate: Missing request or body');
                return false;
            }
            // Example:
            // String requestBody = request.requestBody.toString();
            String body = request.requestBody.toString();

            if (String.isBlank(body)) {
                System.debug('***JiraWebhookProcessor.validate: Empty body');
                return false;
            }
           
            // Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);
                      
            if (!payload.containsKey('webhookEvent')) {
                System.debug('***JiraWebhookProcessor.validate: Missing webhookEvent');
                return false;
            }
            
            // validate either issue or project data
            if (!payload.containsKey('issue') && !payload.containsKey('project')) {
                System.debug('***JiraWebhookProcessor.validate: No issue or project key present');
                return false;
            }

            System.debug('***JiraWebhookProcessor.validate: Validation passed');
            return true; 

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '***Error validating webhook: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Processes the Jira webhook request
     * @param request The REST request containing the webhook payload
     * 
     * STUDENT TASK:
     * Implement the main processing logic
     * - Parse the JSON payload from the request body
     * - Extract the 'webhookEvent' field to determine the event type
     * - Call the appropriate handler method based on the event type
     * 
     * HINT:
     * 1. Use JSON.deserializeUntyped() to convert the request body to a Map
     * 2. Extract the event type: String webhookEvent = (String) payload.get('webhookEvent');
     * 3. Use if/else or switch statements to call the appropriate handler
     * 4. Example: if (webhookEvent == EVENT_ISSUE_CREATED) { processIssueCreated(payload); }
     */
    public void process(RestRequest request) {
        try {
            // TODO: Implement webhook processing logic
            //initial validation
            if (request == null || request.requestBody == null) {
                System.debug('***JiraWebhookProcessor.process: Missing request or body');
                return;
            }
            // Example:
            String body = request.requestBody.toString();
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);
            String webhookEvent = (String) payload.get('webhookEvent');
            
            if (String.isBlank(webhookEvent)) {
                System.debug('***JiraWebhookProcessor.process: No webhookEvent');
                return;
       		}
             
            if (webhookEvent == EVENT_ISSUE_CREATED) {
            processIssueCreated(payload);
            } else if (webhookEvent == EVENT_ISSUE_UPDATED) {
            processIssueUpdated(payload);
            // ... and so on for other event types
             } else if (webhookEvent == EVENT_ISSUE_DELETED) {
                processIssueDeleted(payload);
             } else if (webhookEvent == EVENT_PROJECT_CREATED) {
                processProjectCreated(payload);
             } else if (webhookEvent == EVENT_PROJECT_UPDATED) {
                processProjectUpdated(payload);
             } else if (webhookEvent == EVENT_PROJECT_DELETED) {
                processProjectDeleted(payload); 
             } else {
           	 System.debug('***JiraWebhookProcessor.process: Unhandled webhookEvent: ' + webhookEvent);
       		 }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '***Error processing webhook: ' + e.getMessage());
            throw e; // Re-throw to let the caller handle it
        }
    }
    
    /**
     * @description Process an issue_created event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Use this example as a template for other event handlers
     */
    private void processIssueCreated(Map<String, Object> payload) {
        try {
            // Example implementation:
            
            // 1. Extract issue data from the payload
            Map<String, Object> issueData = (Map<String, Object>) payload.get('issue');
            
            // 2. Create a new Jira_Issue__c record using the helper method
            Jira_Issue__c newIssue = createIssueRecord(issueData);
            
            // 3. Insert the new record
            insert newIssue;
            
            // 4. Log success
            System.debug('***Created Jira issue record: ' + newIssue.Id);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '***Error processing issue_created event: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Process an issue_updated event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to update an existing Jira_Issue__c record
     * If the record doesn't exist, create it
     */
    private void processIssueUpdated(Map<String, Object> payload) {
        // TODO: Implement issue update logic
        try {
            //get issue and key
            Map<String, Object> issueData = (Map<String, Object>) payload.get('issue');
            if (issueData == null) {
                System.debug('***processIssueUpdated: No issue data in payload');
                return;
            }
    
            String issueKey = (String) issueData.get('key');
            if (String.isBlank(issueKey)) {
                System.debug('***processIssueUpdated: No issue key in payload');
                return;
            }
    		System.debug('***processIssueUpdated: issueKey from payload = [' + issueKey + ']');
            
            
			//check sf for existing
            List<Jira_Issue__c> existingIssues = [SELECT Id, Issue_Key__c, Summary__c, Description__c, Issue_Type__c, Status__c, Project_Key__c, Last_Updated__c
                                                    FROM Jira_Issue__c
                                                    WHERE Issue_Key__c = :issueKey
                                                    LIMIT 1
                                                ];
            //if empty, build one
            if (existingIssues.isEmpty()) {
                System.debug('***processIssueUpdated: No existing Jira_Issue__c found for key ' + issueKey + ' — inserting instead.');
                Jira_Issue__c newIssue = createIssueRecord(issueData);
                insert newIssue;
                return;
			}
            //if found, send to updater
            Jira_Issue__c existingIssue = existingIssues[0];
			System.debug('***existing issue query ' + existingIssue);
    
            existingIssue = updateIssueRecord(existingIssue, issueData);
            update existingIssue;
    
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '***Error processing issue_updated event: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Process an issue_deleted event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to delete a Jira_Issue__c record
     */
    private void processIssueDeleted(Map<String, Object> payload) {
        // TODO: Implement issue deletion logic
    	try {
            //get issue and key
            Map<String, Object> issueData = (Map<String, Object>) payload.get('issue');
            if (issueData == null) {
                System.debug('processIssueDeleted: No issue data in payload');
                return;
            }
    
            String issueKey = (String) issueData.get('key');
            if (String.isBlank(issueKey)) {
                System.debug('processIssueDeleted: No issue key in payload');
                return;
            }
    		//check sf for existing 
            List<Jira_Issue__c> issuesToDelete = [SELECT Id
                                                  FROM Jira_Issue__c
                                                  WHERE Issue_Key__c = :issueKey
                                            	  ];
    		//if found delete
            if (!issuesToDelete.isEmpty()) {
                delete issuesToDelete;
                System.debug('Deleted ' + issuesToDelete.size() + ' Jira issue record(s) for key ' + issueKey);
            } else {
                System.debug('processIssueDeleted: No Jira issue records found for key ' + issueKey);
            }
    
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error processing issue_deleted event: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Process a project_created event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to create a Jira_Project__c record
     */
    private void processProjectCreated(Map<String, Object> payload) {
        // TODO: Implement project creation logic
    	try {
            //get project info
            Map<String, Object> projectData = (Map<String, Object>) payload.get('project');
                if (projectData == null) {
                    System.debug('***processProjectCreated: No project data in payload');
                    return;
                }
        		//send to create
                Jira_Project__c project = createProjectRecord(projectData);
                if (project == null){
                    return;
                }
                insert project;
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '***Error processing project_created event: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Process a project_updated event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to update an existing Jira_Project__c record
     * If the record doesn't exist, create it
     */
    private void processProjectUpdated(Map<String, Object> payload) {
        // TODO: Implement project update logic
        try {
            //get project and key
            Map<String, Object> projectData = (Map<String, Object>) payload.get('project');
            if (projectData == null) {
                System.debug('processProjectUpdated: No project data in payload');
                return;
            }
    
            String projectKey = (String) projectData.get('key');
            if (String.isBlank(projectKey)) {
                System.debug('processProjectUpdated: No project key in payload');
                return;
            }
    		//query sf for existing
            List<Jira_Project__c> existingProjects = [SELECT Id, Project_Key__c, Project_ID__c, Project_Name__c, Description__c
                                                      FROM Jira_Project__c
                                                      WHERE Project_Key__c = :projectKey
                                                      LIMIT 1
                                                   	];
    		//if not existing, send to create else send to update
            if (existingProjects.isEmpty()) {
                System.debug('processProjectUpdated: No existing Jira_Project__c found for key ' + projectKey + ' — inserting instead.');
                Jira_Project__c newProject = createProjectRecord(projectData);
                if (newProject == null){
                    return;
                }
                insert newProject;
                return;
            }
    
            Jira_Project__c existingProject = existingProjects[0];
            existingProject = updateProjectRecord(existingProject, projectData);
            update existingProject;
    
            System.debug('Updated Jira project record: ' + existingProject.Id);
    
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error processing project_updated event: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Process a project_deleted event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to delete a Jira_Project__c record
     */
    private void processProjectDeleted(Map<String, Object> payload) {
        // TODO: Implement project deletion logic
        try {
            //get project and key
            Map<String, Object> projectData = (Map<String, Object>) payload.get('project');
            if (projectData == null) {
                System.debug('processProjectDeleted: No project data in payload');
                return;
            }
    
            String projectKey = (String) projectData.get('key');
            if (String.isBlank(projectKey)) {
                System.debug('processProjectDeleted: No project key in payload');
                return;
            }
    		//query sf for existing
            List<Jira_Project__c> projectsToDelete = [SELECT Id
                                                        FROM Jira_Project__c
                                                        WHERE Project_Key__c = :projectKey
                                                    ];
    		//if not empty delete
            if (!projectsToDelete.isEmpty()) {
                delete projectsToDelete;
                System.debug('Deleted ' + projectsToDelete.size() + ' Jira project record(s) for key ' + projectKey);
            } else {
                System.debug('processProjectDeleted: No Jira project records found for key ' + projectKey);
            }
    
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error processing project_deleted event: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Create a Jira_Issue__c record from issue data
     * @param issueData The issue data from the webhook
     * @return Jira_Issue__c The newly created issue record
     * 
     * STUDENT TASK:
     * Implement logic to extract issue fields and create a record
     * 
     * HINT:
     * 1. Extract data from the issueData map (key, summary, status, etc.)
     * 2. Map the fields to a new Jira_Issue__c record
     */
    private Jira_Issue__c createIssueRecord(Map<String, Object> issueData) {
        // TODO: Implement issue record creation logic
        // Example (incomplete - add other fields as needed):
        
        String issueKey = (String) issueData.get('key');
        Map<String, Object> fields = (Map<String, Object>) issueData.get('fields');
		String summary = fields != null ? (String) fields.get('summary') : null;
        String description = fields != null ? (String) fields.get('description') : null;
        String issueType;
        //collect fields
        Map<String, Object> typeMap = fields != null ? (Map<String, Object>) fields.get('issuetype') : null;
        if (typeMap != null) {
            issueType = (String) typeMap.get('name');
        }

        String status;
        Map<String, Object> statusMap = fields != null ? (Map<String, Object>) fields.get('status') : null;
        if (statusMap != null) {
            status = (String) statusMap.get('name');
        }

        String projectKey;
        Map<String, Object> projectMap = fields != null ? (Map<String, Object>) fields.get('project') : null;
        if (projectMap != null) {
            projectKey = (String) projectMap.get('key');
        }
		//build record from fields
        Jira_Issue__c issue = new Jira_Issue__c(
            Issue_Key__c = issueKey,
            Summary__c = summary,
            // Add other fields as needed
            Description__c= description,
            Issue_Type__c = issueType,
            Status__c     = status,
            Project_Key__c= projectKey,
            Last_Updated__c = System.now()
            
        );
        //send to process create
        return issue;
    }
    
    /**
     * @description Update a Jira_Issue__c record from issue data
     * @param existingIssue The existing issue record
     * @param issueData The updated issue data from the webhook
     * @return Jira_Issue__c The updated issue record
     * 
     * STUDENT TASK:
     * Implement logic to extract issue fields and update a record
     */
    private Jira_Issue__c updateIssueRecord(Jira_Issue__c existingIssue, Map<String, Object> issueData) {
        // TODO: Implement issue record update logic
        if (existingIssue == null || issueData == null) {
            return existingIssue;
        }
		//collect fields
        Map<String, Object> fields = (Map<String, Object>) issueData.get('fields');

        if (fields != null) {
            if (fields.containsKey('summary')) {
                existingIssue.Summary__c = (String) fields.get('summary');
            }
            if (fields.containsKey('description')) {
                existingIssue.Description__c = (String) fields.get('description');
            }

            Map<String, Object> typeMap = (Map<String, Object>) fields.get('issuetype');
            if (typeMap != null) {
                existingIssue.Issue_Type__c = (String) typeMap.get('name');
            }

            Map<String, Object> statusMap = (Map<String, Object>) fields.get('status');
            if (statusMap != null) {
                existingIssue.Status__c = (String) statusMap.get('name');
            }

            Map<String, Object> projectMap = (Map<String, Object>) fields.get('project');
            if (projectMap != null) {
                existingIssue.Project_Key__c = (String) projectMap.get('key');
            }
        }

        existingIssue.Last_Updated__c = System.now();
        //send to processupdate
        return existingIssue;
    }
    
    /**
     * @description Create a Jira_Project__c record from project data
     * @param projectData The project data from the webhook
     * @return Jira_Project__c The newly created project record
     * 
     * STUDENT TASK:
     * Implement logic to extract project fields and create a record
     */
    private Jira_Project__c createProjectRecord(Map<String, Object> projectData) {
        // TODO: Implement project record creation logic
    	if (projectData == null) {
            return null;
        }
		//collect fields
        String projectKey = (String) projectData.get('key');
        // id might come as a string or a number; String.valueOf handles both
        String projectId = String.valueOf(projectData.get('id'));
        String name = (String) projectData.get('name');
        String description = (String) projectData.get('description');
        
		//build proj
        Jira_Project__c project = new Jira_Project__c(
            Project_Key__c   = projectKey,
            Project_ID__c    = projectId,
            Project_Name__c  = name,
            Description__c   = description
        );
        
        //send to processcreate
        return project;
    }
    
    /**
     * @description Update a Jira_Project__c record from project data
     * @param existingProject The existing project record
     * @param projectData The updated project data from the webhook
     * @return Jira_Project__c The updated project record
     * 
     * STUDENT TASK:
     * Implement logic to extract project fields and update a record
     */
    private Jira_Project__c updateProjectRecord(Jira_Project__c existingProject, Map<String, Object> projectData) {
        // TODO: Implement project record update logic
        if (existingProject == null || projectData == null) {
            return existingProject;
        }
		//collect fields
        if (projectData.containsKey('key') && projectData.get('key') != null) {
            existingProject.Project_Key__c = (String) projectData.get('key');
        }
    
        if (projectData.containsKey('name') && projectData.get('name') != null) {
            existingProject.Project_Name__c = (String) projectData.get('name');
        }
    
        if (projectData.containsKey('description')) {
            Object descObj = projectData.get('description');
            if (descObj != null) {
                existingProject.Description__c = (String) descObj;
            }
        }
        if (projectData.containsKey('id') && projectData.get('id') != null) {
            existingProject.Project_ID__c = String.valueOf(projectData.get('id'));
        }

		//send to processupdate
        return existingProject;
    }
}
