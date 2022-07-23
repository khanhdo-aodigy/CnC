<aura:application controller="SDP_DefectFormController" access="global"
    implements="lightning:isUrlAddressable,lightning:hasPageReference,force:appHostable,flexipage:availableForAllPageTypes,flexipage:availableForRecordHome,force:hasRecordId">

    <ltng:require styles="{!join(',',
    $Resource.sdpBootstrap + '/BootStrap/styles/style.min.css',
    $Resource.sdpBootstrap + '/BootStrap/styles/oi-style.css')}" afterScriptsLoaded="{!c.scriptsLoaded}" />

    <aura:dependency resource="markup://force:navigateToURL" type="EVENT" />
    <aura:attribute name="recordID" type="String" />
    <aura:attribute name="deviceType" type="String" />
    <aura:attribute name="finishedLoading" type="Boolean" default="false" />
    <aura:attribute name="salesAgreementObject" type="Sales_Agreement__c" />
    <aura:attribute name="currentStage" type="String" default="AddDefectAndAccessories" />

    <aura:handler name="init" value="{!this}" action="{!c.doInit}" />

    <div id="top-error"></div>
    <aura:if isTrue="{!v.finishedLoading}">
        <lightning:notificationsLibrary aura:id="notifLib" />
        <aura:if isTrue="{!v.currentStage == 'AddDefectAndAccessories'}">
            <c:sdp_defectformDetails deviceType="{!v.deviceType}" salesAgreementObj="{!v.salesAgreementObject}"
                recordId="{!v.salesAgreementObject.Id}" onactivitychanged="{!c.processStepChange}" />
        </aura:if>

        <aura:if isTrue="{!v.currentStage == 'SelectServiceCenter'}">
            <c:sdp_defectformSelectServiceCenter editMode="true" recordId="{!v.salesAgreementObject.Id}" franchise="{!v.salesAgreementObject.FranchiseCode__c}"
                onactivitychanged="{!c.processStepChange}" />
        </aura:if>

        <aura:if isTrue="{!v.currentStage == 'ReviewForm'}">
            <c:sdp_defectformReview recordId="{!v.salesAgreementObject.Id}" franchise="{!v.salesAgreementObject.FranchiseCode__c}"
                onactivitychanged="{!c.processStepChange}" />
        </aura:if>

        <aura:if isTrue="{!v.currentStage == 'Submitted'}">
            <c:sdp_defectformSubmitted />
        </aura:if>
    </aura:if>

</aura:application>