/**
 * Created by Админ on 04.01.2022.
 */

trigger OrderItemTrigger on OrderItem (before insert, before update) {

    OrderItemTriggerHandler.handle(Trigger.new, Trigger.oldMap, Trigger.operationType);
}