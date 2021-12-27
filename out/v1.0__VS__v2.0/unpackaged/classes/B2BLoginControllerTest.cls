@IsTest
public with sharing class B2BLoginControllerTest {
    private static String result;

    @TestSetup
    private static void setup() {
        WebStore testStore = B2BTestDataFactory.createWebStore(true, 'TestStore');
        Account account = B2BTestDataFactory.createAccount(true, 'TestAccount');
        Contact contact = B2BTestDataFactory.createContact(true, 'TestContact', account.Id);
    }

    @IsTest
    private static void testCustomLoginAsUser() {
        Contact contact = [SELECT Id FROM Contact WHERE Name = 'TestContact' LIMIT 1];
        User communityUser = B2BTestDataFactory.createCommunityUser(true, contact.Id);

        Test.startTest();
        System.runAs(communityUser) {
            try {
                String password = 'Password@1234';
                String startUrl = 'community.com';
                System.setPassword(communityUser.Id, password);
                String username = communityUser.Username;

                String result = B2BLoginController.login(username, password, startUrl, 'edwed3ddvk-ev-');

                System.debug(result);
            } catch (Exception ex) {
                String result = ex.getMessage();
            }
        }
        Test.stopTest();

        System.assertEquals(null, result, 'User has not permission to login');
    }

    @IsTest
    private static void moveGuestCartToUserCartTest() {
        Account testAccount = [SELECT Id, OwnerId FROM Account WHERE Name = 'TestAccount'];
        Contact testContact = [SELECT Id, OwnerId FROM Contact WHERE Name = 'TestContact' LIMIT 1];
        WebStore testStore = [SELECT Id FROM WebStore LIMIT 1];

        System.debug([SELECT Id FROM CartItem]);

        Product2 testProduct = B2BTestDataFactory.createProduct(true, 'TestProduct', '123_Code');
        GuestCart__c testGuestUserCart = B2BTestDataFactory.createGuestCart(true, testStore.Id);
        B2BTestDataFactory.createGuestCartItem(true, testGuestUserCart.Id, testProduct.Id, 1);

        User commUser = B2BTestDataFactory.createCommunityUser(true, testContact.Id);
        B2BLoginController.userLogin = commUser.Username;
        System.runAs(commUser) {
            Test.startTest();
            WebCart testUserCart = B2BTestDataFactory.createCart(true, testStore.Id, testAccount.Id, commUser.Id);
            B2BTestDataFactory.createCartDeliveryGroup(true, testUserCart.Id);
            B2BLoginController.moveGuestCartToUserCart(testGuestUserCart.Guest_User_Session_Id__c);
            Test.stopTest();
        }

        System.assertEquals(1, [SELECT Id FROM CartItem WHERE Product2Id = :testProduct.Id].size(), 'New Cart Item record not replaced from Guest Cart for logged User');
    }

    @IsTest
    private static void moveGuestCartToUserCartNoUserCartTest() {
        Contact testContact = [SELECT Id, OwnerId FROM Contact WHERE Name = 'TestContact' LIMIT 1];
        WebStore testStore = [SELECT Id FROM WebStore LIMIT 1];

        Product2 testProduct = B2BTestDataFactory.createProduct(true, 'TestProduct', '123_Code');
        GuestCart__c testGuestUserCart = B2BTestDataFactory.createGuestCart(true, testStore.Id);
        B2BTestDataFactory.createGuestCartItem(true, testGuestUserCart.Id, testProduct.Id, 1);
        OrderDeliveryMethod orderDeliveryMethod = B2BTestDataFactory.createOrderDeliveryMethod(true);
        B2BTestDataFactory.createGuestCartDeliveryGroup(true, testGuestUserCart.Id, orderDeliveryMethod.Id);

        User commUser = B2BTestDataFactory.createCommunityUser(true, testContact.Id);
        B2BLoginController.userLogin = commUser.Username;
        System.runAs(commUser) {
            Test.startTest();
            B2BLoginController.moveGuestCartToUserCart(testGuestUserCart.Guest_User_Session_Id__c);
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT Id FROM WebCart WHERE OwnerId = :commUser.Id].size(), 'New Web Cart record not created for logged User');
        System.assertEquals(1, [SELECT Id FROM CartItem WHERE Product2Id = :testProduct.Id].size(), 'New Cart Item record not replaced from Guest Cart for logged User');
    }
}