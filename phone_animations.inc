// ===========================================
// Phone Animations Include File
// ===========================================

// Phone animation IDs
#define PHONE_ANIMATION_CALLING 339
#define PHONE_ANIMATION_TALKING 339
#define PHONE_ANIMATION_MESSAGING 339

// Phone object IDs (you can customize these)
#define PHONE_OBJECT_ID 18865

// Animation functions
StartPhoneAnimation(playerid, type)
{
    switch(type)
    {
        case 0: // Calling
        {
            ApplyAnimation(playerid, "PED", "PHONE_CALL", 4.1, 1, 1, 1, 1, 0);
            SetPlayerAttachedObject(playerid, 0, PHONE_OBJECT_ID, 6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
        }
        case 1: // Talking
        {
            ApplyAnimation(playerid, "PED", "PHONE_TALK", 4.1, 1, 1, 1, 1, 0);
            SetPlayerAttachedObject(playerid, 0, PHONE_OBJECT_ID, 6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
        }
        case 2: // Messaging
        {
            ApplyAnimation(playerid, "PED", "PHONE_CALL", 4.1, 1, 1, 1, 1, 0);
            SetPlayerAttachedObject(playerid, 0, PHONE_OBJECT_ID, 6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
        }
    }
}

StopPhoneAnimation(playerid)
{
    ClearAnimations(playerid);
    RemovePlayerAttachedObject(playerid, 0);
}

// Sound effects
PlayPhoneRingSound(playerid)
{
    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
}

PlayPhoneMessageSound(playerid)
{
    PlayerPlaySound(playerid, 1084, 0.0, 0.0, 0.0);
}

PlayPhoneCallSound(playerid)
{
    PlayerPlaySound(playerid, 1086, 0.0, 0.0, 0.0);
}

// Visual effects
ShowPhoneNotification(playerid, message[])
{
    new string[256];
    format(string, sizeof(string), "~w~Phone: ~y~%s", message);
    GameTextForPlayer(playerid, string, 3000, 4);
}

ShowPhoneCallStatus(playerid, status[])
{
    new string[128];
    format(string, sizeof(string), "~w~Call: ~g~%s", status);
    GameTextForPlayer(playerid, string, 2000, 4);
}