
global with sharing class WarehouseSyncSchedule implements Schedulable {
    //Implement the execute method that calls the callout class
    global void execute(SchedulableContext sc ){
       System.enqueueJob(new WarehouseCalloutService());
    }
}