public class DocusignSignerDetail {
    /** 
     * This class represent detail of a signer
     **/
    public string name;
    public string email;
    public string signingGroupId;
    public string signingGroupName;
    public string recipientId;
    public string clientUserId;
    public string routingOrder;
    public string note;
    public string roleName;
    public string recipientType;
    // public DocusignSignHereTabs tabs;
    public DocusignTabs tabs;                   // ADDED BY THIEU DANG VU - Fri 6th Nov 2020
    public string accessCode;

    public static integer recipientIDCount = 0; // incremental recipient ID
    public static boolean isUCA = false;

    /**
    * build a complete signer detail object from provided information
    **/
    public static DocusignSignerDetail build(DocuSign_Recipient_Configuration__mdt recipientConfigs, Map<string, Map<string, string>> signingGroupsInfo, Sales_Agreement__c currentSA) {
        system.debug('---------- Docusign Signer Detail build ----------');

        // instantiate the object with basic information & place holder
        DocusignSignerDetail signerObj = new DocusignSignerDetail(recipientConfigs);

        // add detail from signing group
        signerObj = signerObj.addSigningGroupInfo(signingGroupsInfo);

        // add detail of sales agreement
        signerObj = signerObj.addSalesAgreementInfo(currentSA);

        // add sign here tab for signer recipient
        if (signerObj.recipientType == 'Signer') signerObj = signerObj.addSignHereTab(recipientConfigs);

        system.debug(signerObj);
        system.debug('---------- Docusign Signer Detail build finish ----------');
        return signerObj;
    }

    public DocusignSignerDetail() {}

    /**
    * construct new signer detail object with basic skeleton of object
    * detail information need to be addedd from sales agreement, signing group & recipient config
    **/
    public DocusignSignerDetail(DocuSign_Recipient_Configuration__mdt recipientConfigs) {
        
        // not very flexible here
        if (recipientConfigs.Signing_Scenario__c == 'C' || recipientConfigs.Signing_Scenario__c == 'D') isUCA = true;
        string signingGroupType = recipientConfigs.Signing_Group__c;

        // place holder for name & email
        this.name = '';
        this.email = '';
        if (string.isBlank(this.name)) this.name = recipientConfigs.Sales_Consultant__c? '_consultant' : '';
        if (string.isBlank(this.name)) this.name = recipientConfigs.Customer__c? '_customer' : '';
        if (string.isBlank(this.name)) this.name = recipientConfigs.Used_Car_Seller__c? '_UCA_Seller' : '';
        system.debug('***** Place holder name in Docusign signer detail *****');
        system.debug(this.name);

        // place holder for private note
        this.note = string.isEmpty(signingGroupType) ? '' : signingGroupType;
        if (string.isBlank(this.note)) this.note = recipientConfigs.Sales_Consultant__c? '_consultant' : '';
        if (string.isBlank(this.note)) this.note = recipientConfigs.Customer__c? '_customer' : '';
        if (string.isBlank(this.note)) this.note = recipientConfigs.Used_Car_Seller__c? '_UCA_Seller' : '';
        system.debug('***** Place holder private note in Docusign signer detail *****');
        system.debug(this.note);


        // signing group information place holder
        this.signingGroupId = string.isEmpty(signingGroupType) ? '' : signingGroupType;
        this.signingGroupName = string.isEmpty(signingGroupType) ? '' : signingGroupType;
        
        // other attributes of recipient
        recipientIDCount += 1;
        this.recipientId = string.valueOf(recipientIDCount);
        this.routingOrder = recipientConfigs.Signing_Order__c;
        this.roleName = recipientConfigs.Recipient_Type__c + ' ' + recipientConfigs.Signing_Order__c;
        this.recipientType = recipientConfigs.Recipient_Type__c;
        this.clientUserId = recipientConfigs.Signing_Method__c == 'Direct'? recipientConfigs.Signing_Order__c : '';
    }

    /**
    * add signing group detail
    **/
    public DocusignSignerDetail addSigningGroupInfo(Map<string, Map<string, string>> signingGroupsInfoMap) {
        if (!string.isEmpty(this.signingGroupId)) {
            string groupType = this.signingGroupId;
            this.signingGroupId = signingGroupsInfoMap.get(groupType).get('ID');
            this.signingGroupName = signingGroupsInfoMap.get(groupType).get('Name');
        }
        return this;
    }

