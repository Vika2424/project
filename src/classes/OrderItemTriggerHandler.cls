/**
 * Created by Админ on 04.01.2022.
 */

public with sharing class OrderItemTriggerHandler {

    public static void handle(List<OrderItem> newRecords, Map<Id, OrderItem> oldMap, System.TriggerOperation triggerOperation) {
        switch on triggerOperation {
            
            when BEFORE_INSERT {
                Map<Id, Product2> mapProducts = getMapProducts(newRecords);

                for (OrderItem newRecord : newRecords) {
                    mapProducts.get(newRecord.Product2Id).Total_Amount__c += newRecord.Quantity;
                }
                update mapProducts.values();
            }

            when BEFORE_UPDATE {

            }
        }
    }

    private static Map<Id, Product2> getMapProducts(List<OrderItem> orderItems) {
        Set<Id> productsId = new Set<Id>();
        for (OrderItem orderItem : orderItems) {
            productsId.add(orderItem.Product2Id);
        }
        return new Map<Id, Product2>([SELECT Id, Total_Amount__c FROM Product2]);
    }
}