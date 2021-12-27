import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import CMS_DELIVERY_MEDIA_URL from '@salesforce/label/c.cmsDeliveryMediaUrl';

import getManagedContentByContentKeys from '@salesforce/apex/B2BHomePageBannerController.getManagedContentByContentKeys';

export default class B2BHomePageBanner extends NavigationMixin(LightningElement) {
    @api imageChangeInterval;
    @api bannerImageAmount;

    @api bannerContentPlace;
    @api bannerHeadingText;
    @api bannerSubHeadingText;
    @api bannerButtonText;
    @api bannerButtonLink;
    @api isBannerButtonDisplayed;

    @api desktopBannerImageId1;
    @api mobileBannerImageId1;
    @api bannerTextColor1;
    @api bannerSubTextColor1;
    @api bannerButtonColor1;
    @api bannerButtonTextColor1;

    @api desktopBannerImageId2;
    @api mobileBannerImageId2;
    @api bannerTextColor2;
    @api bannerSubTextColor2;
    @api bannerButtonColor2;
    @api bannerButtonTextColor2;

    @api desktopBannerImageId3;
    @api mobileBannerImageId3;
    @api bannerTextColor3;
    @api bannerSubTextColor3;
    @api bannerButtonColor3;
    @api bannerButtonTextColor3;

    @api desktopBannerImageId4;
    @api mobileBannerImageId4;
    @api bannerTextColor4;
    @api bannerSubTextColor4;
    @api bannerButtonColor4;
    @api bannerButtonTextColor4;

    @api desktopBannerImageId5;
    @api mobileBannerImageId5;
    @api bannerTextColor5;
    @api bannerSubTextColor5;
    @api bannerButtonColor5;
    @api bannerButtonTextColor5;

    @track desktopData = [];
    @track mobileData = [];
    @track desktopImages = [];
    @track mobileImages = [];
    @track navBarItems = [];

    currentView = 'desktop';
    currentImage = '';
    currentImageNum = 1;
    maxImageNum = 1;
    allImageDesktopNum = 1;
    allImageMobileNum = 1;
    imageChangeTimeOut;

    isFirstRender = true;
    isFirstTimeBannerImageRender = true;
    isNavButtonAndArrowsVisible = false;
    isBannerComponentVisible = false;

    get isArrowButtonVisible() {
        return (this.isNavButtonAndArrowsVisible && window.innerWidth > 480);
    }

    get isBannerButtonVisible() {
        return (this.isBannerButtonDisplayed);
    }

    connectedCallback() {
        this.getBannerImagesData();
    }

    renderedCallback() {
        if (this.isFirstTimeBannerImageRender) {
            let headingTextElement = this.template.querySelector('[data-id="headingText"]');
            if (headingTextElement) {
                this.template.querySelector('[data-id="headingText"]').style = 'color:' + this[`bannerTextColor${this.desktopData[0].num}`];
            }
            let subHeadingTextElement = this.template.querySelector('[data-id="subHeadingText"]');
            if (subHeadingTextElement) {
                this.template.querySelector('[data-id="subHeadingText"]').style = 'color:' + this[`bannerSubTextColor${this.desktopData[0].num}`];
            }
            let bannerButtonElement = this.template.querySelector('[data-id="bannerButton"]');
            if (bannerButtonElement) {
                let backgroundColor = 'background-color:' + this[`bannerButtonColor${this.desktopData[0].num}`];
                let textColor = 'color:' + this[`bannerButtonTextColor${this.desktopData[0].num}`];
                this.template.querySelector('[data-id="bannerButton"]').style = backgroundColor + ';' + textColor;
            }
            let bannerContentSectionElement = this.template.querySelector('[data-id="bannerContentSection"]');
            if (bannerContentSectionElement) {
                if (this.bannerContentPlace === 'left') {
                    this.template.querySelector('[data-id="bannerContentSection"]').style = 'align-items: flex-start;';
                }
                if (this.bannerContentPlace === 'center') {
                    this.template.querySelector('[data-id="bannerContentSection"]').style = 'align-items: center;';
                }
                if (this.bannerContentPlace === 'right') {
                    this.template.querySelector('[data-id="bannerContentSection"]').style = 'align-items: flex-end;';
                }
            }
        }
        if (this.isFirstRender) {
            this.setInitParameters();
            this.addResizelistener();
            this.isFirstRender = false;
        }
    }

