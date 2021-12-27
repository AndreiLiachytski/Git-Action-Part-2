/**
 * @description       : Service class for Guest User Session handling.
 * @author            : Adrian Flores
 * @group             :
 * @last modified on  : 09-30-2021
 * @last modified by  : Adrian Flores
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   09-28-2021   Adrian Flores   Initial Version
 **/
public without sharing class B2BGuestUserSessionService {
    public List<GuestCartItem__c> processGuestCart() {
        List<GuestCartItem__c> guestCartItems = new List<GuestCartItem__c>(getGuestUserCartItems());
        if (!guestCartItems.isEmpty() && guestCartItems != null) {
            return guestCartItems;
        }
        return null;
    }

    //TODO need to rebuilt this
    private List<GuestCartItem__c> getGuestUserCartItems() {
        String guestUserSessionId = UserInfo.getSessionId();
        String getGuestUserCart = [SELECT Id FROM GuestCart__c WHERE Guest_User_Session_Id__c = :guestUserSessionId LIMIT 1].Id;
        List<GuestCartItem__c> gciList = new List<GuestCartItem__c>();
        for (GuestCartItem__c gci : [SELECT Id, Name FROM GuestCartItem__c WHERE CartId__c = :getGuestUserCart]) {
            gciList.add(gci);
        }
        return gciList;
    }
}