<aura:application access="global" implements="lightning:isUrlAddressable,lightning:hasPageReference,force:appHostable,flexipage:availableForAllPageTypes,flexipage:availableForRecordHome,force:hasRecordId" controller="SDP_VehicleDeliveryCertificateController">
    <aura:dependency resource="markup://force:navigateToURL" type="EVENT"/>

    <ltng:require styles="{!join(',',
    $Resource.sdpBootstrap + '/BootStrap/styles/style.min.css',
    $Resource.sdpBootstrap + '/BootStrap/styles/oi-style.css')}" />


    <aura:attribute name="recordID" type="String" />
    <aura:attribute name="finishedLoading" type="Boolean" default="false"/>
    <aura:attribute name="showHeader" type="Boolean" default="true"/>
    <aura:handler name="init" value="{!this}" action="{!c.onInit}"/>

    <lightning:notificationsLibrary aura:id="notifLib" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

    <!--<aura:if isTrue="{!v.showHeader}">
        <header>
            <div class="d-flex align-items-center justify-content-between">
                <a></a>
                <h1>Delivery Certificate</h1>
                <a href="javascript:void(0)" onclick="{!c.formCancel}" style="color: white;">Cancel</a>
            </div>
        </header>
    </aura:if>-->

    <aura:if isTrue="{!v.finishedLoading}">
        <c:sdp_VehicleDeliveryCertificate_Details recordId="{!v.recordID}"></c:sdp_VehicleDeliveryCertificate_Details>
    </aura:if>

</aura:application>