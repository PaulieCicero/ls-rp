// ===========================================
// SA-MP Phone Script v1.0
// Complete phone system with calling, messaging, contacts
// ===========================================

#include <a_samp>
#include <a_mysql>
#include <zcmd>
#include <sscanf2>
#include <foreach>

// ===========================================
// Configuration
// ===========================================

#define MAX_PHONE_CONTACTS 100
#define MAX_PHONE_MESSAGES 50
#define MAX_CALL_HISTORY 30
#define PHONE_PRICE 5000
#define CALL_COST_PER_MINUTE 10

// Phone states
#define PHONE_STATE_IDLE 0
#define PHONE_STATE_CALLING 1
#define PHONE_STATE_RINGING 2
#define PHONE_STATE_IN_CALL 3
#define PHONE_STATE_BUSY 4

// ===========================================
// Variables
// ===========================================

new MySQL:g_SQL;
new PlayerPhoneState[MAX_PLAYERS];
new PlayerPhoneNumber[MAX_PLAYERS];
new PlayerPhoneCredit[MAX_PLAYERS];
new PlayerInCallWith[MAX_PLAYERS];
new PlayerCallStartTime[MAX_PLAYERS];
new PlayerPhoneOn[MAX_PLAYERS];

// Contact system
new ContactNames[MAX_PLAYERS][MAX_PHONE_CONTACTS][32];
new ContactNumbers[MAX_PLAYERS][MAX_PHONE_CONTACTS][15];
new ContactCount[MAX_PLAYERS];

// Message system
new MessageFrom[MAX_PLAYERS][MAX_PHONE_MESSAGES][32];
new MessageText[MAX_PLAYERS][MAX_PHONE_MESSAGES][128];
new MessageTime[MAX_PLAYERS][MAX_PHONE_MESSAGES];
new MessageCount[MAX_PLAYERS];

// Call history
new CallHistoryFrom[MAX_PLAYERS][MAX_CALL_HISTORY][32];
new CallHistoryTo[MAX_PLAYERS][MAX_CALL_HISTORY][32];
new CallHistoryDuration[MAX_PLAYERS][MAX_CALL_HISTORY];
new CallHistoryType[MAX_PLAYERS][MAX_CALL_HISTORY]; // 0 = missed, 1 = received, 2 = dialed
new CallHistoryCount[MAX_PLAYERS];

// ===========================================
// Forward declarations
// ===========================================

forward OnPhoneConnect();
forward OnPhoneDisconnect();
forward OnPlayerPhoneUpdate(playerid);
forward OnPhoneCallEnd(playerid, reason);

// ===========================================
// Main callbacks
// ===========================================

public OnGameModeInit()
{
    // Initialize MySQL connection
    g_SQL = mysql_connect("localhost", "root", "", "samp_phone");
    
    if(mysql_errno(g_SQL) != 0)
    {
        print("ERROR: Could not connect to MySQL database!");
        return 0;
    }
    
    print("Phone Script: MySQL connection established.");
    
    // Create tables
    mysql_query(g_SQL, "CREATE TABLE IF NOT EXISTS player_phones (id INT AUTO_INCREMENT PRIMARY KEY, playerid INT, phonenumber VARCHAR(15), credit INT, hasphone TINYINT(1))");
    mysql_query(g_SQL, "CREATE TABLE IF NOT EXISTS phone_contacts (id INT AUTO_INCREMENT PRIMARY KEY, playerid INT, contactname VARCHAR(32), contactnumber VARCHAR(15))");
    mysql_query(g_SQL, "CREATE TABLE IF NOT EXISTS phone_messages (id INT AUTO_INCREMENT PRIMARY KEY, playerid INT, fromname VARCHAR(32), message TEXT, timestamp INT)");
    mysql_query(g_SQL, "CREATE TABLE IF NOT EXISTS phone_calls (id INT AUTO_INCREMENT PRIMARY KEY, playerid INT, fromname VARCHAR(32), toname VARCHAR(32), duration INT, type INT, timestamp INT)");
    
    // Start phone update timer
    SetTimer("OnPhoneUpdate", 1000, true);
    
    return 1;
}

