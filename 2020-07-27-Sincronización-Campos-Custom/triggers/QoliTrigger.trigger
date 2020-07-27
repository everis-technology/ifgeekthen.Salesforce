trigger QoliTrigger on QuoteLineItem (after update) {
    Map<Id, QuoteLineItem> newMap = Trigger.newMap;
    Map<Id, QuoteLineItem> oldMap = Trigger.oldMap;
    
    Set<Id> setOplis = new Set<Id>();
    List<QuoteLineItem> setQolis = new List<QuoteLineItem>();
    
    // Get OPLIs being syncronized
    for (Id i : newMap.keySet()){
        QuoteLineItem newQ = newMap.get(i);
        //QuoteLineItem oldQ = oldMap.get(i);
        if(newQ.IsSyncing__c /*&& !oldQ.IsSyncing__c*/){
            setOplis.add(newQ.OpportunityLineItemId);
            setQolis.add(newQ);
        }
    }
    
    // Get OPLIs
    List <OpportunityLineItem> opliList =  [Select id, Renewal__c, Quantity, Description, UnitPrice, Discount
                                           		From OpportunityLineItem
                                           		Where id =: setOplis];
    Map<Id, OpportunityLineItem> opliMap = new Map<Id, OpportunityLineItem>();
    for(OpportunityLineItem o : opliList){
        opliMap.put(o.id, o);
    }
    
    // Relate QOLIs with OPLIs
    List <OpportunityLineItem> opliListUpdate = new List <OpportunityLineItem>();
    Map<Id, OpportunityLineItem> ql_opl = new Map<Id, OpportunityLineItem>();
    for(QuoteLineItem q : setQolis){
		ql_opl.put(q.ID, opliMap.get(q.OpportunityLineItemId));
        OpportunityLineItem opli = updateCustomFields(q, opliMap.get(q.OpportunityLineItemId));
        if(opli!=null){
           opliListUpdate.add(opli); 
        }
    }
    
    if(opliListUpdate.size()>0){
        update opliListUpdate;       
    }
    
    
    private OpportunityLineItem updateCustomFields (QuoteLineItem qoli, OpportunityLineItem opli){
        Boolean updated = false;
        if(qoli.Renewal__c != opli.Renewal__c){
           opli.Renewal__c = qoli.Renewal__c;
            updated = true;
        }
        if(qoli.Quantity != opli.Quantity){
           opli.Quantity = qoli.Quantity;
           updated = true;
        }
        if(qoli.Description != opli.Description){
           opli.Description = qoli.Description;
           updated = true;
        }
        if(qoli.UnitPrice  != opli.UnitPrice ){
           opli.UnitPrice  = qoli.UnitPrice ;
           updated = true;
        }
        if(qoli.Discount  != opli.Discount ){
           opli.Discount  = qoli.Discount ;
           updated = true;
        }
        if(updated){
            return opli;
        }
        return null;
        
        
    }
}