public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> workOrders, Map<Id,Case> nonUpdWorkOrderMap) {
        // TODO: Complete the method to update workorders

        //Creating a set to store the Ids of the newly modified cases
        Set<Id> validIds = new Set<Id>();
        for(Case c : workOrders){
            if (nonUpdWorkOrderMap.get(c.id).Status != 'Closed' && c.Status == 'Closed') {
                if (c.Type == 'Repair' || c.Type == 'Routine Maintenance') {
                    validIds.add(c.Id);
                }
            }
        }

        //Null check on case list
        if (!validIds.isEmpty()) {
            //Instantiating a new case list
            List<Case> newCases = new List<Case>();
            
            //Querying salesforce for the cases and their products based on the modified case list passed in earlier
            Map<Id,Case> closedCasesM = new Map<Id,Case>([SELECT Id, Vehicle__c, ProductId, Product.Maintenance_Cycle__c,(SELECT Id,Equipment__c,Quantity__c FROM Equipment_Maintenance_Items__r) 
            FROM Case WHERE Id IN :validIds]);

            //Map to store case products 
            Map<Id,Decimal> maintenanceCycles = new Map<Id,Decimal>();

            //Querying salesforce for case and their assigned products then aggregating that list 
            AggregateResult[] results = [SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)cycle FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :ValidIds GROUP BY Maintenance_Request__c];
            for(AggregateResult ar : results){
                //Storing the id of the case and the products maintenance cycle in a map
                maintenanceCycles.put((Id)ar.get('Maintenance_Request__c'), (Decimal)ar.get('cycle'));
            }
            
            //Looping through the closed cases then using their values to automate new case creation 
            for(Case cc : closedCasesM.values()){
                Case nc = new Case();
                nc.ParentId = cc.Id; 
                nc.Status = 'New';
                nc.Subject = 'Routine Maintenance';
                nc.Type = 'Routine Maintenance';
                nc.Vehicle__c = cc.Vehicle__c;
                nc.ProductId = cc.ProductId;
                nc.Origin = 'Web';
                nc.Date_Reported__c = Date.today(); 

                //Checking the case product list then create a new maintenance cycle if one does not exist already
                if (maintenanceCycles.containsKey(cc.Id)) {
                    nc.Date_Due__c = Date.today().addDays((Integer)maintenanceCycles.get(cc.Id));
                }else {
                    nc.Date_Due__c = Date.today().addDays((Integer)cc.Product.maintenance_Cycle__c);
                }

                newCases.add(nc);

            }
            //Inserting new cases
            insert newCases;
            //Using the new case list to automate creating new junction objects based on the junction objects already existing in the cases
            List<Equipment_Maintenance_Item__c> clonedWps = new List<Equipment_Maintenance_Item__c>();
            for (Case nc : newCases) {
                for (Equipment_Maintenance_Item__c wp : closedCasesM.get(nc.ParentId).Equipment_Maintenance_Items__r) {
                    Equipment_Maintenance_Item__c wpClone = wp.clone();
                    wpClone.Maintenance_Request__c  = nc.Id;
                    clonedWps.add(wpClone);
                }
            }
            //Inserting new junction objects 
            insert clonedWps;
        }
        
    }        
    
}