import {LightningElement, api, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getPopularCategories from '@salesforce/apex/B2BPopularCategoryController.getPopularCategories';
import getBannerImageUrl from '@salesforce/apex/B2BPopularCategoryController.getBannerImageUrl';
import isGuest from '@salesforce/user/isGuest';

const LABELS = {
    mainLabel: 'POPULAR CATEGORIES',
    bannerTextLabel: 'SAVE 15% ON ROASTING STICKS',
};

export default class B2BPopularCategories extends NavigationMixin(LightningElement) {

    @api popularCategory1;
    @api popularCategory2;
    @api popularCategory3;
    @api popularCategory4;
    @api popularCategory5;
    @api popularCategory6;
    @api bannerImageContentKey;
    @api effectiveAccountId;
    @api placeForCategoryName;
    @api bannerOnclickURL;
    @api categoryTitleColor;
    @api categoryTitleBackgroundColor;
    @api categoryImageOpacity;

    bannerImageURL;
    labels = LABELS;
    isTopCategoryName = false;
    isMiddleCategoryName = false;
    isBottomCategoryName = false;

    @track categoriesIdFromBuilder = [];
    parsedCategoriesToHTML = [];

    connectedCallback() {
        this.getBannerImageUrl();
        this.getCategoriesIdList();
        this.getCategoriesData();
        this.getPositionForCategoryName();
    }

    renderedCallback() {
        this.addCustomCssStyles();
    }

    getCategoriesData() {
        if (isGuest || this.effectiveAccountId === '000000000000000') {
            this.effectiveAccountId = null;
        }
        getPopularCategories({
            categoriesId: this.categoriesIdFromBuilder.map(data => data.id),
            effectiveAccountId: this.effectiveAccountId,
        }).then(result => {
            this.parseCategoriesToHTML(result.responseData)
        }).catch(error => {
            this.error = error;
            console.error(error);
            this.result = undefined;
        });
    }

    navigateToBannerOnclick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.bannerOnclickURL
            }
        });
    }

    getBannerImageUrl() {
        getBannerImageUrl({
            bannerImageContentKey: this.bannerImageContentKey
        }).then(result => {
            this.bannerImageURL = result.responseData.url;
        }).catch(error => {
            this.error = error;
            console.error(error);
            this.result = undefined;
        });
    }

    getCategoriesIdList() {
        for (let i = 1; i <= 6; i++) {
            this.categoriesIdFromBuilder.push({
                id: this[`popularCategory${i}`],
            });
        }
        return this.categoriesIdFromBuilder;
    }

    parseCategoriesToHTML(dataArray) {
        let array = [];
        let newCategory;
        for (let i = 1; i <= Object.entries(dataArray).length; i++) {
            let key = this[`popularCategory${i}`] + i;
            newCategory = {
                num: i,
                name: dataArray[key].name,
                url: dataArray[key].url,
            }
            array.push(newCategory)
        }
        this.parsedCategoriesToHTML = array;
    }

    getPositionForCategoryName() {
        if (this.placeForCategoryName === 'top') {
            this.isTopCategoryName = true;
            this.isMiddleCategoryName = false;
            this.isBottomCategoryName = false;
        } else if (this.placeForCategoryName === 'middle') {
            this.isTopCategoryName = false;
            this.isMiddleCategoryName = true;
            this.isBottomCategoryName = false;
        } else if (this.placeForCategoryName === 'bottom') {
            this.isTopCategoryName = false;
            this.isMiddleCategoryName = false;
            this.isBottomCategoryName = true;
        }
    }

    addCustomCssStyles() {
        const style = document.createElement('style');
        let customCssStyles = `
          .middle-position-category-image {
                opacity:${this.categoryImageOpacity}%;
                border-radius: 4px;
                height:100%;
                width: 100%;                         
            }
          .rectangle-category-name {
                background-color:${this.categoryTitleBackgroundColor};
                height: 80px;
            } 
          .category-name{
                color:${this.categoryTitleColor};
            }
        `;
        style.innerText = customCssStyles.replace(/ +(?= )|\n/g, '');
        this.template.querySelector('.custom-css-container').appendChild(style);
    }
}