    /**
    * add sales agreement detail
    **/
    public DocusignSignerDetail addSalesAgreementInfo(Sales_Agreement__c currentSA) {
        
        // add name, email & access code
        string recipientFullName = string.isEmpty(currentSA.Customer_Full_Name__c) ? currentSA.Company_Name__c : currentSA.Customer_Full_Name__c;
        if (!string.isEmpty(this.name)) {
            switch on this.name {
                when '_customer' {
                    if (!Test.isRunningTest() && string.isEmpty(currentSA.emailaddress__c)) throw new AuraHandledException('Error on building recipient object -- Customer do not have email');
                    this.email = currentSA.emailaddress__c;
                    this.name = this.recipientType != 'Signer'? recipientFullName + ' (' + this.recipientType.toLowerCase() + ')' : recipientFullName;
                    // access code for customer sign via email
                    if (string.isBlank(this.clientUserId)) {
                        try {
                            switch on currentSA.Registration_Type__c {
                                when 'P' {this.accessCode = currentSA.NRIC_Number__c.toUpperCase().right(4).rightPad(4, '*');}
                                when 'C' {this.accessCode = currentSA.ARCA_Number__c.toUpperCase().right(4).rightPad(4, '*');}
                                when else {this.accessCode = 'C&C';} // default password, subject to future change
                            }
                        } catch(Exception e) {
                            // if test: fail silently
                            if (!Test.isRunningTest()) throw new AuraHandledException('Error on setting up access code for envelope: ' + e.getMessage());
                        }
                    }
                }
                when '_consultant' {
                    if (!Test.isRunningTest() && string.isEmpty(currentSA.Owner.Email)) throw new AuraHandledException('Error on building recipient object -- Consultant do not have email.');
                    this.email = currentSA.Owner.Email;
                    this.name = this.recipientType != 'Signer'? currentSA.Owner.Name + ' (' + this.recipientType + ')' : currentSA.Owner.Name;
                }
                when '_UCA_Seller' {
                    if (!Test.isRunningTest() && string.isEmpty(currentSA.Seller_Full_Name__c)) throw new AuraHandledException('Error on building recipient object -- Used Car Seller dont have name');
                    if (!Test.isRunningTest() && string.isEmpty(currentSA.Seller_Email_Address__c)) throw new AuraHandledException('Error on building recipient object -- Used Car Seller dont have email');
                    this.email = currentSA.Seller_Email_Address__c;
                    this.name = this.recipientType != 'Signer'? currentSA.Seller_Full_Name__c + ' (' + this.recipientType.toLowerCase() + ')' : currentSA.Seller_Full_Name__c;
                    // TODO: add access code
                }
                when else {} // do nothing, reverse for future use
            }
        }

        // add private note
        string GMSValue = currentSA.GMS_Package__c == null? '0' : string.valueOf(currentSA.GMS_Package__c);
        string commissionValue = currentSA.Proposed_Commission__c == null? '0' : string.valueOf(currentSA.Proposed_Commission__c);
        string commissionReason = currentSA.Proposed_Commission_Reason__c == null? '' : currentSA.Proposed_Commission_Reason__c;
        // Use to set expiration date in email content
        Date currentDate = System.today(); // ADDED BY THIEU DANG VU - Mon 16th Nov 2020
        // note for customer's signing email (P type)
        string signer_AccessCodeInstruction_P =  'Hi ' + recipientFullName + ',' + '\n\n' +
                                                'We require your signature on this sales agreement. Enter the following password for access:' + '\n\n' +
                                                '[Last 4 characters of your NRIC] example: 123A' + '\n\n' + 
                                                'You have 3 attemps to enter the correct password. Should the agreement get locked, please contact your sales consultant. Thank you.' + '\n\n' +
                                                'This envelope will expire on ' + currentDate.addDays(5).format();
        // note for customer's signing email (C type)
        string signer_AccessCodeInstruction_C =  'Hi ' + recipientFullName + ',' + '\n\n' +
                                                'We require your signature on this sales agreement. Enter the following password for access:' + '\n\n' +
                                                '[Last 4 characters of your ARCA] example: 123A' + '\n\n' + 
                                                'You have 3 attemps to enter the correct password. Should the agreement get locked, please contact your sales consultant. Thank you.' + '\n\n' +
                                                'This envelope will expire on ' + currentDate.addDays(5).format();
        // note for customer's copy email (P type)
        string copy_AccessCodeInstruction_P = 'Hi ' + recipientFullName +',' + '\n\n' +
                                            'This is the carbon copy of Agreement No ' + currentSA.SOH_SONO__c + '.' + ' Enter the following password for access:' + '\n\n' +
                                            '[Last 4 characters of your NRIC] example: 123A' + '\n\n' + 
                                            'You have 3 attemps to enter the correct password. Should the agreement get locked, please contact your sales consultant. Thank you.' + '\n\n' +
                                            'This envelope will expire on ' + currentDate.addDays(5).format();
        
        // note for customer's copy email (C type)
        string copy_AccessCodeInstruction_C = 'Hi ' + recipientFullName +',' + '\n\n' +
                                            'This is the carbon copy of Agreement No ' + currentSA.SOH_SONO__c + '.' + ' Enter the following password for access:' + '\n\n' +
                                            '[Last 4 characters of your ARCA] example: 123A' + '\n\n' + 
                                            'You have 3 attemps to enter the correct password. Should the agreement get locked, please contact your sales consultant. Thank you.' + '\n\n' + 
                                            'This envelope will expire on ' + currentDate.addDays(5).format();
        switch on this.note {
            when '_customer' {
                switch on this.recipientType {
                    when 'Signer' {
                        if (string.isBlank(this.clientUserId)) { // sign via email
                            switch on currentSA.Registration_Type__c {
                                when 'P' {this.note = signer_AccessCodeInstruction_P;}
                                when 'C' {this.note = signer_AccessCodeInstruction_C;}
                                when else {this.note = 'Please sign this as ' + recipientFullName;} // subject to future change
                            }
                        }
                        if (!string.isBlank(this.clientUserId)) this.note = 'Please sign this as ' + recipientFullName; // sign in-place
                    }
                    when 'Carbon copy' {
                        switch on currentSA.Registration_Type__c {
                            when 'P' {this.note = copy_AccessCodeInstruction_P;}
                            when 'C' {this.note = copy_AccessCodeInstruction_C;}
                            when else {this.note = 'This is the carbon copy of Agreement No ' + currentSA.SOH_SONO__c;} // subject to future change
                        }
                    }
                    when else {} // do nothing, reverse for future use
                }
            }
            when '_consultant' {this.note = 'This is the carbon copy of Agreement No ' + currentSA.SOH_SONO__c;}
            when 'Endorser' {
                if (isUCA) this.note = 'Third Party Trade-In Agreement in accordance with Sales Agreement No. ' + currentSA.SOH_SONO__c + ' is pending for your endorsement';
                if (!isUCA) this.note = 'Agreement No. ' + currentSA.SOH_SONO__c + ' is pending for your endorsement.\nGMS value: $' + GMSValue + '\nProposed Commisson: $' + commissionValue + '\nCommission Reason: ' + commissionReason;
            }
            when 'Approver' {
                if (isUCA) this.note = 'Third Party Trade-In Agreement in accordance with Sales Agreement No. ' + currentSA.SOH_SONO__c + ' is pending for your approval';
                if (!isUCA) this.note = 'Agreement No. ' + currentSA.SOH_SONO__c + ' is pending for your approval.\nGMS value: $' + GMSValue + '\nProposed Commisson: $' + commissionValue + '\nCommission Reason: ' + commissionReason;
            }
            when '_UCA_Seller' {this.note = 'Third Party Trade-In Agreement in accordance with Sales Agreement No. ' + currentSA.SOH_SONO__c + ' is pending for your signature. Please sign this as ' + currentSA.Seller_Full_Name__c + '.';}
            when else {this.note = 'Agreement No. ' + currentSA.SOH_SONO__c + ' is waiting for your action.\nGMS value: $' + GMSValue;}
        }
        
        return this;
    }

