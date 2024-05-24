//Class to call the API to get a list of equipment
public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts  {

    //endpoint
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    
  Public static void getWarehouseInventory(){
    String body;
      // Instantiate a new Http object
      Http h = new Http();

      // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
     HttpRequest req = new HttpRequest();
     req.setEndpoint(WAREHOUSE_URL);
     req.setMethod('GET');
 
     // Send the request, and return a response
     HttpResponse res = h.send(req);
    
     //Check response to see if it was returned correctly
     if (res.getStatusCode() == 200) {
        //Store response in a string
        body = res.getBody();
        //Deserialize the Json string and return values to debug log 
        List<Object> jsonRes = (List<Object>)JSON.deserializeUntyped(body);
        System.debug('jsonRes >>' + jsonRes);
        
        //Create a list to store the new products created from the Json response
        List<Product2> productList = new List<Product2>();
        //Loop through json response and upsert product list based on responses
        for(Object ob : jsonRes){
            Map<String,Object> jsonMap = (map<String,Object>)ob;
            Product2 pr = new Product2();
           //Assign values to the product based on the values from the map
            pr.Replacement_Part__c = (Boolean)jsonMap.get('replacement');
            pr.Name = (String)jsonMap.get('name');
            pr.Maintenance_Cycle__c = (Integer)jsonMap.get('maintenanceperiod');
            pr.Lifespan_Months__c = (Integer)jsonMap.get('lifespan');
            pr.Cost__c = (Decimal) jsonMap.get('cost');
            pr.Warehouse_SKU__c = (String)jsonMap.get('sku');
            pr.Current_Inventory__c = (Double) jsonMap.get('quantity');

            System.debug('pr >>' +  pr);
            productList.add(pr);

        }
        if(productList.size()>0){
            upsert productList Warehouse_SKU__c;
        }
     }
  }

  public static void execute(QueueableContext context){
    getWarehouseInventory();
  }
    
}