public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> workOrders, Map<Id,Case> nonUpdWorkOrderMap) {
        // TODO: Complete the method to update workorders

        //Write comment and commit to git hub!!!!!
        Set<Id> validIds = new Set<Id>();
        for(Case c : workOrders){
            if (nonUpdWorkOrderMap.get(c.id).Status != 'Closed' && c.Status == 'Closed') {
                if (c.Type == 'Repair' || c.Type == 'Routine Maintenance') {
                    validIds.add(c.Id);
                }
            }
        }

        if (!validIds.isEmpty()) {
            List<Case> newCases = new List<Case>();

            Map<Id,Case> closedCasesM = new Map<Id,Case>([SELECT Id, Vehicle__c, ProductId, Product.Maintenance_Cycle__c,(SELECT Id,Equipment__c,Quantity__c FROM Equipment_Maintenance_Items__r) 
            FROM Case WHERE Id IN :validIds]);

            Map<Id,Decimal> maintenanceCycles = new Map<Id,Decimal>();

            AggregateResult[] results = [SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)cycle FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :ValidIds GROUP BY Maintenance_Request__c];
            for(AggregateResult ar : results){
                maintenanceCycles.put((Id)ar.get('Maintenance_Request__c'), (Decimal)ar.get('cycle'));
            }
            
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

                if (maintenanceCycles.containsKey(cc.Id)) {
                    nc.Date_Due__c = Date.today().addDays((Integer)maintenanceCycles.get(cc.Id));
                }else {
                    nc.Date_Due__c = Date.today().addDays((Integer)cc.Product.maintenance_Cycle__c);
                }

                newCases.add(nc);

            }
            insert newCases;
            List<Equipment_Maintenance_Item__c> clonedWps = new List<Equipment_Maintenance_Item__c>();
            for (Case nc : newCases) {
                for (Equipment_Maintenance_Item__c wp : closedCasesM.get(nc.ParentId).Equipment_Maintenance_Items__r) {
                    Equipment_Maintenance_Item__c wpClone = wp.clone();
                    wpClone.Maintenance_Request__c  = nc.Id;
                    clonedWps.add(wpClone);
                }
            }
            insert clonedWps;
        }
        
    }        
    
}