#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <foreach>
#include <file>
#include <YSI/y_ini>

#define COLOR_INFO          0xB8D8FFFF
#define COLOR_ERROR         0xE57373FF
#define COLOR_SUCCESS       0x81C784FF
#define COLOR_WARNING       0xFFD54FFF
#define COLOR_CALL          0x90CAF9FF
#define COLOR_SMS           0xA5D6A7FF

#define RING_DURATION_MS    (20000)
#define SMS_MAX_LEN         (144)
#define MAX_CONTACTS        (50)
#define MAX_BLOCKED         (30)
#define INVALID_NUMBER      (0)
#define PHONE_SAVE_DIR      "scriptfiles/phone/"

// -------------------------------
// Data structures
// -------------------------------

enum ECallState
{
    CALLSTATE_NONE = 0,
    CALLSTATE_CALLING,
    CALLSTATE_RINGING,
    CALLSTATE_INCALL
};

enum EContact
{
    contactNumber,
    contactName[24]
};

new PlayerPhoneNumber[MAX_PLAYERS];
new bool:PlayerPhoneOn[MAX_PLAYERS];
new ECallState:PlayerCallState[MAX_PLAYERS];
new PlayerCallPeer[MAX_PLAYERS];
new PlayerRingTimer[MAX_PLAYERS];

new PlayerContacts[MAX_PLAYERS][MAX_CONTACTS][EContact];
new PlayerContactsCount[MAX_PLAYERS];

new PlayerBlockedCount[MAX_PLAYERS];
new PlayerBlockedNumbers[MAX_PLAYERS][MAX_BLOCKED];

// -------------------------------
// Forwards
// -------------------------------
forward Phone_LoadData(playerid, name[], value[]);
forward Phone_OnRingTimeout(calleeid, callerid);

// -------------------------------
// Utilities
// -------------------------------
stock SendInfo(playerid, const fmt[], {Float,_}:...)
{
    new msg[180];
    vformat(msg, sizeof msg, fmt, 3);
    return SendClientMessage(playerid, COLOR_INFO, msg);
}

stock SendError(playerid, const fmt[], {Float,_}:...)
{
    new msg[180];
    vformat(msg, sizeof msg, fmt, 3);
    return SendClientMessage(playerid, COLOR_ERROR, msg);
}

stock SendSuccess(playerid, const fmt[], {Float,_}:...)
{
    new msg[180];
    vformat(msg, sizeof msg, fmt, 3);
    return SendClientMessage(playerid, COLOR_SUCCESS, msg);
}

stock SendCall(playerid, const fmt[], {Float,_}:...)
{
    new msg[180];
    vformat(msg, sizeof msg, fmt, 3);
    return SendClientMessage(playerid, COLOR_CALL, msg);
}

stock SendSMSMsg(playerid, const fmt[], {Float,_}:...)
{
    new msg[180];
    vformat(msg, sizeof msg, fmt, 3);
    return SendClientMessage(playerid, COLOR_SMS, msg);
}

stock bool:IsNumeric(const str[])
{
    if (str[0] == '\0') return false;
    for (new i = 0; str[i] != '\0'; i++)
    {
        if (str[i] < '0' || str[i] > '9') return false;
    }
    return true;
}

stock GetPlayerPhonePath(playerid, out[], outlen)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof name);
    format(out, outlen, PHONE_SAVE_DIR "%s.ini", name);
}

stock ResetPhoneState(playerid)
{
    PlayerCallState[playerid] = CALLSTATE_NONE;
    PlayerCallPeer[playerid] = INVALID_PLAYER_ID;
    if (PlayerRingTimer[playerid] != 0)
    {
        KillTimer(PlayerRingTimer[playerid]);
        PlayerRingTimer[playerid] = 0;
    }
}

stock bool:IsInCall(playerid)
{
    return PlayerCallState[playerid] == CALLSTATE_INCALL;
}

stock bool:IsBusy(playerid)
{
    return PlayerCallState[playerid] != CALLSTATE_NONE;
}

stock bool:IsNumberBlocked(playerid, number)
{
    for (new i = 0; i < PlayerBlockedCount[playerid]; i++)
    {
        if (PlayerBlockedNumbers[playerid][i] == number) return true;
    }
    return false;
}

stock FindOnlinePlayerByNumber(number)
{
    foreach (new i : Player)
    {
        if (PlayerPhoneNumber[i] == number) return i;
    }
    return INVALID_PLAYER_ID;
}

