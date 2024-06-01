@IsTest
private class WarehouseCalloutServiceTest {
    // implement your mock callout test here
    @isTest  
    static void testWareHouseCallout(){
        
        WarehouseCalloutServiceMock calloutMock = new WarehouseCalloutServiceMock();
        Test.startTest();
        // implement mock callout test here
        Test.setMock(HTTPCalloutMock.class, calloutMock);
        System.enqueueJob(New WarehouseCalloutService());
        Test.stopTest();
        String expectdBody = '[{"_id":"55d66226726b611100aaf741","replacement":false,"quantity":5,"name":"Generator 1000 kW","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"100003"}]';
        Integer statusCode = 200;
        Map<Id,Product2> prodMap = new Map<Id,Product2>([SELECT name,Replacement_Part__c,Cost__c,Maintenance_Cycle__c FROM Product2]);
        for (Product2 prod : prodMap.values()) {
            System.debug('prod >>' + prod);
        }

        System.assertEquals(1, [SELECT count() FROM Product2],'Found products');

    
    }    

}