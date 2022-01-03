public with sharing class B2BCleanUpGuestCartBatch implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext bc) {

        DateTime dt_lastDay = System.now().addHours(-24);

        String query = 'SELECT ' +
            'Id, OwnerId, Name, Status__c, ' +
            'Type__c, Guest_User_Session_Id__c, LastModifiedDate ' +
            'FROM GuestCart__c ' +
            'WHERE Status__c LIKE \'%Delete\' ' +
            'OR LastModifiedDate <= :dt_lastDay';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<GuestCart__c> records) {
        if (!records.isEmpty()) {
            Database.delete(records, false);
        }
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new B2BCleanUpGuestCartBatch());
    }

    public void finish(Database.BatchableContext bc) {}

    public static void scheduleCleanUpGuestCart() {
        //Everyday at 01 AM
        String crone = '0 0 01 * * ?';
        System.schedule('Proceed Clean Up Guest Cart', crone, new B2BCleanUpGuestCartBatch());
    }
}