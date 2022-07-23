/*******
 * Description : API Class to indicate App User’s PA can be deleted
 * 
 * Change History :
 * Date(YYYYMMDD)      Name                    Description
 * 20220331            vu.thieudang            Created Initial Version 
*******/

@RestResource (urlMapping = '/ShowDeleteButton/*')
global class ShowDeleteButtonAPI {
    private static RestResponse response = RestContext.response;
    private static RestRequest request   = RestContext.request;
    private static HttpErrorResponse errorResponse;

    @HttpGet
    global static void ShowDeleteButtonAPI()
    {
        response.addHeader('Content-Type', 'application/json');
        try 
        {   
            checkValidUserPA();
        }
        catch(Exception ex) 
        {
            loggerDataPool.buildLogDataPool('ShowDeleteButtonAPI', ex);
            errorResponse = new HttpErrorResponse('Failed', ex.getMessage() + ' ' + ex.getLineNumber());
        }

        if (errorResponse != null)
        {
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
        }

        serviceDataPool.buildServiceDataPool('ShowDeleteButtonAPI', 'ShowDeleteButtonAPI', '', request, response);
    }

    public static void checkValidUserPA() {
        String userId = request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
        if (String.isBlank(userId))
        {
            errorResponse = new HttpErrorResponse('Failed', 'User Id can not be empty');
            return;
        }
        else
        {
            List<User> users = [SELECT Id, Email, FirstName, LastName FROM User WHERE Id = :userId AND Profile.Name = 'End User'];
            if (users.size() == 0)
            {
                errorResponse = new HttpErrorResponse('Failed', 'Unable to find User with provided User Id');
                return;
            }

            List<Account> accs = [SELECT Id, PersonEmail, PersonContactId, Signup_Channel__pc, RecordType.DeveloperName
                                  FROM Account
                                  WHERE IsPersonAccount = true 
                                    AND PersonEmail =: users[0].Email
                                  LIMIT 1];
            
            // AccountUtil.getPersonAccountsByEmails(new Set<String>{users[0].Email});

            if (accs.size() > 1)
            {
                errorResponse = new HttpErrorResponse('Failed', 'Found too many Person Account with provided User Id');
                return;
            } 
            else if (accs.size() == 0)
            {
                errorResponse = new HttpErrorResponse('Failed', 'Unable to find Person Account with provided User Id');
                return;
            }

            Boolean isValidUser = IDPAppService.checkUserForDeletion(accs[0]);

            response.statusCode   = 200;
            response.responseBody = Blob.valueOf(String.valueOf(isValidUser));
        }
    }

    public class HttpErrorResponse
    {
        public String status;
        public String message;

        public HttpErrorResponse(String status, String message)
        {
            this.status  = status;
            this.message = message;
        }
    }
}