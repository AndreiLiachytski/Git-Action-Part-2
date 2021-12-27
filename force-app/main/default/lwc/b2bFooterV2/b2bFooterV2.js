/**
 * Created by yurybialkevich on 19.10.21.
 */

import {api, LightningElement, track} from 'lwc';
import instagramLogo from '@salesforce/resourceUrl/instagramLogo'
import FacebookLogo from '@salesforce/resourceUrl/FacebookLogo'
import LinkedInLogo from '@salesforce/resourceUrl/LinkedInLogo'
import CompanyLogo from '@salesforce/resourceUrl/CompanyLogo'
import PinImage from '@salesforce/resourceUrl/pinLogo'
import PhoneImage from '@salesforce/resourceUrl/phoneLogo'
import line from '@salesforce/resourceUrl/line'
import getNavigationMenuItem from '@salesforce/apex/B2BFooterV2Controller.getNavigationMenuItem'

export default class B2BFooterV2 extends LightningElement {
    @api companyAddress;
    @api companyPhone;
    @api facebookLink
    @api linkedinLink;
    @api instagramLink;
    @api copyrightText;
    @api companyLink;

    @track line = line;
    @track navigationMenuItems = [];

    @track socialIcons = {
        facebook: '',
        instagram: '',
        linkedIn: '',
        company: '',
        pin: '',
        phone: ''
    };

    connectedCallback() {
        this.configureLogo();
        this.getNavigationMenuItem();
    }

    getNavigationMenuItem() {
        getNavigationMenuItem()
            .then(result => {
                if (result.isSuccess) {
                    this.navigationMenuItems = result.responseData;
                    console.log('nav menu item ' + this.navigationMenuItems);
                }
            })
            .catch(error => {
                console.error(error);
            });
    }

    configureLogo() {
        this.socialIcons.facebook = FacebookLogo;
        this.socialIcons.instagram = instagramLogo;
        this.socialIcons.linkedIn = LinkedInLogo;
        this.socialIcons.company = CompanyLogo;
        this.socialIcons.pin = PinImage;
        this.socialIcons.phone = PhoneImage;
    }

    get getCopyrightLabel() {
        if (this.copyrightText) {
            return this.copyrightText.replace('YYYY', new Date().getFullYear());
        } else {
            return `© ${new Date().getFullYear()}, Forte Group All rights reserved`;
        }
    }
}