stock GetContactIndexByNumber(playerid, number)
{
    for (new i = 0; i < PlayerContactsCount[playerid]; i++)
    {
        if (PlayerContacts[playerid][i][contactNumber] == number) return i;
    }
    return -1;
}

stock GetContactIndexByName(playerid, const name[])
{
    for (new i = 0; i < PlayerContactsCount[playerid]; i++)
    {
        if (!strcmp(PlayerContacts[playerid][i][contactName], name, true)) return i;
    }
    return -1;
}

stock bool:GetContactNameForNumber(playerid, number, dest[], len)
{
    for (new i = 0; i < PlayerContactsCount[playerid]; i++)
    {
        if (PlayerContacts[playerid][i][contactNumber] == number)
        {
            format(dest, len, "%s", PlayerContacts[playerid][i][contactName]);
            return true;
        }
    }
    return false;
}

stock bool:AddContact(playerid, number, const name[])
{
    if (PlayerContactsCount[playerid] >= MAX_CONTACTS) return false;
    new idx = PlayerContactsCount[playerid];
    PlayerContacts[playerid][idx][contactNumber] = number;
    format(PlayerContacts[playerid][idx][contactName], 24, "%s", name);
    PlayerContactsCount[playerid]++;
    return true;
}

stock bool:RemoveContactByIndex(playerid, index)
{
    if (index < 0 || index >= PlayerContactsCount[playerid]) return false;
    for (new i = index; i < PlayerContactsCount[playerid] - 1; i++)
    {
        PlayerContacts[playerid][i][contactNumber] = PlayerContacts[playerid][i + 1][contactNumber];
        format(PlayerContacts[playerid][i][contactName], 24, "%s", PlayerContacts[playerid][i + 1][contactName]);
    }
    PlayerContactsCount[playerid]--;
    return true;
}

stock bool:AddBlockedNumber(playerid, number)
{
    if (PlayerBlockedCount[playerid] >= MAX_BLOCKED) return false;
    PlayerBlockedNumbers[playerid][PlayerBlockedCount[playerid]++] = number;
    return true;
}

stock bool:RemoveBlockedNumber(playerid, number)
{
    for (new i = 0; i < PlayerBlockedCount[playerid]; i++)
    {
        if (PlayerBlockedNumbers[playerid][i] == number)
        {
            for (new j = i; j < PlayerBlockedCount[playerid] - 1; j++)
            {
                PlayerBlockedNumbers[playerid][j] = PlayerBlockedNumbers[playerid][j + 1];
            }
            PlayerBlockedCount[playerid]--;
            return true;
        }
    }
    return false;
}

stock GenerateUniqueNumber()
{
    new attempt, num;
    for (attempt = 0; attempt < 1000; attempt++)
    {
        num = 100000 + random(900000); // 6-digit
        // ensure not used by any online player right now
        if (FindOnlinePlayerByNumber(num) == INVALID_PLAYER_ID) return num;
    }
    return 100000 + random(900000);
}

stock SavePhoneData(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    new path[128];
    GetPlayerPhonePath(playerid, path, sizeof path);

    new File:f = fopen(path, io_write);
    if (!f) return 0;

    new line[196];
    format(line, sizeof line, "number=%d\r\n", PlayerPhoneNumber[playerid]);
    fwrite(f, line);
    format(line, sizeof line, "phone_on=%d\r\n", PlayerPhoneOn[playerid]);
    fwrite(f, line);

    // contacts
    format(line, sizeof line, "contact_count=%d\r\n", PlayerContactsCount[playerid]);
    fwrite(f, line);
    for (new i = 0; i < PlayerContactsCount[playerid]; i++)
    {
        format(line, sizeof line, "c%d_num=%d\r\n", i, PlayerContacts[playerid][i][contactNumber]);
        fwrite(f, line);
        format(line, sizeof line, "c%d_name=%s\r\n", i, PlayerContacts[playerid][i][contactName]);
        fwrite(f, line);
    }

    // blocked
    format(line, sizeof line, "blocked_count=%d\r\n", PlayerBlockedCount[playerid]);
    fwrite(f, line);
    for (new j = 0; j < PlayerBlockedCount[playerid]; j++)
    {
        format(line, sizeof line, "b%d=%d\r\n", j, PlayerBlockedNumbers[playerid][j]);
        fwrite(f, line);
    }

    fclose(f);
    return 1;
}