    /**
    * add sign here tab for signer recipient
    **/
    public DocusignSignerDetail addSignHereTab(DocuSign_Recipient_Configuration__mdt recipientConfigs) {
        /* add sign here tab for signer */
        string anchorString = recipientConfigs.Signing_Tab_Anchor_String__c;
        DocusignSignHereTabDetail signHereTabDetail = new DocusignSignHereTabDetail(anchorString, this.recipientId, this.recipientId, '20', null);
        // signHereTabDetail.anchorXOffset = '20'; // to the right
        this.tabs = new DocusignTabs(new List<DocusignSignHereTabDetail> {signHereTabDetail});
        return this;
    }

    /* -------- MODIFIED BY THIEU DANG VU - Fri 6th Nov 2020 -- START --------*/
    /***
     * Method to add Sign Here & Date signed tab for MB
     */
    public DocusignSignerDetail addSignHereTab_MB(DocuSign_Recipient_Configuration__mdt recipientConfigs) {
        // Add signing tab
        string anchorString = recipientConfigs.Signing_Tab_Anchor_String__c;
        DocusignSignHereTabDetail signHereTabDetail = new DocusignSignHereTabDetail(anchorString, this.recipientId, this.recipientId, '20', null);
        // Add signed date time tab
        string dateSignedAnchorString = recipientConfigs.Date_Signed_Tab_Anchor_String__c;
        DocusignDateSignedTabDetail dateSignedTabDetail = new DocusignDateSignedTabDetail(dateSignedAnchorString, this.recipientId, this.recipientId, null, null);
 
        this.tabs = new DocusignTabs(new List<DocusignSignHereTabDetail> {signHereTabDetail}, new List<DocusignDateSignedTabDetail> {dateSignedTabDetail});

        return this;
    }

    /**
     * Add another tab for signer recipient for MB
     * Scenario: Seller = Buyer, will sign 2 places
     */
    public DocusignSignerDetail addAnotherSignHereTab_MB(DocuSign_Recipient_Configuration__mdt recipientConfigs) {
        string anchorString = recipientConfigs.Signing_Tab_Anchor_String__c;
        DocusignSignHereTabDetail signHereTabDetail = new DocusignSignHereTabDetail(anchorString, this.recipientId, this.recipientId, '20', null);
        // Add Date Signed Tab for Signer
        string dateSignedAnchorString = recipientConfigs.Date_Signed_Tab_Anchor_String__c;
        DocusignDateSignedTabDetail dateSignedTabDetail = new DocusignDateSignedTabDetail(dateSignedAnchorString, this.recipientId, this.recipientId, null, null);
        this.tabs.signHereTabs.add(signHereTabDetail);
        this.tabs.dateSignedTabs.add(dateSignedTabDetail);

        return this;
    }
    /* -------- MODIFIED BY THIEU DANG VU - Fri 6th Nov 2020 -- END --------*/
}