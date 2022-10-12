<aura:application controller="DigitalSalesAgreementApplication" access="global"
    implements="lightning:isUrlAddressable,lightning:hasPageReference,force:appHostable,flexipage:availableForAllPageTypes,flexipage:availableForRecordHome,force:hasRecordId">
    <aura:dependency resource="markup://force:navigateToURL" type="EVENT"/>

    <ltng:require styles="{!join(',',
    $Resource.sdpBootstrap + '/BootStrap/styles/style.min.css',
    $Resource.sdpBootstrap + '/BootStrap/styles/oi-style.css')}" />


    <aura:attribute name="recordID" type="String" />

    <aura:attribute name="salesAgreementObject" type="Sales_Agreement__c" />
    <aura:attribute name="stockResObject" type="Stock_Reservation__c" />
    <aura:attribute name="deltaChangesObj" type="Sales_Agreement__c" />
    <aura:attribute name="deltaChangesStockResObj" type="Stock_Reservation__c" />
    <aura:attribute name="currentStage" type="String" default="Customer"/>
    <aura:attribute name="enableDocuButton" type="Boolean" default="false"/>
    <aura:attribute name="hasErrors" type="Boolean" default="false"/>
    <aura:attribute name="errorMsg" type="String" />
    <aura:attribute name="finishedLoading" type="Boolean" default="false"/>

    <aura:attribute name="isLocked" type="Boolean" default="false"/>

    <aura:attribute name="isUsedCarAgrmnt" type="Boolean" default="false"/>
    <aura:attribute name="recipientEmailForUCA" type="String" default=""/>
    <aura:attribute name="recipientEmail" type="String" default=""/>
    
    <aura:handler name="init" value="{!this}" action="{!c.doInit}" />
    <aura:if isTrue="{!v.hasErrors}">
        <div data-name="ErrorHeaderOffsetSticky" class="header-snap scroller sticky" style="top: -20px; background:#fc6c6c">
            <div class="container">
                <div class="row justify-content-md-center">
                    <span>   Please contact your system admin. Package of Stock Reservation is not setup correctly. </span>
                   <span>   {!v.errorMsg} </span>
                </div>
              </div>
        </div>
    </aura:if>
    <aura:if isTrue="{!v.finishedLoading}">
        <aura:if isTrue="{!v.currentStage == 'RegistrationType'}">
            <c:dsp_registrationType recordId = "{!v.stockResObject.Id}"
                                    onotherchangepage0="{!c.handlePreInitSalesAgreementChanges}"
                                    onchangepage0="{!c.handleChangePage0}"
                                    onactivitychanged="{!c.processStepChange}"/>
            <aura:set attribute="else">
                <lightning:notificationsLibrary aura:id="notifLib" />
                <aura:if isTrue="{!v.currentStage != 'undefined'}">
                <c:dsa_processFlowHeader aura:id= "processHeader" processType="DigitalSalesAgreement"
                                         showOnlyReview = "{!v.isLocked}"
                                         recordId = "{!v.salesAgreementObject.Id}"
                                         currentStep= "{!v.currentStage}"
                                         onactivitychanged="{!c.processStepChange}"
                                         onclosewindow="{!c.closeWindow}"/>
                </aura:if> 
        
                <aura:if isTrue="{!v.currentStage == 'Customer'}">
                    <c:dsp_customerDetails recordId = "{!v.salesAgreementObject.Id}"
                                            onchange="{!c.handleChange}"
                                            onactivitychanged="{!c.processStepChange}"
                                            onclosewindow="{!c.closeWindow}"/>
        
                </aura:if>
        
                <aura:if isTrue="{!v.currentStage == 'VehiclePurchase'}">
                    <c:dsp_vehiclePurchase  recordId = "{!v.salesAgreementObject.Id}"
                                            onchange="{!c.handleChange}"
                                            onactivitychanged="{!c.processStepChange}"/>
                </aura:if>
        
                <aura:if isTrue="{!v.currentStage == 'Finance'}">
                    <c:dsp_financeInsurance recordId = "{!v.salesAgreementObject.Id}"
                                            onchange="{!c.handleChange}"
                                            onactivitychanged="{!c.processStepChange}">
        
                    </c:dsp_financeInsurance>
                </aura:if>
        
                <aura:if isTrue="{!v.currentStage == 'Trade-In'}">
                    <c:dsp_tradeIn  recordId = "{!v.salesAgreementObject.Id}"
                                    onchange="{!c.handleChange}"
                                    onactivitychanged="{!c.processStepChange}">
                    </c:dsp_tradeIn>      
                </aura:if>
        
                <aura:if isTrue="{!v.currentStage == 'Deposit'}">
                    <c:dsp_deposit  recordId = "{!v.salesAgreementObject.Id}"
                                    onchange="{!c.handleChange}"
                                    onpublisherror="{!c.handleErrors}"
                                    onclearerror ="{!c.clearErrors}"
                                    onactivitychanged="{!c.processStepChange}">
                    </c:dsp_deposit>
                </aura:if>
        
                <aura:if isTrue="{!v.currentStage == 'Review'}">
        
                    <c:dsp_review  recordId = "{!v.salesAgreementObject.Id}"
                                    onactivitychanged="{!c.processStepChange}"
                                    isLocked = "{!v.isLocked}">
                    </c:dsp_review>
        
        
                    <aura:if isTrue="{!v.enableDocuButton }">
                        <c:dsp_reviewContainer aura:id= "docuSection" recordId = "{!v.salesAgreementObject.Id}" recipientEmail="{!v.recipientEmail}"
                                               salesAgreementRecord="{!v.salesAgreementObject}"
                                               isUsedCarAgmnt="{!v.isUsedCarAgrmnt}"
                                               recipientEmailForUCA="{!v.recipientEmailForUCA}">
                        </c:dsp_reviewContainer >
                        <!--
                        <aura:if isTrue="{!v.isLocked}">
                            <div class="container">
                                    <button aura:id="docuButton" disabled="true" type="button" class="btn btn-primary btn-submit">Generate PDF</button>
                                </div>
                            <aura:set attribute="else">
                                <c:dsp_reviewContainer aura:id= "docuSection" recordId = "{!v.salesAgreementObject.Id}" >
                                </c:dsp_reviewContainer >
                            </aura:set>
                        </aura:if>
                        -->
                        <aura:set attribute="else">
                            <div class="container">
                                <button aura:id="docuButton" disabled="true" type="button" class="btn btn-primary btn-submit">Generate PDF</button>
                            </div>
                        </aura:set>
                    </aura:if>
                </aura:if>
            </aura:set>
        </aura:if>