    handleArrowButtonClick(event) {
        this.arrowButtonClickProcessing(event.target.dataset.action);
    }

    handleBannerButtonClick() {
        this.bannerButtonClickProcessing();
    }

    getBannerImagesData() {
        this.desktopData = this.prepareImageIdArray('desktopBannerImage');
        this.mobileData = this.prepareImageIdArray('mobileBannerImage');
        if (!this.desktopData.length || !this.mobileData.length) return;
        Promise.all([
            getManagedContentByContentKeys({
                managedContentIds: this.desktopData.map(data => data.id)
            }),
            getManagedContentByContentKeys({
                managedContentIds: this.mobileData.map(data => data.id)
            })
        ])
            .then(([ desktopImages, mobileImages ]) => {
                console.log('desktopImages:');
                console.log(desktopImages);
                console.log('mobileImages:');
                console.log(mobileImages);
                this.dataProcessing('desktopImages', desktopImages);
                this.dataProcessing('mobileImages', mobileImages);
                if (this.currentView === 'desktop' && this.desktopImages.length) {
                    this.currentImage = this.desktopImages[0].imageUrl;

                } else if ((this.currentView === 'mobile' && this.mobileImages.length)) {
                    this.currentImage = this.mobileImages[0].imageUrl;
                }
                this.maxImageNum = this.allImageDesktopNum;
                this.isBannerComponentVisible = true;
                this.prepareNavButtonSection();
                this.setImageChange();
            })
            .catch(error => {
                console.error(error);
            });
    }

    prepareImageIdArray(name) {
        let imageIdArray = [];
        for (let i = 1; i <= this.bannerImageAmount; i++) {
            console.log('this[`${name}Id${i}`]:');
            console.log(this[`${name}Id${i}`]);
            if (this[`desktopBannerImageId${i}`] && this[`mobileBannerImageId${i}`]) {
                imageIdArray.push({
                    id: this[`${name}Id${i}`],
                    num: i
                });
            }
        }
        if (imageIdArray.length > this.bannerImageAmount) {
            imageIdArray.splice(this.bannerImageAmount - imageIdArray.length);
        }
        return imageIdArray;
    }

    dataProcessing(name, data) {
        let sortedImages = [];
        let formattedData = data.items.map(imageItem => {
            return {
                id: imageItem.contentKey,
                imageUrl: imageItem.contentNodes.source.url
            }
        });
        if (name === 'desktopImages') {
            this.desktopData.forEach(desktopDataObj => {
                formattedData.forEach(imageData => {
                    if (desktopDataObj.id === imageData.id) { sortedImages.push(imageData); }
                });
            });
            this.desktopImages = sortedImages;
            this.allImageDesktopNum = data.total;
        } else {
            this.mobileData.forEach(mobileDataObj => {
                formattedData.forEach(imageData => {
                    if (mobileDataObj.id === imageData.id) { sortedImages.push(imageData); }
                });
            });
            this.mobileImages = sortedImages;
            this.allImageMobileNum = data.total;
        }
    }

    prepareNavButtonSection() {
        let navBarItems = [];
        for (let i = 1; i <= this.maxImageNum; i++) {
            navBarItems.push({
                id: `nav-bar-item-${i}`,
                cssClass: (i === 1) ? 'banner-navigation-item active' : 'banner-navigation-item'
            });
        }
        this.navBarItems = navBarItems;
        this.isNavButtonAndArrowsVisible = (navBarItems.length > 1);
    }

