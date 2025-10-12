// ===========================================
// Phone Admin Commands
// ===========================================

#include <a_samp>
#include <zcmd>

// Admin commands for phone management
CMD:givephone(playerid, params[])
{
    if(GetPlayerAdminLevel(playerid) < ADMIN_LEVEL_PHONE_MANAGE)
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: You don't have permission to use this command!");
        return 1;
    }
    
    new targetid, amount = 1;
    if(sscanf(params, "uD(1)", targetid, amount))
    {
        SendClientMessage(playerid, COLOR_PHONE_INFO, "USAGE: /givephone [playerid] [amount]");
        return 1;
    }
    
    if(!IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: Player not connected!");
        return 1;
    }
    
    if(PlayerPhoneOn[targetid])
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: Player already has a phone!");
        return 1;
    }
    
    PlayerPhoneOn[targetid] = 1;
    PlayerPhoneNumber[targetid] = PHONE_NUMBER_MIN + random(PHONE_NUMBER_MAX - PHONE_NUMBER_MIN);
    PlayerPhoneCredit[targetid] = PHONE_STARTING_CREDIT;
    
    new string[128];
    format(string, sizeof(string), "You gave %s a phone! Number: %d", GetPlayerNameEx(targetid), PlayerPhoneNumber[targetid]);
    SendClientMessage(playerid, COLOR_PHONE_SUCCESS, string);
    
    format(string, sizeof(string), "Admin %s gave you a phone! Your number is: %d", GetPlayerNameEx(playerid), PlayerPhoneNumber[targetid]);
    SendClientMessage(targetid, COLOR_PHONE_SUCCESS, string);
    
    SavePlayerPhoneData(targetid);
    return 1;
}

CMD:removephone(playerid, params[])
{
    if(GetPlayerAdminLevel(playerid) < ADMIN_LEVEL_PHONE_MANAGE)
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: You don't have permission to use this command!");
        return 1;
    }
    
    new targetid;
    if(sscanf(params, "u", targetid))
    {
        SendClientMessage(playerid, COLOR_PHONE_INFO, "USAGE: /removephone [playerid]");
        return 1;
    }
    
    if(!IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: Player not connected!");
        return 1;
    }
    
    if(!PlayerPhoneOn[targetid])
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: Player doesn't have a phone!");
        return 1;
    }
    
    // End any active calls
    if(PlayerPhoneState[targetid] == PHONE_STATE_IN_CALL || PlayerPhoneState[targetid] == PHONE_STATE_CALLING)
    {
        EndPhoneCall(targetid, 1);
    }
    
    PlayerPhoneOn[targetid] = 0;
    PlayerPhoneNumber[targetid] = 0;
    PlayerPhoneCredit[targetid] = 0;
    
    new string[128];
    format(string, sizeof(string), "You removed %s's phone!", GetPlayerNameEx(targetid));
    SendClientMessage(playerid, COLOR_PHONE_SUCCESS, string);
    
    format(string, sizeof(string), "Admin %s removed your phone!", GetPlayerNameEx(playerid));
    SendClientMessage(targetid, COLOR_PHONE_ERROR, string);
    
    SavePlayerPhoneData(targetid);
    return 1;
}

CMD:setphonecredit(playerid, params[])
{
    if(GetPlayerAdminLevel(playerid) < ADMIN_LEVEL_PHONE_MANAGE)
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: You don't have permission to use this command!");
        return 1;
    }
    
    new targetid, amount;
    if(sscanf(params, "ud", targetid, amount))
    {
        SendClientMessage(playerid, COLOR_PHONE_INFO, "USAGE: /setphonecredit [playerid] [amount]");
        return 1;
    }
    
    if(!IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: Player not connected!");
        return 1;
    }
    
    if(!PlayerPhoneOn[targetid])
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: Player doesn't have a phone!");
        return 1;
    }
    
    PlayerPhoneCredit[targetid] = amount;
    
    new string[128];
    format(string, sizeof(string), "You set %s's phone credit to $%d", GetPlayerNameEx(targetid), amount);
    SendClientMessage(playerid, COLOR_PHONE_SUCCESS, string);
    
    format(string, sizeof(string), "Admin %s set your phone credit to $%d", GetPlayerNameEx(playerid), amount);
    SendClientMessage(targetid, COLOR_PHONE_SUCCESS, string);
    
    SavePlayerPhoneData(targetid);
    return 1;
}

CMD:addphonecredit(playerid, params[])
{
    if(GetPlayerAdminLevel(playerid) < ADMIN_LEVEL_PHONE_MANAGE)
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: You don't have permission to use this command!");
        return 1;
    }
    
    new targetid, amount;
    if(sscanf(params, "ud", targetid, amount))
    {
        SendClientMessage(playerid, COLOR_PHONE_INFO, "USAGE: /addphonecredit [playerid] [amount]");
        return 1;
    }
    
    if(!IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: Player not connected!");
        return 1;
    }
    
    if(!PlayerPhoneOn[targetid])
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: Player doesn't have a phone!");
        return 1;
    }
    
    PlayerPhoneCredit[targetid] += amount;
    
    new string[128];
    format(string, sizeof(string), "You added $%d to %s's phone credit! New balance: $%d", amount, GetPlayerNameEx(targetid), PlayerPhoneCredit[targetid]);
    SendClientMessage(playerid, COLOR_PHONE_SUCCESS, string);
    
    format(string, sizeof(string), "Admin %s added $%d to your phone credit! New balance: $%d", GetPlayerNameEx(playerid), amount, PlayerPhoneCredit[targetid]);
    SendClientMessage(targetid, COLOR_PHONE_SUCCESS, string);
    
    SavePlayerPhoneData(targetid);
    return 1;
}

