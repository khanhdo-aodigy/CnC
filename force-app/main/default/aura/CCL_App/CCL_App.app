<aura:application access="GLOBAL" extends="ltng:outApp" implements="flexipage:availableForAllPageTypes,ltng:allowGuestAccess">
    <aura:dependency resource="ccl_loginForm"></aura:dependency>    
    <aura:dependency resource="ccl_registrationForm"></aura:dependency>
    <aura:dependency resource="ccl_forgotPasswordForm"></aura:dependency>
    <aura:dependency resource="ccl_changePasswordForm"></aura:dependency>
    <aura:dependency resource="markup://force:*" type="EVENT"/>
</aura:application>