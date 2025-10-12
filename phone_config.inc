// ===========================================
// Phone Configuration File
// ===========================================

// Database Configuration
#define DB_HOST "localhost"
#define DB_USER "root"
#define DB_PASS ""
#define DB_NAME "samp_phone"

// Phone System Configuration
#define MAX_PHONE_CONTACTS 100
#define MAX_PHONE_MESSAGES 50
#define MAX_CALL_HISTORY 30
#define PHONE_PRICE 5000
#define CALL_COST_PER_MINUTE 10
#define MESSAGE_COST 1
#define PHONE_STARTING_CREDIT 100

// Phone States
#define PHONE_STATE_IDLE 0
#define PHONE_STATE_CALLING 1
#define PHONE_STATE_RINGING 2
#define PHONE_STATE_IN_CALL 3
#define PHONE_STATE_BUSY 4

// Call Settings
#define CALL_TIMEOUT_SECONDS 30
#define MAX_CALL_DURATION 3600 // 1 hour in seconds
#define RING_INTERVAL 2000 // 2 seconds between rings

// Message Settings
#define MAX_MESSAGE_LENGTH 128
#define MESSAGE_EXPIRY_DAYS 30

// Phone Number Settings
#define PHONE_NUMBER_MIN 1000000
#define PHONE_NUMBER_MAX 9999999

// Colors
#define COLOR_PHONE_SUCCESS 0x00FF00FF
#define COLOR_PHONE_ERROR 0xFF0000FF
#define COLOR_PHONE_INFO 0xFFFF00FF
#define COLOR_PHONE_NOTIFICATION 0x00FFFFFF

// Sound Effects
#define SOUND_PHONE_RING 1085
#define SOUND_PHONE_MESSAGE 1084
#define SOUND_PHONE_CALL 1086
#define SOUND_PHONE_HANGUP 1087

// Animation Settings
#define ANIMATION_PHONE_CALL "PHONE_CALL"
#define ANIMATION_PHONE_TALK "PHONE_TALK"
#define ANIMATION_PHONE_MESSAGE "PHONE_CALL"

// Object Settings
#define PHONE_OBJECT_MODEL 18865
#define PHONE_ATTACH_BONE 6
#define PHONE_ATTACH_X 0.0
#define PHONE_ATTACH_Y 0.0
#define PHONE_ATTACH_Z 0.0
#define PHONE_ATTACH_RX 0.0
#define PHONE_ATTACH_RY 0.0
#define PHONE_ATTACH_RZ 0.0
#define PHONE_ATTACH_SCALE 1.0

// Feature Toggles
#define ENABLE_PHONE_ANIMATIONS 1
#define ENABLE_PHONE_SOUNDS 1
#define ENABLE_PHONE_NOTIFICATIONS 1
#define ENABLE_CALL_HISTORY 1
#define ENABLE_MESSAGE_HISTORY 1
#define ENABLE_CONTACT_SYSTEM 1
#define ENABLE_CREDIT_SYSTEM 1

// Admin Commands
#define ADMIN_LEVEL_PHONE_MANAGE 1
#define ADMIN_LEVEL_PHONE_RESET 2