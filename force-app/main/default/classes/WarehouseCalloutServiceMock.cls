@IsTest
public class WarehouseCalloutServiceMock implements HttpCalloutMock  {
    // implement http mock callout

    public static HttpResponse respond(HttpRequest request){
        
        System.assertEquals('https://th-superbadge-apex.herokuapp.com/equipment', request.getEndpoint(),'Here is your endpoint! ');
        System.assertEquals('GET', request.getMethod(),'Returned get response! ');
        
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"_id":"55d66226726b611100aaf741","replacement":false,"quantity":5,"name":"Generator 1000 kW","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"100003"}]');
        response.setStatusCode(200);
        return response;
    }

}