<!-- 
        <lightning:notificationsLibrary aura:id="notifLib" />
        <aura:if isTrue="{!v.currentStage != 'undefined'}">
        <c:dsa_processFlowHeader aura:id= "processHeader" processType="DigitalSalesAgreement"
                                 showOnlyReview = "{!v.isLocked}"
                                 recordId = "{!v.salesAgreementObject.Id}"
                                 currentStep= "{!v.currentStage}"
                                 onactivitychanged="{!c.processStepChange}"
                                 onclosewindow="{!c.closeWindow}"/>
        </aura:if> 

        <aura:if isTrue="{!v.currentStage == 'Customer'}">
            <c:dsp_customerDetails recordId = "{!v.salesAgreementObject.Id}"
                                    onchange="{!c.handleChange}"
                                    onactivitychanged="{!c.processStepChange}"/>

        </aura:if>

        <aura:if isTrue="{!v.currentStage == 'VehiclePurchase'}">
            <c:dsp_vehiclePurchase  recordId = "{!v.salesAgreementObject.Id}"
                                    onchange="{!c.handleChange}"
                                    onactivitychanged="{!c.processStepChange}"/>
        </aura:if>

        <aura:if isTrue="{!v.currentStage == 'Finance'}">
            <c:dsp_financeInsurance recordId = "{!v.salesAgreementObject.Id}"
                                    onchange="{!c.handleChange}"
                                    onactivitychanged="{!c.processStepChange}">

            </c:dsp_financeInsurance>
        </aura:if>

        <aura:if isTrue="{!v.currentStage == 'Trade-In'}">
            <c:dsp_tradeIn  recordId = "{!v.salesAgreementObject.Id}"
                            onchange="{!c.handleChange}"
                            onactivitychanged="{!c.processStepChange}"></c:dsp_tradeIn>

        </aura:if>

        <aura:if isTrue="{!v.currentStage == 'Deposit'}">
            <c:dsp_deposit  recordId = "{!v.salesAgreementObject.Id}"
                            onchange="{!c.handleChange}"
                            onpublisherror="{!c.handleErrors}"
                            onclearerror ="{!c.clearErrors}"
                            onactivitychanged="{!c.processStepChange}">
            </c:dsp_deposit>
        </aura:if>

        <aura:if isTrue="{!v.currentStage == 'Review'}">

            <c:dsp_review  recordId = "{!v.salesAgreementObject.Id}"
                            onactivitychanged="{!c.processStepChange}"
                            isLocked = "{!v.isLocked}">
            </c:dsp_review>


            <aura:if isTrue="{!v.enableDocuButton }">
                <c:dsp_reviewContainer aura:id= "docuSection" recordId = "{!v.salesAgreementObject.Id}" recipientEmail="{!v.salesAgreementObject.emailaddress__c}" salesAgreementRecord="{!v.salesAgreementObject}">
                </c:dsp_reviewContainer > -->
                <!--
                <aura:if isTrue="{!v.isLocked}">
                    <div class="container">
                            <button aura:id="docuButton" disabled="true" type="button" class="btn btn-primary btn-submit">Generate PDF</button>
                        </div>
                    <aura:set attribute="else">
                        <c:dsp_reviewContainer aura:id= "docuSection" recordId = "{!v.salesAgreementObject.Id}" >
                        </c:dsp_reviewContainer >
                    </aura:set>
                </aura:if>
                -->
                <!-- <aura:set attribute="else">
                    <div class="container">
                        <button aura:id="docuButton" disabled="true" type="button" class="btn btn-primary btn-submit">Generate PDF</button>
                    </div>
                </aura:set>
            </aura:if>
        </aura:if> -->
    </aura:if>
</aura:application>