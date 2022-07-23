<aura:application access="global" implements="lightning:isUrlAddressable,lightning:hasPageReference,force:appHostable,flexipage:availableForAllPageTypes,flexipage:availableForRecordHome,force:hasRecordId">
    <aura:dependency resource="markup://force:navigateToURL" type="EVENT"/>

    <ltng:require styles="{!join(',',
    $Resource.sdpBootstrap + '/BootStrap/styles/style.min.css',
    $Resource.sdpBootstrap + '/BootStrap/styles/oi-style.css')}" />

    <aura:attribute name="recordID" type="String" />
    <aura:attribute name="formID" type="String" />
    <aura:attribute name="finishedLoading" type="Boolean" default="false"/>
    <aura:attribute name="showHeader" type="Boolean" default="true"/>
    <aura:handler name="init" value="{!this}" action="{!c.onInit}"/>

    <lightning:notificationsLibrary aura:id="notifLib" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

    <aura:if isTrue="{!v.finishedLoading}">
        <c:sdp_formDetails recordId="{!v.recordID}" formId="{!v.formID}"></c:sdp_formDetails>
    </aura:if>
</aura:application>