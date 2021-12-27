@IsTest
private class B2BPopularCategoriesPickListTest {

    private static final String POPULAR_CATEGORY_NAME = 'Test Category';
    private static B2BPopularCategoriesPickList popularCategoriesPickList = new B2BPopularCategoriesPickList();

    @TestSetup
    static void testData() {
        B2BTestDataFactory.createGuestUser(true, 'testChittsUser@gmail.com');
        ProductCatalog productCatalog = B2BTestDataFactory.createProductCatalog(true,'SomeTestCatalog');
        ProductCategory productCategory = B2BTestDataFactory.createProductCategory(true, productCatalog.Id, POPULAR_CATEGORY_NAME);
        productCategory.Popular_Category__c = true;
        productCategory.Sequence__c = 1;
        update productCategory;
    }

    @IsTest
    static void getDefaultValue_Test_Positive() {
        User guestUser = [SELECT Id FROM User WHERE Username = 'testChittsUser@gmail.com'];
        String defaultLabel = B2BPopularCategoriesPickList.DEFAULT_LABEL;
        String defaultValue = ' ';
        VisualEditor.DataRow dataRow;

        System.runAs(guestUser) {
            Test.startTest();
            dataRow = popularCategoriesPickList.getDefaultValue();
            Test.stopTest();
        }
        String label = dataRow.getLabel();
        Object value = dataRow.getValue();
        System.assert(!dataRow.isSelected(), 'Expected isSelected = false.');
        System.assertEquals(label, defaultLabel, 'Expected Default label.');
        System.assertEquals(value, defaultValue, 'Expected empty line.');
    }

    @IsTest
    static void getValues_Test_Positive() {
        User guestUser = [SELECT Id FROM User WHERE Username = 'testChittsUser@gmail.com'];
        VisualEditor.DynamicPickListRows pickListValues;

        System.runAs(guestUser) {
            Test.startTest();
            pickListValues = popularCategoriesPickList.getValues();
            Test.stopTest();
        }
        String categoryName = pickListValues.get(1).getLabel();
        System.assert(pickListValues.containsAllRows(), 'Expected Success.');
        System.assertEquals(categoryName, POPULAR_CATEGORY_NAME, 'Expected Success.');
    }
}

