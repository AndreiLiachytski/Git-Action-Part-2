global without sharing class B2BPopularCategoriesPickList extends VisualEditor.DynamicPickList {

    public static final String DEFAULT_LABEL = 'Choose category';
    public static final String EMPTY_LABEL = 'Not selected';
    public static final VisualEditor.DynamicPickListRows PICKLIST_VALUES = new VisualEditor.DynamicPickListRows();

    global override VisualEditor.DataRow getDefaultValue() {
        return new VisualEditor.DataRow(DEFAULT_LABEL, ' ');
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        List<ProductCategory> productCategories = getProductCategories();
        return (PICKLIST_VALUES.getDataRows().isEmpty()) ? getPickListValues(productCategories) : PICKLIST_VALUES;
    }

    @TestVisible
    private static List<ProductCategory> getProductCategories() {
        List<ProductCategory> productCategories = [
            SELECT Id, Name
            FROM ProductCategory
            WHERE is_Popular_Category__c = TRUE
            ORDER BY Popular_sequence__c DESC, Name NULLS LAST
        ];
        return productCategories;
    }

    @TestVisible
    private static VisualEditor.DynamicPickListRows getPickListValues(List<ProductCategory> productCategories) {
        PICKLIST_VALUES.addRow(new VisualEditor.DataRow(EMPTY_LABEL, ' '));

        for (ProductCategory category : productCategories) {
            VisualEditor.DataRow value = new VisualEditor.DataRow(
                category.Name,
                String.valueOf(category.Id)
            );
            PICKLIST_VALUES.addRow(value);
        }
        return PICKLIST_VALUES;
    }
}

