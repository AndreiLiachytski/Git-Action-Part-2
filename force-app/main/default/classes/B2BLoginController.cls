public without sharing class B2BLoginController {

    @TestVisible
    private static String userLogin;

    @AuraEnabled
    public static String login(String userName, String password, String startUrl, String sessionId) {
        try {
            System.PageReference lgn = Site.login(userName, password, startUrl);
            userLogin = userName;

            moveGuestCartToUserCart(sessionId);

            return lgn.getUrl();
        } catch (Exception ex) {
            AuraHandledException handledException = new AuraHandledException(ex.getMessage());
            handledException.setMessage(ex.getMessage());
            throw handledException;
        }
    }


    @TestVisible
    private static void moveGuestCartToUserCart(String guestSessionId) {
        if (userLogin != null && String.isNotEmpty(guestSessionId)) {
            User currentUser = [
                    SELECT Id, Name, AccountId, Username
                    FROM User
                    WHERE Username = :userLogin
                    LIMIT 1
            ];

            List<GuestCart__c> guestUserCarts = [
                    SELECT Id, Status__c, Name, AccountId__c, WebStoreId__c, Type__c, Guest_User_Session_Id__c,
                            BillingCity__c, BillingCountry__c, BillingState__c, BillingStreet__c, BillingPostalCode__c
                    FROM GuestCart__c
                    WHERE Guest_User_Session_Id__c = :guestSessionId AND Status__c = 'Active'
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];

            if (!guestUserCarts.isEmpty()) {
                GuestCart__c guestUserCart = guestUserCarts[0];

                List<WebCart> userCart = [
                        SELECT Id, AccountId, GrandTotalAmount, WebStoreId, OwnerId
                        FROM WebCart
                        WHERE Status = 'Active'AND WebStoreId = :guestUserCart.WebStoreId__c AND CreatedById = :currentUser.Id
                        LIMIT 1
                ];

                List<GuestCartItem__c> guestCartItems = [
                        SELECT Id, CartId__c, Sku__c, Name, Type__c, Quantity__c,
                                TotalPrice__c, TotalAmount__c, Product2Id__c
                        FROM GuestCartItem__c
                        WHERE CartId__c = :guestUserCart.Id
                ];

                Map<Id, GuestCartItem__c> guestCartItemByGuestProductIds = new Map<Id, GuestCartItem__c>();
                if (!guestCartItems.isEmpty()) {
                    for (GuestCartItem__c guestCartItem : guestCartItems) {
                        guestCartItemByGuestProductIds.put(guestCartItem.Product2Id__c, guestCartItem);
                    }
                }

                Map<Id, Product2> guestUserProducts = new Map<Id, Product2>([
                        SELECT Id, Name
                        FROM Product2
                        WHERE Id IN :guestCartItemByGuestProductIds.keySet()
                ]);

                List<CartItem> newCartItemToInsert = new List<CartItem>();
                if (userCart.isEmpty()) {

                    //create webCart
                    WebCart newUserWebCart = new WebCart(
                            WebStoreId = guestUserCart.WebStoreId__c,
                            Name = guestUserCart.Name,
                            AccountId = currentUser.AccountId,
                            Status = 'Active',
                            BillingCity = guestUserCart.BillingCity__c,
                            BillingCountry = guestUserCart.BillingCountry__c,
                            BillingPostalCode = guestUserCart.BillingPostalCode__c,
                            BillingState = guestUserCart.BillingState__c,
                            BillingStreet = guestUserCart.BillingStreet__c,
                            Type = guestUserCart.Type__c,
                            OwnerId = currentUser.Id
                    );
                    insert newUserWebCart;

                    GuestCartDeliveryGroup__c guestCartDeliveryGroup = [
                            SELECT Id, Name, Cart__c, DeliverToCity__c, DeliverToCountry__c, DeliverToPostalCode__c,
                                    DeliverToState__c, DeliverToStreet__c, DesiredDeliveryDate__c,
                                    OrderDeliveryMethodId__c, ShippingInstructions__c
                            FROM GuestCartDeliveryGroup__c
                            WHERE Cart__c = :guestUserCart.Id
                    ];

                    CartDeliveryGroup newCartDeliveryGroup = new CartDeliveryGroup(
                            Name = guestCartDeliveryGroup.Name,
                            CartId = newUserWebCart.Id,
                            DeliverToCity = guestCartDeliveryGroup.DeliverToCity__c,
                            DeliverToCountry = guestCartDeliveryGroup.DeliverToCountry__c,
                            DeliverToPostalCode = guestCartDeliveryGroup.DeliverToPostalCode__c,
                            DeliverToState = guestCartDeliveryGroup.DeliverToState__c,
                            DeliverToStreet = guestCartDeliveryGroup.DeliverToStreet__c,
                            DesiredDeliveryDate = guestCartDeliveryGroup.DesiredDeliveryDate__c,
                            DeliveryMethodId = guestCartDeliveryGroup.OrderDeliveryMethodId__c,
                            ShippingInstructions = guestCartDeliveryGroup.ShippingInstructions__c
                    );
                    insert newCartDeliveryGroup;

                    //create cartItems
                    for (Product2 guestProduct : guestUserProducts.values()) {
                        newCartItemToInsert.add(new CartItem(
                                Name = guestProduct.Name,
                                Product2Id = guestProduct.Id,
                                CartId = newUserWebCart.Id,
                                CartDeliveryGroupId = newCartDeliveryGroup.Id,
                                Quantity = guestCartItemByGuestProductIds.get(guestProduct.Id).Quantity__c
                        ));
                    }
                } else {
                    Set<Id> existedInCartProductIds = new Set<Id>();
                    Id cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :userCart[0].Id][0].Id;

                    for (CartItem cartItem : [
                            SELECT Id, Product2Id
                            FROM CartItem
                            WHERE CartId = :userCart[0].Id
                    ]) {
                        existedInCartProductIds.add(cartItem.Product2Id);
                    }

                    //add new cartItems
                    for (Id guestProductId : guestCartItemByGuestProductIds.keySet()) {
                        if (!existedInCartProductIds.contains(guestProductId)) {
                            newCartItemToInsert.add(new CartItem(
                                    Name = guestUserProducts.get(guestProductId).Name,
                                    Product2Id = guestProductId,
                                    CartId = userCart[0].Id,
                                    CartDeliveryGroupId = cartDeliveryGroupId,
                                    Quantity = guestCartItemByGuestProductIds.get(guestProductId).Quantity__c
                            ));
                        }
                    }
                }
                insert newCartItemToInsert;

                //mark guestCartItems as PendingDelete
                guestUserCart.Status__c = 'PendingDelete';
                update guestUserCart;
            }
        }
    }
}