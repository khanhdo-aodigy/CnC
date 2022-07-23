@isTest
private class DocuSignNotificationSettingsTest {
    @isTest
    private static void testConstructor() {
        DocuSignNotificationSettings notify = new DocuSignNotificationSettings('true', '2', '1');
        system.assertEquals('false', notify.useAccountDefaults);
        system.assertEquals('true', notify.reminders.reminderEnabled);
        system.assertEquals('2', notify.reminders.reminderDelay);
        system.assertEquals('1', notify.reminders.reminderFrequency);
    }

    @isTest
    private static void test_addReminderSettings() {
        DocuSignNotificationSettings notis = new DocuSignNotificationSettings();
        notis.useAccountDefaults = 'false';
        notis.addReminderSettings('true', '2', '3');
        system.assertEquals('false', notis.useAccountDefaults);
        system.assertEquals('true', notis.reminders.reminderEnabled);
        system.assertEquals('2', notis.reminders.reminderDelay);
        system.assertEquals('3', notis.reminders.reminderFrequency);
    }

    @isTest
    private static void test_addExpirationSettings() {
        DocuSignNotificationSettings notis = new DocuSignNotificationSettings();
        notis.useAccountDefaults = 'false';
        notis.addExpirationSettings('true', '1', '0');
        system.assertEquals('false', notis.useAccountDefaults);
        system.assertEquals('true', notis.expirations.expireEnabled);
        system.assertEquals('1', notis.expirations.expireAfter);
        system.assertEquals('0', notis.expirations.expireWarn);
    }
}