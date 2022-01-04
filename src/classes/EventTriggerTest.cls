/**
 * Created by Админ on 02.01.2022.
 */

@IsTest
private class EventTriggerTest {


    @IsTest
    static void testInsertEventsSameTime() {

        List<Event> events = TestDataFactory.getEvents(10, UserInfo.getUserId(), 0, Datetime.now(), 60);

        Test.startTest();
        Database.SaveResult[] results = Database.insert(events, false);
        Test.stopTest();

        List<Event> events2 = [SELECT Id FROM Event];
        System.assert(results[0].isSuccess());
        for (Integer i = 1; i < results.size(); i++) {
            System.assert(!results[i].isSuccess());
        }
        System.assertEquals(1, events2.size());
    }

    @IsTest
    static void testInsertEventDifferentTime() {

        List<Event> events = TestDataFactory.getEvents(8, UserInfo.getUserId(), 60, Datetime.now(), 60);

        Test.startTest();
        Database.SaveResult[] results = Database.insert(events, false);
        Test.stopTest();

        List<Event> events2 = [SELECT Id FROM Event];
        for (Integer i = 0; i < results.size(); i++) {
            System.assert(results[i].isSuccess());
        }
        System.assertEquals(8, events2.size());
    }

    @IsTest
    static void testWithEarlyCollision() {
        TestDataFactory.insertEvent(UserInfo.getUserId(), Datetime.now(), 60);

        Event event = new Event(OwnerId = UserInfo.getUserId(), StartDateTime = Datetime.now().addMinutes(-20), EndDateTime = Datetime.now().addMinutes(30));

        Test.startTest();
        Database.insert(event, false);
        Test.stopTest();

        List<Event> events = [SELECT Id FROM Event];

        System.assertEquals(1, events.size());
    }

    @IsTest
    static void testWithLateCollision() {
        TestDataFactory.insertEvent(UserInfo.getUserId(), Datetime.now(), 60);

        Event event = new Event(OwnerId = UserInfo.getUserId(), StartDateTime = Datetime.now().addMinutes(20), EndDateTime = Datetime.now().addMinutes(80));

        Test.startTest();
        Database.insert(event, false);
        Test.stopTest();

        List<Event> events = [SELECT Id FROM Event];

        System.assertEquals(1, events.size());
    }

    @IsTest
    static void testWithInsideCollision() {
        TestDataFactory.insertEvent(UserInfo.getUserId(), Datetime.now(), 60);

        Event event = new Event(OwnerId = UserInfo.getUserId(), StartDateTime = Datetime.now().addMinutes(20), EndDateTime = Datetime.now().addMinutes(30));

        Test.startTest();
        Database.insert(event, false);
        Test.stopTest();

        List<Event> events = [SELECT Id FROM Event];

        System.assertEquals(1, events.size());
    }

    @IsTest
    static void testWithOutsideCollision() {
        TestDataFactory.insertEvent(UserInfo.getUserId(), Datetime.now(), 60);

        Event event = new Event(OwnerId = UserInfo.getUserId(), StartDateTime = Datetime.now().addMinutes(-20), EndDateTime = Datetime.now().addMinutes(80));

        Test.startTest();
        Database.insert(event, false);
        Test.stopTest();

        List<Event> events = [SELECT Id FROM Event];

        System.assertEquals(1, events.size());
    }

    @IsTest
    static void testUpdateSingleEvent() {
        Datetime currentTime = Datetime.now();
        TestDataFactory.insertEvent(UserInfo.getUserId(), currentTime, 60);
        Event event = [SELECT Id, StartDateTime, EndDateTime FROM Event];

        event.StartDateTime.addMinutes(20);
        event.EndDateTime.addMinutes(20);

        Test.startTest();
        Database.update(event, false);
        Test.stopTest();

        List<Event> events = [SELECT Id, StartDateTime, EndDateTime FROM Event];
        System.assertEquals(1, events.size());
        System.equals(currentTime.addMinutes(20).minute(), events[0].StartDateTime.minute());
        System.equals(currentTime.addMinutes(80).minute(), events[0].EndDateTime.minute());
    }

    @IsTest
    static void testUpdateWithCollision() {
        Datetime currentTime = Datetime.now();
        List<Event> events = TestDataFactory.insertEvents(4, UserInfo.getUserId(), 60, currentTime, 60);

        Id eventId = events[0].Id;
        events[0].StartDateTime = Datetime.now().addMinutes(20);
        events[0].EndDateTime = Datetime.now().addMinutes(80);

        Test.startTest();
        Database.SaveResult[] results = Database.update(events, false);
        Test.stopTest();

        System.assert(!results[0].isSuccess());
        List<Event> resultEvents = [SELECT Id FROM Event];
        System.assertEquals(4, resultEvents.size());

        Event event = [SELECT Id, StartDateTime, EndDateTime FROM Event WHERE Id = :eventId];
        System.assertEquals(currentTime, event.StartDateTime);
        System.assertEquals(currentTime.addMinutes(60), event.EndDateTime);
    }
}