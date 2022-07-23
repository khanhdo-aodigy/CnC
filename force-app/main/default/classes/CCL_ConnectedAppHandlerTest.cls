@IsTest
private class CCL_ConnectedAppHandlerTest {
	
    @IsTest
    private static void customAttributesTest() {
        //Create an instance of a connected app
        ConnectedApplication connectedApp = UserProvisioning.ConnectorTestUtil.createConnectedApp('TestApp');
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User testUser = new User(username='chutrochamkam@test.com', Firstname= 'Test', Lastname='User1', email='testuser1@test.com',
        FederationIdentifier='testuser1@test.com', profileId= p.Id, communityNickName='tuser1', alias='tuser', TimeZoneSidKey='GMT', 
        LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert testUser;
        Map<String,String> mapstr = new Map<String,String>();
        Test.startTest();
        CCL_ConnectedAppHandler handler = new CCL_ConnectedAppHandler ();
        System.runAs(testUser){
            Map<String,String> respMapStr = handler.customAttributes(UserInfo.getUserId(), connectedApp.Id, mapstr,  Auth.InvocationContext.SAML_ASSERTION);
        }
        Test.stopTest();
        
    }
}