public Phone_LoadData(playerid, name[], value[])
{
    if (!strcmp(name, "number", true))
    {
        PlayerPhoneNumber[playerid] = strval(value);
    }
    else if (!strcmp(name, "phone_on", true))
    {
        PlayerPhoneOn[playerid] = bool:strval(value);
    }
    else if (!strcmp(name, "contact_count", true))
    {
        PlayerContactsCount[playerid] = strval(value);
        if (PlayerContactsCount[playerid] < 0) PlayerContactsCount[playerid] = 0;
        if (PlayerContactsCount[playerid] > MAX_CONTACTS) PlayerContactsCount[playerid] = MAX_CONTACTS;
    }
    else if (!strcmp(name, "blocked_count", true))
    {
        PlayerBlockedCount[playerid] = strval(value);
        if (PlayerBlockedCount[playerid] < 0) PlayerBlockedCount[playerid] = 0;
        if (PlayerBlockedCount[playerid] > MAX_BLOCKED) PlayerBlockedCount[playerid] = MAX_BLOCKED;
    }
    else if (name[0] == 'c')
    {
        // Expecting c<idx>_num or c<idx>_name
        new idx = -1;
        new pos = 1;
        while (name[pos] >= '0' && name[pos] <= '9') pos++;
        if (pos > 1)
        {
            new digits[6];
            strmid(digits, name[1], 0, pos - 1, sizeof digits);
            idx = strval(digits);
        }
        if (idx >= 0 && idx < MAX_CONTACTS && name[pos] == '_' )
        {
            if (!strcmp(name[pos + 1], "num", true))
            {
                PlayerContacts[playerid][idx][contactNumber] = strval(value);
                if (idx >= PlayerContactsCount[playerid]) PlayerContactsCount[playerid] = idx + 1;
            }
            else if (!strcmp(name[pos + 1], "name", true))
            {
                format(PlayerContacts[playerid][idx][contactName], 24, "%s", value);
                if (idx >= PlayerContactsCount[playerid]) PlayerContactsCount[playerid] = idx + 1;
            }
        }
    }
    else if (name[0] == 'b')
    {
        // Expecting b<idx>
        new pos = 1;
        while (name[pos] >= '0' && name[pos] <= '9') pos++;
        if (pos > 1)
        {
            new digits[6];
            // copy digits after 'b' (name[1..pos-1]) into digits buffer
            strmid(digits, name[1], 0, pos - 1, sizeof digits);
            new idx = strval(digits);
            if (idx >= 0 && idx < MAX_BLOCKED)
            {
                PlayerBlockedNumbers[playerid][idx] = strval(value);
                if (idx >= PlayerBlockedCount[playerid]) PlayerBlockedCount[playerid] = idx + 1;
            }
        }
    }
    return 1;
}

stock LoadPhoneData(playerid)
{
    // reset defaults
    PlayerPhoneOn[playerid] = true;
    PlayerContactsCount[playerid] = 0;
    PlayerBlockedCount[playerid] = 0;

    new path[128];
    GetPlayerPhonePath(playerid, path, sizeof path);

    if (fexist(path))
    {
        INI_ParseFile(path, "Phone_LoadData", .bExtra = true, .extra = playerid);
        // Ensure uniqueness among online players for the loaded number
        if (PlayerPhoneNumber[playerid] <= 0)
        {
            PlayerPhoneNumber[playerid] = GenerateUniqueNumber();
        }
        else
        {
            // if number already used by someone online (name collision), regenerate
            foreach (new i : Player)
            {
                if (i == playerid) continue;
                if (PlayerPhoneNumber[i] == PlayerPhoneNumber[playerid])
                {
                    PlayerPhoneNumber[playerid] = GenerateUniqueNumber();
                    break;
                }
            }
        }
    }
    else
    {
        PlayerPhoneNumber[playerid] = GenerateUniqueNumber();
        SavePhoneData(playerid);
    }
    return 1;
}

stock DescribeNumberFor(playerid, number, out[], len)
{
    new cname[24];
    if (GetContactNameForNumber(playerid, number, cname, sizeof cname))
    {
        format(out, len, "%d (%s)", number, cname);
    }
    else
    {
        format(out, len, "%d", number);
    }
}

