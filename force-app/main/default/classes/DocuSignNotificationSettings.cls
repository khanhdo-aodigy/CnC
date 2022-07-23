public with sharing class DocuSignNotificationSettings {
    public string useAccountDefaults;
    public ReminderNotification reminders;
    public Expirations expirations;                    // ADDED BY THIEU DANG VU - 13/11/2020 - Add instance for setting Envelope expiration

    public DocuSignNotificationSettings() {}

    public DocuSignNotificationSettings(string reminderEnabled, string reminderDelay, string reminderFrequency) {
        this.useAccountDefaults = 'false';
        this.reminders = new ReminderNotification(reminderEnabled, reminderDelay, reminderFrequency);
    }

    public class ReminderNotification {
        public string reminderEnabled;
        public string reminderDelay;
        public string reminderFrequency;

        ReminderNotification(string reminderEnabled, string reminderDelay, string reminderFrequency) {
            this.reminderEnabled = reminderEnabled;
            this.reminderDelay = reminderDelay;
            this.reminderFrequency = reminderFrequency;
        }
    }

    /* -------- ADDED BY THIEU DANG VU - Fri 13th Nov 2020 -- START --------*/
    public DocuSignNotificationSettings addExpirationSettings(string expireEnabled, string expireAfter, string expireWarn) {
        this.expirations = new Expirations(expireEnabled, expireAfter, expireWarn);

        return this;
    }

    public DocuSignNotificationSettings addReminderSettings(string reminderEnabled, string reminderDelay, string reminderFrequency) {
        this.reminders = new ReminderNotification(reminderEnabled, reminderDelay, reminderFrequency);

        return this;
    }

    public class Expirations {
        public string expireEnabled;
        public string expireAfter;
        public string expireWarn;

        Expirations(string expireEnabled, string expireAfter, string expireWarn) {
            this.expireEnabled = expireEnabled;
            this.expireAfter = expireAfter;
            this.expireWarn = expireWarn;
        }
    }
    /* -------- ADDED BY THIEU DANG VU - Fri 13th Nov 2020 -- END --------*/
}