public OnGameModeExit()
{
    mysql_close(g_SQL);
    return 1;
}

public OnPlayerConnect(playerid)
{
    // Initialize player phone data
    PlayerPhoneState[playerid] = PHONE_STATE_IDLE;
    PlayerPhoneNumber[playerid] = 0;
    PlayerPhoneCredit[playerid] = 0;
    PlayerInCallWith[playerid] = INVALID_PLAYER_ID;
    PlayerCallStartTime[playerid] = 0;
    PlayerPhoneOn[playerid] = 0;
    ContactCount[playerid] = 0;
    MessageCount[playerid] = 0;
    CallHistoryCount[playerid] = 0;
    
    // Load player phone data from database
    LoadPlayerPhoneData(playerid);
    
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    // Save player phone data
    SavePlayerPhoneData(playerid);
    
    // End any active calls
    if(PlayerPhoneState[playerid] == PHONE_STATE_IN_CALL || PlayerPhoneState[playerid] == PHONE_STATE_CALLING)
    {
        EndPhoneCall(playerid, 1); // Reason: Player disconnected
    }
    
    return 1;
}

// ===========================================
// Phone Commands
// ===========================================

CMD:phone(playerid, params[])
{
    if(!PlayerPhoneOn[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You don't have a phone!");
        return 1;
    }
    
    ShowPhoneMainMenu(playerid);
    return 1;
}

CMD:buyphone(playerid, params[])
{
    if(PlayerPhoneOn[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You already have a phone!");
        return 1;
    }
    
    if(GetPlayerMoney(playerid) < PHONE_PRICE)
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You don't have enough money! Phone costs $5,000.");
        return 1;
    }
    
    GivePlayerMoney(playerid, -PHONE_PRICE);
    PlayerPhoneOn[playerid] = 1;
    PlayerPhoneNumber[playerid] = 1000000 + random(9000000); // Generate random phone number
    PlayerPhoneCredit[playerid] = 100; // Give some starting credit
    
    new string[128];
    format(string, sizeof(string), "You bought a phone! Your number is: %d", PlayerPhoneNumber[playerid]);
    SendClientMessage(playerid, 0x00FF00FF, string);
    
    SavePlayerPhoneData(playerid);
    return 1;
}

CMD:call(playerid, params[])
{
    if(!PlayerPhoneOn[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You don't have a phone!");
        return 1;
    }
    
    if(PlayerPhoneState[playerid] != PHONE_STATE_IDLE)
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You're already on a call!");
        return 1;
    }
    
    new number;
    if(sscanf(params, "d", number))
    {
        SendClientMessage(playerid, 0xFFFF00FF, "USAGE: /call [phone number]");
        return 1;
    }
    
    if(number == PlayerPhoneNumber[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You can't call yourself!");
        return 1;
    }
    
    // Find player with this phone number
    new targetid = INVALID_PLAYER_ID;
    foreach(new i : Player)
    {
        if(PlayerPhoneNumber[i] == number && PlayerPhoneOn[i])
        {
            targetid = i;
            break;
        }
    }
    
    if(targetid == INVALID_PLAYER_ID)
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: Phone number not found or player is offline!");
        return 1;
    }
    
    if(PlayerPhoneState[targetid] != PHONE_STATE_IDLE)
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: The person you're calling is busy!");
        return 1;
    }
    
    // Start the call
    StartPhoneCall(playerid, targetid);
    return 1;
}

CMD:answer(playerid, params[])
{
    if(!PlayerPhoneOn[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You don't have a phone!");
        return 1;
    }
    
    if(PlayerPhoneState[playerid] != PHONE_STATE_RINGING)
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: Your phone is not ringing!");
        return 1;
    }
    
    AnswerPhoneCall(playerid);
    return 1;
}

CMD:hangup(playerid, params[])
{
    if(!PlayerPhoneOn[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You don't have a phone!");
        return 1;
    }
    
    if(PlayerPhoneState[playerid] == PHONE_STATE_IDLE)
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You're not on a call!");
        return 1;
    }
    
    EndPhoneCall(playerid, 0); // Reason: Player hung up
    return 1;
}