// -------------------------------
// Ring Timeout
// -------------------------------
public Phone_OnRingTimeout(calleeid, callerid)
{
    PlayerRingTimer[calleeid] = 0;

    if (!IsPlayerConnected(calleeid) || !IsPlayerConnected(callerid)) return 1;

    if (PlayerCallState[calleeid] == CALLSTATE_RINGING && PlayerCallPeer[calleeid] == callerid)
    {
        SendCall(callerid, "Call to %d timed out.", PlayerPhoneNumber[calleeid]);
        SendCall(calleeid, "Missed call from %d.", PlayerPhoneNumber[callerid]);
        ResetPhoneState(calleeid);
        ResetPhoneState(callerid);
    }
    return 1;
}

// -------------------------------
// SA:MP callbacks
// -------------------------------
public OnFilterScriptInit()
{
    print("[phone] Phone filterscript loaded.");
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        PlayerPhoneNumber[i] = INVALID_NUMBER;
        PlayerPhoneOn[i] = true;
        PlayerCallState[i] = CALLSTATE_NONE;
        PlayerCallPeer[i] = INVALID_PLAYER_ID;
        PlayerRingTimer[i] = 0;
        PlayerContactsCount[i] = 0;
        PlayerBlockedCount[i] = 0;
    }
    return 1;
}

public OnFilterScriptExit()
{
    foreach (new i : Player)
    {
        if (IsPlayerConnected(i))
        {
            SavePhoneData(i);
        }
    }
    print("[phone] Phone filterscript unloaded.");
    return 1;
}

public OnPlayerConnect(playerid)
{
    ResetPhoneState(playerid);
    LoadPhoneData(playerid);
    SendInfo(playerid, "Your phone number is %d. Use /phelp for commands.", PlayerPhoneNumber[playerid]);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    SavePhoneData(playerid);
    // If in call with someone, let them know
    new peer = PlayerCallPeer[playerid];
    if (peer != INVALID_PLAYER_ID && IsPlayerConnected(peer))
    {
        SendCall(peer, "Call ended (peer disconnected).");
        ResetPhoneState(peer);
    }
    ResetPhoneState(playerid);
    return 1;
}

// -------------------------------
// Commands
// -------------------------------
CMD:phelp(playerid, params[])
{
    SendInfo(playerid, "Phone commands: /phone on|off|status, /mynumber");
    SendInfo(playerid, "/call <number|contact>", 0);
    SendInfo(playerid, "/pickup, /hangup, /answer");
    SendInfo(playerid, "/sms <number|contact> <message>");
    SendInfo(playerid, "/addcontact <number> <name>, /delcontact <number|name>, /contacts [page]");
    SendInfo(playerid, "/block <number>, /unblock <number>, /blocked");
    SendInfo(playerid, "/setnumber <6-9 digits>");
    return 1;
}

CMD:phone(playerid, params[])
{
    new sub[16];
    if (sscanf(params, "s[16]", sub))
    {
        SendInfo(playerid, "Usage: /phone on|off|status");
        return 1;
    }

    if (!strcmp(sub, "on", true))
    {
        if (PlayerPhoneOn[playerid]) return SendInfo(playerid, "Your phone is already ON."), 1;
        PlayerPhoneOn[playerid] = true;
        SavePhoneData(playerid);
        SendSuccess(playerid, "You turned your phone ON.");
    }
    else if (!strcmp(sub, "off", true))
    {
        if (!PlayerPhoneOn[playerid]) return SendInfo(playerid, "Your phone is already OFF."), 1;
        PlayerPhoneOn[playerid] = false;
        // If ringing or in call, end
        if (PlayerCallState[playerid] != CALLSTATE_NONE)
        {
            new peer = PlayerCallPeer[playerid];
            if (peer != INVALID_PLAYER_ID && IsPlayerConnected(peer))
            {
                SendCall(peer, "Call ended. %d turned their phone off.", PlayerPhoneNumber[playerid]);
                ResetPhoneState(peer);
            }
            ResetPhoneState(playerid);
        }
        SavePhoneData(playerid);
        SendSuccess(playerid, "You turned your phone OFF.");
    }
    else if (!strcmp(sub, "status", true))
    {
        SendInfo(playerid, "Phone: %s | Number: %d", PlayerPhoneOn[playerid] ? ("ON") : ("OFF"), PlayerPhoneNumber[playerid]);
    }
    else
    {
        SendInfo(playerid, "Usage: /phone on|off|status");
    }
    return 1;
}