CMD:resetphone(playerid, params[])
{
    if(GetPlayerAdminLevel(playerid) < ADMIN_LEVEL_PHONE_RESET)
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: You don't have permission to use this command!");
        return 1;
    }
    
    new targetid;
    if(sscanf(params, "u", targetid))
    {
        SendClientMessage(playerid, COLOR_PHONE_INFO, "USAGE: /resetphone [playerid]");
        return 1;
    }
    
    if(!IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: Player not connected!");
        return 1;
    }
    
    // End any active calls
    if(PlayerPhoneState[targetid] == PHONE_STATE_IN_CALL || PlayerPhoneState[targetid] == PHONE_STATE_CALLING)
    {
        EndPhoneCall(targetid, 1);
    }
    
    // Reset all phone data
    PlayerPhoneOn[targetid] = 0;
    PlayerPhoneNumber[targetid] = 0;
    PlayerPhoneCredit[targetid] = 0;
    PlayerPhoneState[targetid] = PHONE_STATE_IDLE;
    PlayerInCallWith[targetid] = INVALID_PLAYER_ID;
    PlayerCallStartTime[targetid] = 0;
    ContactCount[targetid] = 0;
    MessageCount[targetid] = 0;
    CallHistoryCount[targetid] = 0;
    
    new string[128];
    format(string, sizeof(string), "You reset %s's phone data!", GetPlayerNameEx(targetid));
    SendClientMessage(playerid, COLOR_PHONE_SUCCESS, string);
    
    format(string, sizeof(string), "Admin %s reset your phone data!", GetPlayerNameEx(playerid));
    SendClientMessage(targetid, COLOR_PHONE_ERROR, string);
    
    SavePlayerPhoneData(targetid);
    return 1;
}

CMD:phoneinfo(playerid, params[])
{
    if(GetPlayerAdminLevel(playerid) < ADMIN_LEVEL_PHONE_MANAGE)
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: You don't have permission to use this command!");
        return 1;
    }
    
    new targetid;
    if(sscanf(params, "u", targetid))
    {
        SendClientMessage(playerid, COLOR_PHONE_INFO, "USAGE: /phoneinfo [playerid]");
        return 1;
    }
    
    if(!IsPlayerConnected(targetid))
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: Player not connected!");
        return 1;
    }
    
    new string[256];
    format(string, sizeof(string), "Phone Info for %s:\nHas Phone: %s\nPhone Number: %d\nCredit: $%d\nState: %d\nIn Call With: %d",
           GetPlayerNameEx(targetid),
           PlayerPhoneOn[targetid] ? "Yes" : "No",
           PlayerPhoneNumber[targetid],
           PlayerPhoneCredit[targetid],
           PlayerPhoneState[targetid],
           PlayerInCallWith[targetid]);
    
    ShowPlayerDialog(playerid, 2000, DIALOG_STYLE_MSGBOX, "Phone Information", string, "OK", "");
    return 1;
}

CMD:phoneadmin(playerid, params[])
{
    if(GetPlayerAdminLevel(playerid) < ADMIN_LEVEL_PHONE_MANAGE)
    {
        SendClientMessage(playerid, COLOR_PHONE_ERROR, "ERROR: You don't have permission to use this command!");
        return 1;
    }
    
    new string[512];
    strcat(string, "Phone Admin Commands:\n", sizeof(string));
    strcat(string, "/givephone [playerid] [amount] - Give phone to player\n", sizeof(string));
    strcat(string, "/removephone [playerid] - Remove player's phone\n", sizeof(string));
    strcat(string, "/setphonecredit [playerid] [amount] - Set phone credit\n", sizeof(string));
    strcat(string, "/addphonecredit [playerid] [amount] - Add phone credit\n", sizeof(string));
    strcat(string, "/resetphone [playerid] - Reset phone data\n", sizeof(string));
    strcat(string, "/phoneinfo [playerid] - Show phone information\n", sizeof(string));
    
    ShowPlayerDialog(playerid, 2001, DIALOG_STYLE_MSGBOX, "Phone Admin Commands", string, "OK", "");
    return 1;
}

// Helper function to get admin level (implement this in your admin system)
GetPlayerAdminLevel(playerid)
{
    // This is a placeholder - implement based on your admin system
    // Return 0 for non-admin, 1 for level 1 admin, 2 for level 2 admin, etc.
    return GetPlayerAdminLevel(playerid); // Replace with your admin system
}