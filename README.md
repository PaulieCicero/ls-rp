# SA-MP Phone Script v1.0

A comprehensive phone system for SA-MP servers with calling, messaging, contacts, and more!

## Features

### 📞 Core Phone Features
- **Phone Purchase System** - Players can buy phones for $5,000
- **Phone Numbers** - Unique 7-digit phone numbers for each player
- **Credit System** - Pay-per-minute calling with credit management
- **Call Management** - Make calls, answer, hang up, call timeout
- **Call History** - Track missed, received, and dialed calls

### 📱 Messaging System
- **SMS Messaging** - Send text messages to other players
- **Message History** - Store and view received messages
- **Message Notifications** - Sound alerts for new messages

### 👥 Contact Management
- **Contact List** - Add, delete, and manage contacts
- **Quick Dial** - Call contacts directly from the contact list
- **Contact Storage** - Persistent contact storage in database

### 🎨 User Interface
- **Interactive Menus** - Easy-to-use dialog-based interface
- **Phone Animations** - Realistic phone animations during calls
- **Sound Effects** - Ring tones, message alerts, and call sounds
- **Visual Notifications** - On-screen call status and notifications

### 🛠️ Admin Features
- **Phone Management** - Give/remove phones from players
- **Credit Management** - Set and add phone credit
- **Phone Information** - View detailed phone data
- **Reset System** - Reset player phone data

## Installation

### Requirements
- SA-MP Server 0.3.7+
- MySQL Database
- Required includes:
  - `a_samp` (included with SA-MP)
  - `a_mysql` (MySQL plugin)
  - `zcmd` (command processor)
  - `sscanf2` (string parsing)
  - `foreach` (player iteration)

### Database Setup
1. Create a MySQL database named `samp_phone`
2. The script will automatically create the required tables:
   - `player_phones` - Stores player phone data
   - `phone_contacts` - Stores contact lists
   - `phone_messages` - Stores message history
   - `phone_calls` - Stores call history

### File Installation
1. Place `phone_script.pwn` in your `filterscripts` folder
2. Place `phone_animations.inc` and `phone_config.inc` in your `includes` folder
3. Place `phone_admin.pwn` in your `filterscripts` folder (optional)
4. Compile the scripts and add them to your `server.cfg`

### Server Configuration
Add these lines to your `server.cfg`:
```
filterscripts phone_script phone_admin
```

## Commands

### Player Commands
- `/phone` - Open phone main menu
- `/buyphone` - Purchase a phone ($5,000)
- `/call [number]` - Call a phone number
- `/answer` - Answer incoming call
- `/hangup` - Hang up current call
- `/contacts` - Open contacts menu
- `/addcontact [name] [number]` - Add contact
- `/messages` - Open messages menu
- `/sendmessage [number] [message]` - Send SMS
- `/callhistory` - View call history
- `/phonecredit` - Check phone credit
- `/addcredit [amount]` - Add credit to phone

### Admin Commands
- `/givephone [playerid] [amount]` - Give phone to player
- `/removephone [playerid]` - Remove player's phone
- `/setphonecredit [playerid] [amount]` - Set phone credit
- `/addphonecredit [playerid] [amount]` - Add phone credit
- `/resetphone [playerid]` - Reset phone data
- `/phoneinfo [playerid]` - Show phone information
- `/phoneadmin` - Show admin commands

## Configuration

Edit `phone_config.inc` to customize:
- Database settings
- Phone prices and costs
- Call timeouts and limits
- Sound effects and animations
- Feature toggles
- Admin levels

## Features in Detail

### Phone System
- Players start without a phone
- Purchase phones for $5,000
- Each phone gets a unique 7-digit number
- Credit system for call costs ($10/minute)
- Phone states: Idle, Calling, Ringing, In Call, Busy

### Calling System
- Call any player by phone number
- 30-second timeout if not answered
- Call duration tracking
- Automatic cost calculation
- Call history with duration and type

### Messaging System
- Send SMS to any phone number
- Message history storage
- Sound notifications for new messages
- Message expiry after 30 days

### Contact Management
- Add contacts with names and numbers
- Quick dial from contact list
- Persistent storage in database
- Up to 100 contacts per player

### Admin Tools
- Complete phone management
- Credit manipulation
- Phone data reset
- Detailed information display

## Database Schema

### player_phones
- `id` - Auto increment primary key
- `playerid` - Player ID
- `phonenumber` - Phone number
- `credit` - Available credit
- `hasphone` - Whether player has phone

### phone_contacts
- `id` - Auto increment primary key
- `playerid` - Player ID
- `contactname` - Contact name
- `contactnumber` - Contact phone number

### phone_messages
- `id` - Auto increment primary key
- `playerid` - Player ID
- `fromname` - Sender name
- `message` - Message text
- `timestamp` - Unix timestamp

### phone_calls
- `id` - Auto increment primary key
- `playerid` - Player ID
- `fromname` - Caller name
- `toname` - Receiver name
- `duration` - Call duration in seconds
- `type` - Call type (0=missed, 1=received, 2=dialed)
- `timestamp` - Unix timestamp

## Customization

### Adding New Features
1. Add new variables in the main script
2. Create new functions for functionality
3. Add commands using `CMD:` syntax
4. Update database schema if needed
5. Add admin commands if required

### Modifying Costs
Edit `phone_config.inc`:
```pawn
#define PHONE_PRICE 5000
#define CALL_COST_PER_MINUTE 10
#define MESSAGE_COST 1
```

### Adding Sound Effects
Modify sound IDs in `phone_config.inc`:
```pawn
#define SOUND_PHONE_RING 1085
#define SOUND_PHONE_MESSAGE 1084
#define SOUND_PHONE_CALL 1086
```

## Troubleshooting

### Common Issues
1. **MySQL Connection Failed**
   - Check database credentials in `phone_config.inc`
   - Ensure MySQL server is running
   - Verify database exists

2. **Commands Not Working**
   - Check if includes are properly installed
   - Verify script compilation
   - Check server console for errors

3. **Phone Not Saving**
   - Check MySQL connection
   - Verify database permissions
   - Check for SQL errors in console

### Debug Mode
Enable debug messages by adding:
```pawn
#define DEBUG_PHONE 1
```

## Support

For support and updates:
- Check the script comments for detailed explanations
- Review the database schema for data structure
- Test with a small group before full server deployment

## License

This script is provided as-is for educational and server use. Modify and distribute as needed for your server.

## Version History

- **v1.0** - Initial release with full phone system
  - Basic calling and messaging
  - Contact management
  - Admin tools
  - Database integration
  - Animations and sounds

---

**Enjoy your new phone system!** 📱