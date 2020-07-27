trigger OpliTrigger on OpportunityLineItem (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        Map<id, OpportunityLineItem> newMap = trigger.newMap;
        Set<Id> oppId = new Set<Id>();
        Set<Id> SyncQuotes = new Set<Id>();
       
        for(OpportunityLineItem opli : newMap.values()){
            oppId.add(opli.OpportunityId);            
        }
        // Get SyncedQuotes Quotes
        // 
        List<Opportunity> opps = [Select SyncedQuoteId
                            	From Opportunity 
                            	where id =: oppId];
        
        for(Opportunity opp : opps){
           	SyncQuotes.add(opp.SyncedQuoteId);      
        }

        // Get QOLIs
        // 
        List<QuoteLineItem> qolis = [Select id, IsSyncing__c
                                    	from QuoteLineItem
                                    	where QuoteId =: SyncQuotes];
        
        for(QuoteLineItem q : qolis){
            q.IsSyncing__c = true;
        }
        update qolis;
        
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        system.debug('Quantity ' + Trigger.new[0].Quantity);
        Map<id, OpportunityLineItem> newMap = trigger.newMap;
        Set<Id> oppId = new Set<Id>();

        // Get opportunities
        for(OpportunityLineItem opli : newMap.values()){
            oppId.add(opli.OpportunityId);            
        }
        List<Opportunity> opps = [Select id, SyncedQuoteId
                            		From Opportunity 
                            		where id =: oppId 
                                    and SyncedQuoteId != null];
        Set<Id> QuoteIdSet = new Set<Id>();
        // Get Ids
        for(Opportunity opp : opps){
            quoteIdSet.add(opp.SyncedQuoteId);            
        }
        // Get QOLIs
        List<QuoteLineItem> qoliList = [Select id, OpportunityLineItemId, Renewal__c, Quantity, Description, UnitPrice, Discount
                                       	from QuoteLineItem
                                       where QuoteId =: quoteIdSet];
        
        
        
        Map<id, QuoteLineItem> qoliMap = new Map<id, QuoteLineItem>();
        for(QuoteLineItem qoli : qoliList){
            qoliMap.put(qoli.OpportunityLineItemId, qoli);
        }
        
        List <QuoteLineItem> qolisUpdate = new List<QuoteLineItem>();
        for(OpportunityLineItem opli : newMap.values()){
            if(qoliMap.get(opli.id)!=null){
                QuoteLineItem qoli1 = updateCustomFields(qoliMap.get(opli.id), opli);
            	if(qoli1 != null){
                	qolisUpdate.add(qoli1);
            	}
            } 
        }
        if(qolisUpdate.size()>0){
            update qolisUpdate;
        }
        
    }
    
    private QuoteLineItem updateCustomFields (QuoteLineItem qoli, OpportunityLineItem opli){
        Boolean updated = false;
        if(qoli.Renewal__c != opli.Renewal__c){
           qoli.Renewal__c = opli.Renewal__c;
           updated = true;
        }
        if(qoli.Quantity != opli.Quantity){
           qoli.Quantity = opli.Quantity;
           updated = true;
        }
        if(qoli.Description != opli.Description){
           qoli.Description = opli.Description;
           updated = true;
        }
        if(qoli.UnitPrice  != opli.UnitPrice ){
           qoli.UnitPrice  = opli.UnitPrice ;
           updated = true;
        }
        if(qoli.Discount  != opli.Discount ){
           qoli.Discount  = opli.Discount ;
           updated = true;
        }
        if(updated){
            return qoli;
        }
        return null;
    }
}