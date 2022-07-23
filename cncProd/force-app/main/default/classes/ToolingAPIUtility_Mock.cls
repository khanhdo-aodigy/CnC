@isTest
global class ToolingAPIUtility_Mock implements HttpCalloutMock{
  public HttpResponse respond(HttpRequest request)
  {     
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setStatusCode(200);  
    String endpoint = request.getEndpoint();
    if (endpoint.endsWith('services/data'))
    {
      res.setBody('[{' + 
      ' "label" : null,' +
      ' "url" : "/services/data/v53.0",' + 
      ' "version" : "53.0"' +
      '},' + '{' +
      ' "label" : null,' +
      ' "url" : "/services/data/v54.0",' +
      ' "version" : "54.0"' +
      '}]');
    }
    else if (endpoint.endsWith('DeveloperName=\'Model\''))
    {
      res.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"GlobalValueSet","records":[{"attributes":{"type":"GlobalValueSet","url":"/services/data/v54.0/tooling/sobjects/GlobalValueSet/0NtO0000000ClrkKAC"},"Id":"0NtO0000000ClrkKAC","MasterLabel":"Model","Description":null,"FullName":"Model","Metadata":{"customValue":[{"color":null,"default":false,"description":null,"isActive":null,"label":"RIO 1.5 AUTO","urls":null,"valueName":"RIO 1.5 AUTO"},{"color":null,"default":false,"description":null,"isActive":null,"label":"RIO 1.5 AUTO HACHBACK","urls":null,"valueName":"RIO 1.5 AUTO HACHBACK"}],"description":null,"masterLabel":"Model","sorted":false,"urls":null}}]}');
    }
    return res;
  }  
}