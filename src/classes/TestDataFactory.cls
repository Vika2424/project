/**
 * Created by Админ on 02.01.2022.
 */
@IsTest
public class TestDataFactory {

    public static List<Event> getEvents(Integer num, Id owner, Integer interval, Datetime start, Integer duration) {
        List<Event> events = new List<Event>();
        for (Integer i = 0; i < num; i++) {
            events.add(new Event(OwnerId = owner, StartDateTime = start.addMinutes(i * interval), EndDateTime = start.addMinutes(duration + i * interval)));
        }
        return events;
    }

    public static void insertEvent(Id owner, Datetime start, Integer duration) {
        insert new Event(OwnerId = owner, StartDateTime = start, EndDateTime = start.addMinutes(duration));
    }

    public static List<Event> insertEvents(Integer num, Id owner, Integer interval, Datetime start, Integer duration) {
        List<Event> events = new List<Event>();
        for (Integer i = 0; i < num; i++) {
            events.add(new Event(OwnerId = owner, StartDateTime = start.addMinutes(i * interval), EndDateTime = start.addMinutes(duration + i * interval)));
        }
        insert events;
        return events;
    }
}