CMD:mynumber(playerid, params[])
{
    SendInfo(playerid, "Your phone number is %d", PlayerPhoneNumber[playerid]);
    return 1;
}

static stock ResolveTargetToNumber(playerid, const arg[])
{
    if (IsNumeric(arg)) return strval(arg);
    new idx = GetContactIndexByName(playerid, arg);
    if (idx != -1) return PlayerContacts[playerid][idx][contactNumber];
    return INVALID_NUMBER;
}

CMD:call(playerid, params[])
{
    new arg[32];
    if (sscanf(params, "s[32]", arg))
    {
        SendInfo(playerid, "Usage: /call <number|contact>");
        return 1;
    }

    if (!PlayerPhoneOn[playerid]) return SendError(playerid, "Your phone is OFF."), 1;
    if (IsBusy(playerid)) return SendError(playerid, "You are busy."), 1;

    new number = ResolveTargetToNumber(playerid, arg);
    if (number <= 0) return SendError(playerid, "Invalid number or contact."), 1;

    new target = FindOnlinePlayerByNumber(number);
    if (target == INVALID_PLAYER_ID) return SendError(playerid, "Number %d is unreachable.", number), 1;
    if (target == playerid) return SendError(playerid, "You can't call yourself."), 1;

    if (!PlayerPhoneOn[target]) return SendError(playerid, "Number %d is switched off.", number), 1;

    if (IsBusy(target)) return SendError(playerid, "Number %d is busy.", number), 1;

    if (IsNumberBlocked(target, PlayerPhoneNumber[playerid]))
    {
        return SendError(playerid, "Your number is blocked by %d.", number), 1;
    }

    // Set up call states
    PlayerCallState[playerid] = CALLSTATE_CALLING;
    PlayerCallPeer[playerid] = target;

    PlayerCallState[target] = CALLSTATE_RINGING;
    PlayerCallPeer[target] = playerid;

    PlayerRingTimer[target] = SetTimerEx("Phone_OnRingTimeout", RING_DURATION_MS, false, "ii", target, playerid);

    new youSee[64];
    DescribeNumberFor(playerid, PlayerPhoneNumber[target], youSee, sizeof youSee);

    new theySee[64];
    DescribeNumberFor(target, PlayerPhoneNumber[playerid], theySee, sizeof theySee);

    SendCall(playerid, "Calling %s ...", youSee);
    SendCall(target, "%s is calling. Use /pickup or /hangup.", theySee);
    return 1;
}

CMD:pickup(playerid, params[])
{
    if (PlayerCallState[playerid] != CALLSTATE_RINGING) return SendError(playerid, "You are not being called."), 1;
    new caller = PlayerCallPeer[playerid];
    if (caller == INVALID_PLAYER_ID || !IsPlayerConnected(caller))
    {
        ResetPhoneState(playerid);
        return SendError(playerid, "Caller not available."), 1;
    }

    if (!PlayerPhoneOn[playerid])
    {
        SendError(playerid, "Your phone is OFF.");
        return 1;
    }

    if (IsNumberBlocked(playerid, PlayerPhoneNumber[caller]))
    {
        SendError(playerid, "Caller is blocked.");
        ResetPhoneState(playerid);
        ResetPhoneState(caller);
        return 1;
    }

    if (PlayerRingTimer[playerid] != 0)
    {
        KillTimer(PlayerRingTimer[playerid]);
        PlayerRingTimer[playerid] = 0;
    }

    PlayerCallState[playerid] = CALLSTATE_INCALL;
    PlayerCallState[caller] = CALLSTATE_INCALL;

    new youSee[64];
    DescribeNumberFor(playerid, PlayerPhoneNumber[caller], youSee, sizeof youSee);

    new theySee[64];
    DescribeNumberFor(caller, PlayerPhoneNumber[playerid], theySee, sizeof theySee);

    SendCall(playerid, "You answered the call from %s.", youSee);
    SendCall(caller, "%s answered. You're now connected. Use /hangup to end.", theySee);
    return 1;
}

CMD:answer(playerid, params[]) return cmd_pickup(playerid, params);