    setImageChange() {
        if (this.maxImageNum === 1) return;
        this.imageChangeTimeOut = window.setInterval(
            function() {
                this.imageChange();
            }.bind(this), this.imageChangeInterval * 1000
        );
    }

    imageChange() {
        this.currentImageNum = (this.currentImageNum === this.maxImageNum)
            ? 1
            : this.currentImageNum + 1;

        this.setCurrentData();
        this.updateNavBarItems();
    }

    setInitParameters() {
        this.currentView = (window.innerWidth >= 1024)
            ? 'desktop'
            : 'mobile';
    }

    addResizelistener() {
        window.addEventListener('resize', () => {
            this.resizeScreenProcessing();
        });
    }

    resizeScreenProcessing() {
        if (window.innerWidth >= 1024) {
            this.currentView = 'desktop';
            if (this.desktopImages.length) {
                this.currentImage = this.desktopImages[0].imageUrl;
            }
        } else {
            this.currentView = 'mobile';
            if (this.mobileImages.length) {
                this.currentImage = this.mobileImages[0].imageUrl;
            }
        }
        this.currentImageNum = 1;
        this.prepareNavButtonSection();
        this.updateImageChangeInterval();
    }

    updateImageChangeInterval() {
        if (this.maxImageNum === 1) return;
        window.clearInterval(this.imageChangeTimeOut);
        this.imageChangeTimeOut = window.setInterval(
            function() {
                this.imageChange();
            }.bind(this), this.imageChangeInterval * 1000
        );
    }

    arrowButtonClickProcessing(action) {
        if (action === 'prev' && this.currentImageNum > 1) {
            this.currentImageNum -= 1;
            this.setCurrentData();
        } else if (action === 'prev' && this.currentImageNum === 1) {
            this.currentImageNum = this.maxImageNum;
            this.setCurrentData();
        } else if (action === 'next' && this.currentImageNum < this.maxImageNum) {
            this.currentImageNum += 1;
            this.setCurrentData();
        } else if (action === 'next' && this.currentImageNum === this.maxImageNum) {
            this.currentImageNum = 1;
            this.setCurrentData();
        }
        this.updateNavBarItems();
        this.updateImageChangeInterval();
    }

    updateNavBarItems() {
        this.navBarItems.forEach((item, index) => {
            item.cssClass = (index + 1 === this.currentImageNum)
                ? 'banner-navigation-item active'
                : 'banner-navigation-item';
        });
    }

    setCurrentData() {
        this.currentImage = (this.currentView === 'desktop')
            ? this.desktopImages[this.currentImageNum - 1].imageUrl
            : this.mobileImages[this.currentImageNum - 1].imageUrl;

        this.isFirstTimeBannerImageRender = false;
        let headingTextElement = this.template.querySelector('[data-id="headingText"]');
        if (headingTextElement) {
            this.template.querySelector('[data-id="headingText"]').style = 'color:' + this[`bannerTextColor${this.desktopData[this.currentImageNum - 1].num}`];
        }
        let subHeadingTextElement = this.template.querySelector('[data-id="subHeadingText"]');
        if (subHeadingTextElement) {
            this.template.querySelector('[data-id="subHeadingText"]').style = 'color:' + this[`bannerSubTextColor${this.desktopData[this.currentImageNum - 1].num}`];;
        }
        let bannerButtonElement = this.template.querySelector('[data-id="bannerButton"]');
        if (bannerButtonElement) {
            let backgroundColor = 'background-color:' + this[`bannerButtonColor${this.desktopData[this.currentImageNum - 1].num}`];
            let textColor = 'color:' + this[`bannerButtonTextColor${this.desktopData[this.currentImageNum - 1].num}`];
            this.template.querySelector('[data-id="bannerButton"]').style = backgroundColor + ';' + textColor;
        }
    }

    bannerButtonClickProcessing() {
        this[NavigationMixin.Navigate](
            {
                type: 'standard__webPage',
                attributes: {
                    url: this.bannerButtonLink
                }
            },
            false
        );
    }
}