/**
 * Created by Админ on 29.12.2021.
 */

public with sharing class EventTriggerHandler {

    public static void handle(List<Event> newRecords, System.TriggerOperation triggerOperation) {

        Map<Id, List<Event>> mapEvents = EventTriggerHandler.getEventsOfUsers(newRecords);
        switch on triggerOperation {

            when BEFORE_INSERT {
                for (Event newRecord : newRecords) {
                    System.debug( mapEvents.get(newRecord.OwnerId));
                    for (Event event : mapEvents.get(newRecord.OwnerId)) {
                        if ((newRecord.StartDateTime < event.StartDateTime && newRecord.EndDateTime > event.StartDateTime) ||
                                (newRecord.EndDateTime > event.EndDateTime && newRecord.StartDateTime < event.EndDateTime) ||
                                (newRecord.StartDateTime >= event.StartDateTime && newRecord.EndDateTime <= event.EndDateTime)) {
                            newRecord.addError('You have already had an event at this time');
                            break;
                        }
                    }
                    mapEvents.get(newRecord.OwnerId).add(newRecord);

                }
            }

            when BEFORE_UPDATE {
                for (Event newRecord : newRecords) {
                    for (Event event : mapEvents.get(newRecord.OwnerId)) {
                        if (event.Id == newRecord.Id) {
                            continue;
                        }
                        if ((newRecord.StartDateTime < event.StartDateTime && newRecord.EndDateTime > event.StartDateTime) ||
                                (newRecord.EndDateTime > event.EndDateTime && newRecord.StartDateTime < event.EndDateTime) ||
                                (newRecord.StartDateTime >= event.StartDateTime && newRecord.EndDateTime <= event.EndDateTime)) {
                            newRecord.addError('You have already had an event at this time');
                        }
                    }
                }
            }
        }
    }

    private static Map<Id, List<Event>> getEventsOfUsers(List<Event> records) {
        Set<Id> users = new Set<Id>();
        for (Event record : records) {
            users.add(record.OwnerId);
        }
        Map<Id, List<Event>> mapEvents = new Map<Id, List<Event>>();
        for (Id user : users) {
            mapEvents.put(user, [SELECT Id, StartDateTime, EndDateTime FROM Event WHERE OwnerId = :user]);
        }
        return mapEvents;
    }

}