CMD:hangup(playerid, params[])
{
    if (PlayerCallState[playerid] == CALLSTATE_NONE) return SendError(playerid, "You are not in a call."), 1;

    new peer = PlayerCallPeer[playerid];

    if (PlayerCallState[playerid] == CALLSTATE_RINGING)
    {
        SendCall(playerid, "You declined the call.");
        if (PlayerRingTimer[playerid] != 0)
        {
            KillTimer(PlayerRingTimer[playerid]);
            PlayerRingTimer[playerid] = 0;
        }
        if (peer != INVALID_PLAYER_ID && IsPlayerConnected(peer)) SendCall(peer, "Call to %d was declined.", PlayerPhoneNumber[playerid]);
        if (peer != INVALID_PLAYER_ID) ResetPhoneState(peer);
        ResetPhoneState(playerid);
        return 1;
    }

    if (PlayerCallState[playerid] == CALLSTATE_CALLING)
    {
        SendCall(playerid, "You cancelled the call.");
        if (peer != INVALID_PLAYER_ID && IsPlayerConnected(peer))
        {
            if (PlayerCallState[peer] == CALLSTATE_RINGING)
            {
                if (PlayerRingTimer[peer] != 0)
                {
                    KillTimer(PlayerRingTimer[peer]);
                    PlayerRingTimer[peer] = 0;
                }
                SendCall(peer, "%d cancelled the call.", PlayerPhoneNumber[playerid]);
            }
            ResetPhoneState(peer);
        }
        ResetPhoneState(playerid);
        return 1;
    }

    if (PlayerCallState[playerid] == CALLSTATE_INCALL)
    {
        SendCall(playerid, "You hung up.");
        if (peer != INVALID_PLAYER_ID && IsPlayerConnected(peer)) SendCall(peer, "%d hung up.", PlayerPhoneNumber[playerid]);
        if (peer != INVALID_PLAYER_ID) ResetPhoneState(peer);
        ResetPhoneState(playerid);
        return 1;
    }

    return 1;
}

CMD:sms(playerid, params[])
{
    new arg[32], text[SMS_MAX_LEN + 8];
    if (sscanf(params, "s[32] S()[152]", arg, text))
    {
        SendInfo(playerid, "Usage: /sms <number|contact> <message>");
        return 1;
    }

    if (!PlayerPhoneOn[playerid]) return SendError(playerid, "Your phone is OFF."), 1;

    if (strlen(text) > SMS_MAX_LEN)
    {
        text[SMS_MAX_LEN] = '\0';
    }

    new number = ResolveTargetToNumber(playerid, arg);
    if (number <= 0) return SendError(playerid, "Invalid number or contact."), 1;

    new target = FindOnlinePlayerByNumber(number);
    if (target == INVALID_PLAYER_ID) return SendError(playerid, "Number %d is unreachable.", number), 1;
    if (!PlayerPhoneOn[target]) return SendError(playerid, "Number %d is switched off.", number), 1;
    if (IsNumberBlocked(target, PlayerPhoneNumber[playerid])) return SendError(playerid, "Your number is blocked by %d.", number), 1;

    new fromBuf[64], toBuf[64];
    DescribeNumberFor(target, PlayerPhoneNumber[playerid], fromBuf, sizeof fromBuf);
    DescribeNumberFor(playerid, PlayerPhoneNumber[target], toBuf, sizeof toBuf);

    SendSMSMsg(playerid, "SMS to %s: %s", toBuf, text);
    SendSMSMsg(target, "SMS from %s: %s", fromBuf, text);
    return 1;
}

CMD:addcontact(playerid, params[])
{
    new number, name[24];
    if (sscanf(params, "i S()[24]", number, name))
    {
        SendInfo(playerid, "Usage: /addcontact <number> <name>");
        return 1;
    }

    if (number <= 0) return SendError(playerid, "Invalid number."), 1;
    if (GetContactIndexByNumber(playerid, number) != -1) return SendError(playerid, "This number is already in contacts."), 1;
    if (!AddContact(playerid, number, name)) return SendError(playerid, "Contacts full (%d).", MAX_CONTACTS), 1;

    SavePhoneData(playerid);
    SendSuccess(playerid, "Added contact: %d (%s)", number, name);
    return 1;
}

CMD:delcontact(playerid, params[])
{
    new arg[32];
    if (sscanf(params, "s[32]", arg))
    {
        SendInfo(playerid, "Usage: /delcontact <number|name>");
        return 1;
    }

    new idx = -1;
    if (IsNumeric(arg))
    {
        idx = GetContactIndexByNumber(playerid, strval(arg));
    }
    else
    {
        idx = GetContactIndexByName(playerid, arg);
    }

    if (idx == -1) return SendError(playerid, "Contact not found."), 1;

    new number = PlayerContacts[playerid][idx][contactNumber];
    new cname[24];
    format(cname, sizeof cname, "%s", PlayerContacts[playerid][idx][contactName]);

    RemoveContactByIndex(playerid, idx);
    SavePhoneData(playerid);
    SendSuccess(playerid, "Deleted contact: %d (%s)", number, cname);
    return 1;
}

