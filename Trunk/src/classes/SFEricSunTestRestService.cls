@RestResource(urlMapping='/SFEricSunTestRestService/*')
global class SFEricSunTestRestService {
    
    @HttpDelete
    global static string doDelete() {
        RestRequest req = RestContext.request;
        String name = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        return 'Delete ' + name;
    }
  
    @HttpGet
    global static string doGet() {
        RestRequest req = RestContext.request;
        String name = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        return 'Get ' + name;
    }
  
    @HttpPost
    global static string doPost(string name, string age) {
        return 'Post' + name + ' ' + age;
    }
    
}