CMD:contacts(playerid, params[])
{
    if(!PlayerPhoneOn[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You don't have a phone!");
        return 1;
    }
    
    ShowContactsMenu(playerid);
    return 1;
}

CMD:addcontact(playerid, params[])
{
    if(!PlayerPhoneOn[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You don't have a phone!");
        return 1;
    }
    
    new name[32], number[15];
    if(sscanf(params, "s[32]s[15]", name, number))
    {
        SendClientMessage(playerid, 0xFFFF00FF, "USAGE: /addcontact [name] [phone number]");
        return 1;
    }
    
    if(ContactCount[playerid] >= MAX_PHONE_CONTACTS)
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: Your contact list is full!");
        return 1;
    }
    
    // Add contact
    strcat(ContactNames[playerid][ContactCount[playerid]], name, 32);
    strcat(ContactNumbers[playerid][ContactCount[playerid]], number, 15);
    ContactCount[playerid]++;
    
    new string[128];
    format(string, sizeof(string), "Contact '%s' (%s) added to your phone!", name, number);
    SendClientMessage(playerid, 0x00FF00FF, string);
    
    SavePlayerContacts(playerid);
    return 1;
}

CMD:messages(playerid, params[])
{
    if(!PlayerPhoneOn[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You don't have a phone!");
        return 1;
    }
    
    ShowMessagesMenu(playerid);
    return 1;
}

CMD:sendmessage(playerid, params[])
{
    if(!PlayerPhoneOn[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You don't have a phone!");
        return 1;
    }
    
    new number[15], message[128];
    if(sscanf(params, "s[15]s[128]", number, message))
    {
        SendClientMessage(playerid, 0xFFFF00FF, "USAGE: /sendmessage [phone number] [message]");
        return 1;
    }
    
    // Find player with this phone number
    new targetid = INVALID_PLAYER_ID;
    foreach(new i : Player)
    {
        if(PlayerPhoneNumber[i] == strval(number) && PlayerPhoneOn[i])
        {
            targetid = i;
            break;
        }
    }
    
    if(targetid == INVALID_PLAYER_ID)
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: Phone number not found or player is offline!");
        return 1;
    }
    
    SendPhoneMessage(playerid, targetid, message);
    return 1;
}

CMD:callhistory(playerid, params[])
{
    if(!PlayerPhoneOn[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You don't have a phone!");
        return 1;
    }
    
    ShowCallHistoryMenu(playerid);
    return 1;
}

CMD:phonecredit(playerid, params[])
{
    if(!PlayerPhoneOn[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You don't have a phone!");
        return 1;
    }
    
    new string[128];
    format(string, sizeof(string), "Your phone credit: $%d", PlayerPhoneCredit[playerid]);
    SendClientMessage(playerid, 0x00FF00FF, string);
    return 1;
}

CMD:addcredit(playerid, params[])
{
    if(!PlayerPhoneOn[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You don't have a phone!");
        return 1;
    }
    
    new amount;
    if(sscanf(params, "d", amount))
    {
        SendClientMessage(playerid, 0xFFFF00FF, "USAGE: /addcredit [amount]");
        return 1;
    }
    
    if(amount <= 0)
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: Amount must be positive!");
        return 1;
    }
    
    if(GetPlayerMoney(playerid) < amount)
    {
        SendClientMessage(playerid, 0xFF0000FF, "ERROR: You don't have enough money!");
        return 1;
    }
    
    GivePlayerMoney(playerid, -amount);
    PlayerPhoneCredit[playerid] += amount;
    
    new string[128];
    format(string, sizeof(string), "Added $%d to your phone credit! Total: $%d", amount, PlayerPhoneCredit[playerid]);
    SendClientMessage(playerid, 0x00FF00FF, string);
    
    SavePlayerPhoneData(playerid);
    return 1;
}

// ===========================================
// Phone Functions
// ===========================================

StartPhoneCall(playerid, targetid)
{
    PlayerPhoneState[playerid] = PHONE_STATE_CALLING;
    PlayerPhoneState[targetid] = PHONE_STATE_RINGING;
    PlayerInCallWith[playerid] = targetid;
    PlayerInCallWith[targetid] = playerid;
    PlayerCallStartTime[playerid] = gettime();
    PlayerCallStartTime[targetid] = gettime();
    
    // Send messages
    new string[128];
    format(string, sizeof(string), "Calling %s (%d)...", GetPlayerNameEx(targetid), PlayerPhoneNumber[targetid]);
    SendClientMessage(playerid, 0x00FF00FF, string);
    
    format(string, sizeof(string), "Incoming call from %s (%d) - Use /answer to answer", GetPlayerNameEx(playerid), PlayerPhoneNumber[playerid]);
    SendClientMessage(targetid, 0x00FF00FF, string);
    
    // Play ring sound (you can add sound effects here)
    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
    PlayerPlaySound(targetid, 1085, 0.0, 0.0, 0.0);
    
    // Set timer to auto-hangup if not answered
    SetTimerEx("OnPhoneCallTimeout", 30000, false, "ii", playerid, targetid);
}

AnswerPhoneCall(playerid)
{
    new callerid = PlayerInCallWith[playerid];
    
    PlayerPhoneState[playerid] = PHONE_STATE_IN_CALL;
    PlayerPhoneState[callerid] = PHONE_STATE_IN_CALL;
    
    new string[128];
    format(string, sizeof(string), "Call connected with %s", GetPlayerNameEx(callerid));
    SendClientMessage(playerid, 0x00FF00FF, string);
    SendClientMessage(callerid, 0x00FF00FF, string);
    
    // Start call timer
    SetTimerEx("OnPhoneCallUpdate", 1000, true, "i", playerid);
}

EndPhoneCall(playerid, reason)
{
    new targetid = PlayerInCallWith[playerid];
    
    if(targetid != INVALID_PLAYER_ID)
    {
        // Calculate call duration and cost
        new duration = gettime() - PlayerCallStartTime[playerid];
        new cost = (duration / 60) * CALL_COST_PER_MINUTE;
        
        if(cost > 0)
        {
            if(PlayerPhoneCredit[playerid] >= cost)
            {
                PlayerPhoneCredit[playerid] -= cost;
                new string[128];
                format(string, sizeof(string), "Call cost: $%d (Duration: %d seconds)", cost, duration);
                SendClientMessage(playerid, 0xFFFF00FF, string);
            }
            else
            {
                SendClientMessage(playerid, 0xFF0000FF, "ERROR: Not enough credit to pay for the call!");
            }
        }
        
        // Add to call history
        AddCallHistory(playerid, targetid, duration, 2); // 2 = dialed
        AddCallHistory(targetid, playerid, duration, 1); // 1 = received
        
        // Reset states
        PlayerPhoneState[playerid] = PHONE_STATE_IDLE;
        PlayerPhoneState[targetid] = PHONE_STATE_IDLE;
        PlayerInCallWith[playerid] = INVALID_PLAYER_ID;
        PlayerInCallWith[targetid] = INVALID_PLAYER_ID;
        
        // Send messages
        new string[128];
        switch(reason)
        {
            case 0: format(string, sizeof(string), "Call ended by %s", GetPlayerNameEx(playerid));
            case 1: format(string, sizeof(string), "Call ended - %s disconnected", GetPlayerNameEx(playerid));
            case 2: format(string, sizeof(string), "Call ended - %s ran out of credit", GetPlayerNameEx(playerid));
        }
        
        SendClientMessage(playerid, 0xFF0000FF, "Call ended.");
        SendClientMessage(targetid, 0xFF0000FF, string);
        
        // Kill call update timer
        KillTimer(GetPVarInt(playerid, "PhoneCallTimer"));
    }
}

SendPhoneMessage(playerid, targetid, message[])
{
    // Add message to target's inbox
    if(MessageCount[targetid] < MAX_PHONE_MESSAGES)
    {
        strcat(MessageFrom[targetid][MessageCount[targetid]], GetPlayerNameEx(playerid), 32);
        strcat(MessageText[targetid][MessageCount[targetid]], message, 128);
        MessageTime[targetid][MessageCount[targetid]] = gettime();
        MessageCount[targetid]++;
    }
    
    // Send notification
    new string[256];
    format(string, sizeof(string), "SMS from %s (%d): %s", GetPlayerNameEx(playerid), PlayerPhoneNumber[playerid], message);
    SendClientMessage(targetid, 0x00FF00FF, string);
    
    // Play message sound
    PlayerPlaySound(targetid, 1084, 0.0, 0.0, 0.0);
    
    SendClientMessage(playerid, 0x00FF00FF, "Message sent!");
}

AddCallHistory(playerid, targetid, duration, type)
{
    if(CallHistoryCount[playerid] < MAX_CALL_HISTORY)
    {
        strcat(CallHistoryFrom[playerid][CallHistoryCount[playerid]], GetPlayerNameEx(targetid), 32);
        strcat(CallHistoryTo[playerid][CallHistoryCount[playerid]], GetPlayerNameEx(playerid), 32);
        CallHistoryDuration[playerid][CallHistoryCount[playerid]] = duration;
        CallHistoryType[playerid][CallHistoryCount[playerid]] = type;
        CallHistoryCount[playerid]++;
    }
}

// ===========================================
// Dialog Functions
// ===========================================

ShowPhoneMainMenu(playerid)
{
    new string[512];
    strcat(string, "Phone Menu\n", sizeof(string));
    strcat(string, "1. Make Call\n", sizeof(string));
    strcat(string, "2. Contacts\n", sizeof(string));
    strcat(string, "3. Messages\n", sizeof(string));
    strcat(string, "4. Call History\n", sizeof(string));
    strcat(string, "5. Phone Credit\n", sizeof(string));
    strcat(string, "6. Settings\n", sizeof(string));
    
    ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_LIST, "Phone Menu", string, "Select", "Close");
}

ShowContactsMenu(playerid)
{
    new string[1024];
    strcat(string, "Contacts\n", sizeof(string));
    
    for(new i = 0; i < ContactCount[playerid]; i++)
    {
        new contact[64];
        format(contact, sizeof(contact), "%s - %s\n", ContactNames[playerid][i], ContactNumbers[playerid][i]);
        strcat(string, contact, sizeof(string));
    }
    
    strcat(string, "Add Contact\n", sizeof(string));
    strcat(string, "Delete Contact\n", sizeof(string));
    
    ShowPlayerDialog(playerid, 1001, DIALOG_STYLE_LIST, "Contacts", string, "Select", "Back");
}

ShowMessagesMenu(playerid)
{
    new string[1024];
    strcat(string, "Messages\n", sizeof(string));
    
    for(new i = 0; i < MessageCount[playerid]; i++)
    {
        new message[128];
        format(message, sizeof(message), "From: %s\n%s\n\n", MessageFrom[playerid][i], MessageText[playerid][i]);
        strcat(string, message, sizeof(string));
    }
    
    strcat(string, "Send Message\n", sizeof(string));
    strcat(string, "Delete Messages\n", sizeof(string));
    
    ShowPlayerDialog(playerid, 1002, DIALOG_STYLE_LIST, "Messages", string, "Select", "Back");
}

ShowCallHistoryMenu(playerid)
{
    new string[1024];
    strcat(string, "Call History\n", sizeof(string));
    
    for(new i = 0; i < CallHistoryCount[playerid]; i++)
    {
        new history[128];
        new type[16];
        switch(CallHistoryType[playerid][i])
        {
            case 0: strcat(type, "Missed", 16);
            case 1: strcat(type, "Received", 16);
            case 2: strcat(type, "Dialed", 16);
        }
        
        format(history, sizeof(history), "%s - %s (%d sec) [%s]\n", 
               CallHistoryFrom[playerid][i], CallHistoryTo[playerid][i], 
               CallHistoryDuration[playerid][i], type);
        strcat(string, history, sizeof(string));
    }
    
    strcat(string, "Clear History\n", sizeof(string));
    
    ShowPlayerDialog(playerid, 1003, DIALOG_STYLE_LIST, "Call History", string, "Select", "Back");
}

// ===========================================
// Dialog Responses
// ===========================================

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case 1000: // Phone Main Menu
        {
            if(!response) return 1;
            
            switch(listitem)
            {
                case 0: // Make Call
                {
                    ShowPlayerDialog(playerid, 1004, DIALOG_STYLE_INPUT, "Make Call", "Enter phone number:", "Call", "Cancel");
                }
                case 1: // Contacts
                {
                    ShowContactsMenu(playerid);
                }
                case 2: // Messages
                {
                    ShowMessagesMenu(playerid);
                }
                case 3: // Call History
                {
                    ShowCallHistoryMenu(playerid);
                }
                case 4: // Phone Credit
                {
                    new string[128];
                    format(string, sizeof(string), "Your phone credit: $%d\n\nAdd credit amount:", PlayerPhoneCredit[playerid]);
                    ShowPlayerDialog(playerid, 1005, DIALOG_STYLE_INPUT, "Phone Credit", string, "Add", "Back");
                }
                case 5: // Settings
                {
                    ShowPlayerDialog(playerid, 1006, DIALOG_STYLE_MSGBOX, "Phone Settings", "Phone Settings:\n\nPhone Number: Your number\nCredit: Your credit\nStatus: Online", "OK", "Back");
                }
            }
        }
        
        case 1001: // Contacts Menu
        {
            if(!response)
            {
                ShowPhoneMainMenu(playerid);
                return 1;
            }
            
            if(listitem == ContactCount[playerid]) // Add Contact
            {
                ShowPlayerDialog(playerid, 1007, DIALOG_STYLE_INPUT, "Add Contact", "Enter contact name:", "Next", "Back");
            }
            else if(listitem == ContactCount[playerid] + 1) // Delete Contact
            {
                ShowPlayerDialog(playerid, 1008, DIALOG_STYLE_INPUT, "Delete Contact", "Enter contact name to delete:", "Delete", "Back");
            }
            else // Call contact
            {
                new cmd[128];
                format(cmd, sizeof(cmd), "/call %s", ContactNumbers[playerid][listitem]);
                CallLocalFunction("OnPlayerCommandText", "is", playerid, cmd);
            }
        }
        
        case 1002: // Messages Menu
        {
            if(!response)
            {
                ShowPhoneMainMenu(playerid);
                return 1;
            }
            
            if(listitem == MessageCount[playerid]) // Send Message
            {
                ShowPlayerDialog(playerid, 1009, DIALOG_STYLE_INPUT, "Send Message", "Enter phone number:", "Next", "Back");
            }
            else if(listitem == MessageCount[playerid] + 1) // Delete Messages
            {
                MessageCount[playerid] = 0;
                SendClientMessage(playerid, 0x00FF00FF, "All messages deleted!");
                ShowMessagesMenu(playerid);
            }
        }
        
        case 1003: // Call History Menu
        {
            if(!response)
            {
                ShowPhoneMainMenu(playerid);
                return 1;
            }
            
            if(listitem == CallHistoryCount[playerid]) // Clear History
            {
                CallHistoryCount[playerid] = 0;
                SendClientMessage(playerid, 0x00FF00FF, "Call history cleared!");
                ShowCallHistoryMenu(playerid);
            }
        }
        
        case 1004: // Make Call
        {
            if(!response) return 1;
            
            new cmd[128];
            format(cmd, sizeof(cmd), "/call %s", inputtext);
            CallLocalFunction("OnPlayerCommandText", "is", playerid, cmd);
        }
        
        case 1005: // Phone Credit
        {
            if(!response)
            {
                ShowPhoneMainMenu(playerid);
                return 1;
            }
            
            new cmd[128];
            format(cmd, sizeof(cmd), "/addcredit %s", inputtext);
            CallLocalFunction("OnPlayerCommandText", "is", playerid, cmd);
        }
        
        case 1007: // Add Contact - Name
        {
            if(!response)
            {
                ShowContactsMenu(playerid);
                return 1;
            }
            
            SetPVarString(playerid, "ContactName", inputtext);
            ShowPlayerDialog(playerid, 1010, DIALOG_STYLE_INPUT, "Add Contact", "Enter phone number:", "Add", "Back");
        }
        
        case 1010: // Add Contact - Number
        {
            if(!response)
            {
                ShowContactsMenu(playerid);
                return 1;
            }
            
            new name[32];
            GetPVarString(playerid, "ContactName", name, 32);
            
            new cmd[128];
            format(cmd, sizeof(cmd), "/addcontact %s %s", name, inputtext);
            CallLocalFunction("OnPlayerCommandText", "is", playerid, cmd);
            
            DeletePVar(playerid, "ContactName");
        }
        
        case 1009: // Send Message - Number
        {
            if(!response)
            {
                ShowMessagesMenu(playerid);
                return 1;
            }
            
            SetPVarString(playerid, "MessageNumber", inputtext);
            ShowPlayerDialog(playerid, 1011, DIALOG_STYLE_INPUT, "Send Message", "Enter message:", "Send", "Back");
        }
        
        case 1011: // Send Message - Text
        {
            if(!response)
            {
                ShowMessagesMenu(playerid);
                return 1;
            }
            
            new number[15];
            GetPVarString(playerid, "MessageNumber", number, 15);
            
            new cmd[256];
            format(cmd, sizeof(cmd), "/sendmessage %s %s", number, inputtext);
            CallLocalFunction("OnPlayerCommandText", "is", playerid, cmd);
            
            DeletePVar(playerid, "MessageNumber");
        }
    }
    
    return 1;
}

// ===========================================
// Timer Functions
// ===========================================

public OnPhoneUpdate()
{
    foreach(new i : Player)
    {
        if(PlayerPhoneOn[i] && PlayerPhoneState[i] == PHONE_STATE_IN_CALL)
        {
            // Check if player has enough credit
            new duration = gettime() - PlayerCallStartTime[i];
            new cost = (duration / 60) * CALL_COST_PER_MINUTE;
            
            if(PlayerPhoneCredit[i] < cost)
            {
                EndPhoneCall(i, 2); // Reason: Out of credit
            }
        }
    }
}

public OnPhoneCallTimeout(playerid, targetid)
{
    if(PlayerPhoneState[playerid] == PHONE_STATE_CALLING && PlayerPhoneState[targetid] == PHONE_STATE_RINGING)
    {
        EndPhoneCall(playerid, 0); // Reason: Timeout
        SendClientMessage(playerid, 0xFF0000FF, "Call timed out - no answer.");
        SendClientMessage(targetid, 0xFF0000FF, "Missed call.");
        
        // Add to call history
        AddCallHistory(playerid, targetid, 0, 2); // 2 = dialed
        AddCallHistory(targetid, playerid, 0, 0); // 0 = missed
    }
}

public OnPhoneCallUpdate(playerid)
{
    if(PlayerPhoneState[playerid] == PHONE_STATE_IN_CALL)
    {
        new duration = gettime() - PlayerCallStartTime[playerid];
        new minutes = duration / 60;
        new seconds = duration % 60;
        
        new string[64];
        format(string, sizeof(string), "Call duration: %02d:%02d", minutes, seconds);
        GameTextForPlayer(playerid, string, 2000, 4);
    }
}

// ===========================================
// Database Functions
// ===========================================

LoadPlayerPhoneData(playerid)
{
    new query[256];
    format(query, sizeof(query), "SELECT * FROM player_phones WHERE playerid = %d", playerid);
    mysql_query(g_SQL, query);
    
    new result = mysql_store_result(g_SQL);
    if(mysql_num_rows(result) > 0)
    {
        new row[256];
        mysql_fetch_row(row, result);
        
        PlayerPhoneOn[playerid] = strval(row[4]);
        PlayerPhoneNumber[playerid] = strval(row[2]);
        PlayerPhoneCredit[playerid] = strval(row[3]);
    }
    mysql_free_result(result);
    
    // Load contacts
    LoadPlayerContacts(playerid);
    
    // Load messages
    LoadPlayerMessages(playerid);
    
    // Load call history
    LoadPlayerCallHistory(playerid);
}

SavePlayerPhoneData(playerid)
{
    new query[256];
    format(query, sizeof(query), "INSERT INTO player_phones (playerid, phonenumber, credit, hasphone) VALUES (%d, %d, %d, %d) ON DUPLICATE KEY UPDATE phonenumber = %d, credit = %d, hasphone = %d",
           playerid, PlayerPhoneNumber[playerid], PlayerPhoneCredit[playerid], PlayerPhoneOn[playerid],
           PlayerPhoneNumber[playerid], PlayerPhoneCredit[playerid], PlayerPhoneOn[playerid]);
    mysql_query(g_SQL, query);
}

LoadPlayerContacts(playerid)
{
    new query[256];
    format(query, sizeof(query), "SELECT * FROM phone_contacts WHERE playerid = %d", playerid);
    mysql_query(g_SQL, query);
    
    new result = mysql_store_result(g_SQL);
    ContactCount[playerid] = 0;
    
    new row[256];
    while(mysql_fetch_row(row, result) && ContactCount[playerid] < MAX_PHONE_CONTACTS)
    {
        strcat(ContactNames[playerid][ContactCount[playerid]], row[2], 32);
        strcat(ContactNumbers[playerid][ContactCount[playerid]], row[3], 15);
        ContactCount[playerid]++;
    }
    mysql_free_result(result);
}

SavePlayerContacts(playerid)
{
    // Delete existing contacts
    new query[128];
    format(query, sizeof(query), "DELETE FROM phone_contacts WHERE playerid = %d", playerid);
    mysql_query(g_SQL, query);
    
    // Insert new contacts
    for(new i = 0; i < ContactCount[playerid]; i++)
    {
        format(query, sizeof(query), "INSERT INTO phone_contacts (playerid, contactname, contactnumber) VALUES (%d, '%s', '%s')",
               playerid, ContactNames[playerid][i], ContactNumbers[playerid][i]);
        mysql_query(g_SQL, query);
    }
}

LoadPlayerMessages(playerid)
{
    new query[256];
    format(query, sizeof(query), "SELECT * FROM phone_messages WHERE playerid = %d ORDER BY timestamp DESC LIMIT %d", playerid, MAX_PHONE_MESSAGES);
    mysql_query(g_SQL, query);
    
    new result = mysql_store_result(g_SQL);
    MessageCount[playerid] = 0;
    
    new row[512];
    while(mysql_fetch_row(row, result) && MessageCount[playerid] < MAX_PHONE_MESSAGES)
    {
        strcat(MessageFrom[playerid][MessageCount[playerid]], row[2], 32);
        strcat(MessageText[playerid][MessageCount[playerid]], row[3], 128);
        MessageTime[playerid][MessageCount[playerid]] = strval(row[4]);
        MessageCount[playerid]++;
    }
    mysql_free_result(result);
}

LoadPlayerCallHistory(playerid)
{
    new query[256];
    format(query, sizeof(query), "SELECT * FROM phone_calls WHERE playerid = %d ORDER BY timestamp DESC LIMIT %d", playerid, MAX_CALL_HISTORY);
    mysql_query(g_SQL, query);
    
    new result = mysql_store_result(g_SQL);
    CallHistoryCount[playerid] = 0;
    
    new row[256];
    while(mysql_fetch_row(row, result) && CallHistoryCount[playerid] < MAX_CALL_HISTORY)
    {
        strcat(CallHistoryFrom[playerid][CallHistoryCount[playerid]], row[2], 32);
        strcat(CallHistoryTo[playerid][CallHistoryCount[playerid]], row[3], 32);
        CallHistoryDuration[playerid][CallHistoryCount[playerid]] = strval(row[4]);
        CallHistoryType[playerid][CallHistoryCount[playerid]] = strval(row[5]);
        CallHistoryCount[playerid]++;
    }
    mysql_free_result(result);
}

// ===========================================
// Utility Functions
// ===========================================

GetPlayerNameEx(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, MAX_PLAYER_NAME);
    return name;
}

// ===========================================
// End of Script
// ===========================================