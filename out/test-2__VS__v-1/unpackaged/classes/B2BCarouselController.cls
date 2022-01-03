public with sharing class B2BCarouselController {

    @AuraEnabled
    public static List<B2BProductController.ProductImage> getProductImages(String productId, String effectiveAccountId) {
        List<B2BProductController.ProductImage> productImages = B2BProductController.getProductImages(productId, effectiveAccountId);
        return productImages;
    }
    
}