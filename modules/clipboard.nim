import winim, strutils
proc get_clipboard*(): string =
  defer: discard CloseClipboard()
  if OpenClipboard(0):
    let data = GetClipboardData(1)
    if data != 0:
      let text = cast[cstring](GlobalLock(data))
      discard GlobalUnlock(data)
      if text != NULL:
        var sanitized_text = ($text).replace("\c", "")
        return sanitized_text