/**
 * Created by yurybialkevich on 25.10.21.
 */

public with sharing class B2BFooterV2Controller {
    private static final String MENU_LABEL = 'Footer Navigation';
    private static final String STATUS = 'Live';
    @AuraEnabled
    public static B2BResponse getNavigationMenuItem(){
        List<NavigationMenuItem> lItems = [SELECT Id, Label, Target, Status, NavigationLinkSet.MasterLabel
        FROM NavigationMenuItem
        WHERE Status = :STATUS AND NavigationLinkSet.MasterLabel =: MENU_LABEL];
        return new B2BResponse(true, lItems, 'success');
    }
}