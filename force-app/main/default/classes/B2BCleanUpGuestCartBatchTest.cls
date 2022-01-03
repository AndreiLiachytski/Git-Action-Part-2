@isTest
public with sharing class B2BCleanUpGuestCartBatchTest {
    @TestSetup
    static void makeData(){

        GuestCart__c testCart = B2BTestDataFactory.createGuestCart(false, '0ZE5g000000gD0fGAE');
        testCart.Name = 'TestCart';
        testCart.Status__c = 'PendingDelete';

        insert testCart;
    }

    @IsTest
    static void testJob(){
        Test.startTest();
            Id batchJobId = Database.executeBatch(new B2BCleanUpGuestCartBatch(), 1);
        Test.stopTest();

        List<GuestCart__c> cartsForDelete = [SELECT Id, Name, Status__c FROM GuestCart__c WHERE Status__c LIKE '%Delete'];
        System.assert(cartsForDelete.isEmpty());

    }


    @IsTest 
    static void testScheduleExecuteBatch() {

        String crone = '0 0 01 * * ?';

        Test.startTest();
        String jobId = System.schedule('TestBatchName', crone, new B2BCleanUpGuestCartBatch());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(crone, ct.CronExpression);
    }

}