CMD:contacts(playerid, params[])
{
    new page = 1;
    sscanf(params, "D(1)", page);
    if (page < 1) page = 1;

    new total = PlayerContactsCount[playerid];
    if (total == 0) return SendInfo(playerid, "Your contacts list is empty."), 1;

    new perPage = 10;
    new pages = total / perPage + ((total % perPage) ? 1 : 0);
    if (page > pages) page = pages;

    new start = (page - 1) * perPage;
    new end = start + perPage;
    if (end > total) end = total;

    new header[64];
    format(header, sizeof header, "Contacts (Page %d/%d):", page, pages);
    SendInfo(playerid, header);

    for (new i = start; i < end; i++)
    {
        SendInfo(playerid, "%02d) %d (%s)", i + 1, PlayerContacts[playerid][i][contactNumber], PlayerContacts[playerid][i][contactName]);
    }
    return 1;
}

CMD:block(playerid, params[])
{
    new number;
    if (sscanf(params, "i", number))
    {
        SendInfo(playerid, "Usage: /block <number>");
        return 1;
    }

    if (number <= 0) return SendError(playerid, "Invalid number."), 1;
    if (IsNumberBlocked(playerid, number)) return SendInfo(playerid, "Number already blocked."), 1;

    if (!AddBlockedNumber(playerid, number)) return SendError(playerid, "Blocked list full (%d).", MAX_BLOCKED), 1;
    SavePhoneData(playerid);
    SendSuccess(playerid, "Blocked %d", number);
    return 1;
}

CMD:unblock(playerid, params[])
{
    new number;
    if (sscanf(params, "i", number))
    {
        SendInfo(playerid, "Usage: /unblock <number>");
        return 1;
    }

    if (!RemoveBlockedNumber(playerid, number)) return SendError(playerid, "Number not in block list."), 1;
    SavePhoneData(playerid);
    SendSuccess(playerid, "Unblocked %d", number);
    return 1;
}

CMD:blocked(playerid, params[])
{
    if (PlayerBlockedCount[playerid] == 0) return SendInfo(playerid, "Your block list is empty."), 1;
    SendInfo(playerid, "Blocked numbers (%d):", PlayerBlockedCount[playerid]);
    for (new i = 0; i < PlayerBlockedCount[playerid]; i++)
    {
        SendInfo(playerid, "- %d", PlayerBlockedNumbers[playerid][i]);
    }
    return 1;
}

CMD:setnumber(playerid, params[])
{
    new arg[16];
    if (sscanf(params, "s[16]", arg))
    {
        SendInfo(playerid, "Usage: /setnumber <6-9 digits>");
        return 1;
    }

    if (!IsNumeric(arg)) return SendError(playerid, "Number must be digits."), 1;

    new len = strlen(arg);
    if (len < 6 || len > 9) return SendError(playerid, "Number must be 6-9 digits."), 1;

    new newNum = strval(arg);
    if (FindOnlinePlayerByNumber(newNum) != INVALID_PLAYER_ID) return SendError(playerid, "This number is already taken (online)."), 1;

    new old = PlayerPhoneNumber[playerid];
    PlayerPhoneNumber[playerid] = newNum;
    SavePhoneData(playerid);
    SendSuccess(playerid, "Number changed: %d -> %d", old, newNum);
    return 1;
}

// -------------------------------
// Chat relay while in call (optional simple behavior)
// -------------------------------
public OnPlayerText(playerid, text[])
{
    if (PlayerCallState[playerid] == CALLSTATE_INCALL)
    {
        new peer = PlayerCallPeer[playerid];
        if (peer != INVALID_PLAYER_ID && IsPlayerConnected(peer))
        {
            new name[MAX_PLAYER_NAME];
            GetPlayerName(playerid, name, sizeof name);
            new line[200];
            format(line, sizeof line, "[CALL] %s: %s", name, text);
            SendClientMessage(peer, COLOR_CALL, line);
            // Hide original to avoid double-send
            return 0;
        }
    }
    return 1;
}
