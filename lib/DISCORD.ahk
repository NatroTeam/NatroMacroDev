#Include %A_LineFile%\..\WebSocket.ahk
class Discord {
    ws := 0, __last_sent := 0, ping := 0, s := "null"
    __New(intents, eventObj, token) {
        this.ws := WebSocket("wss://gateway.discord.gg/?v=10&encoding=json", {
            message: this.__onmsg.bind(this),
            close: this.__onclose.bind(this),
        })
        _rest_prototype := {
            __Class: "Discord.REST",
            GET: GET,
            POST: POST,
            PUT: PUT,
            PATCH: PATCH,
            DELETE: DELETE,
            token: "",
            base_url: "https://discord.com/api/v10",
        }
        this.REST := {
            base: _rest_prototype,
            token: token
        }

        for key, value in eventObj.OwnProps() {
            if SubStr(key, 1, 2) = "on" {
                this.%key% := value
            }
        }

        identify()


        ; REST Object:
        GET(self, url, requestobj) {
            getter := Type(requestobj) = "Map" ? Map.Prototype.Get : (obj, key) => obj.%key%
            has := Type(requestobj) = "Map" ? Map.Prototype.Has : (obj, key) => obj.HasProp(key)

            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("GET", self.base_url . url, async := has(requestobj, "async") ? getter(requestobj, "async") : false)
            if has(requestobj, "headers") {
                for key, value in getter(requestobj, "headers") is Map ? getter(requestobj, "headers") : getter(requestobj, "headers").OwnProps() {
                    whr.SetRequestHeader(key, value)
                }
            }
            whr.SetRequestHeader("Authorization", "Bot " self.token)
            whr.SetRequestHeader("User-Agent", "Ninju's Discord Library (ahk v2)")
            whr.Send(has(requestobj, "body") ? getter(requestobj, "body") : "")
            return async ? whr : whr.ResponseText
        }
        POST(self, url, requestobj) {
            getter := Type(requestobj) = "Map" ? Map.Prototype.Get : (obj, key) => obj.%key%
            has := Type(requestobj) = "Map" ? Map.Prototype.Has : (obj, key) => obj.HasProp(key)
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("POST", this.base_url . url, async := has(requestobj, "async") ? getter(requestobj, "async") : false)
            if has(requestobj, "headers") {
                for key, value in getter(requestobj, "headers") is Map ? getter(requestobj, "headers") : getter(requestobj, "headers").OwnProps() {
                    whr.SetRequestHeader(key, value)
                }
            }
            whr.SetRequestHeader("Authorization", "Bot " self.token)
            whr.SetRequestHeader("User-Agent", "Ninju's Discord Library (ahk v2)")
            if !has(requestobj, "headers") || !has(getter(requestobj, "headers"), "Content-Type")
                whr.SetRequestHeader("Content-Type", "application/json")
            whr.Send(has(requestobj, "body") ? getter(requestobj, "body") : "")
            return async ? whr : whr.ResponseText
        }
        PUT(self, url, requestobj) {
            getter := Type(requestobj) = "Map" ? Map.Prototype.Get : (obj, key) => obj.%key%
            has := Type(requestobj) = "Map" ? Map.Prototype.Has : (obj, key) => obj.HasProp(key)
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("PUT", self.base_url . url, async := has(requestobj, "async") ? getter(requestobj, "async") : false)
            if has(requestobj, "headers") {
                for key, value in getter(requestobj, "headers") is Map ? getter(requestobj, "headers") : getter(requestobj, "headers").OwnProps() {
                    whr.SetRequestHeader(key, value)
                }
            }
            whr.SetRequestHeader("Authorization", "Bot " self.token)
            whr.SetRequestHeader("User-Agent", "Ninju's Discord Library (ahk v2)")
            if !has(requestobj, "headers") || !has(getter(requestobj, "headers"), "Content-Type")
                whr.SetRequestHeader("Content-Type", "application/json")
            whr.Send(has(requestobj, "body") ? getter(requestobj, "body") : "")
            return async ? whr : whr.ResponseText
        }
        PATCH(self, url, requestobj) {
            getter := Type(requestobj) = "Map" ? Map.Prototype.Get : (obj, key) => obj.%key%
            has := Type(requestobj) = "Map" ? Map.Prototype.Has : (obj, key) => obj.HasProp(key)
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("PATCH", self.base_url . url, async := has(requestobj, "async") ? getter(requestobj, "async") : false)
            if has(requestobj, "headers") {
                for key, value in getter(requestobj, "headers") is Map ? getter(requestobj, "headers") : getter(requestobj, "headers").OwnProps() {
                    whr.SetRequestHeader(key, value)
                }
            }
            whr.SetRequestHeader("Authorization", "Bot " self.token)
            whr.SetRequestHeader("User-Agent", "Ninju's Discord Library (ahk v2)")
            if !has(requestobj, "headers") || !has(getter(requestobj, "headers"), "Content-Type")
                whr.SetRequestHeader("Content-Type", "application/json")
            whr.Send(has(requestobj, "body") ? getter(requestobj, "body") : "")
            return async ? whr : whr.ResponseText
        }
        DELETE(self, url, requestobj) {
            getter := Type(requestobj) = "Map" ? Map.Prototype.Get : (obj, key) => obj.%key%
            has := Type(requestobj) = "Map" ? Map.Prototype.Has : (obj, key) => obj.HasProp(key)
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("DELETE", self.base_url . url, async := has(requestobj, "async") ? getter(requestobj, "async") : false)
            if has(requestobj, "headers") {
                for key, value in getter(requestobj, "headers") is Map ? getter(requestobj, "headers") : getter(requestobj, "headers").OwnProps() {
                    whr.SetRequestHeader(key, value)
                }
            }
            whr.SetRequestHeader("Authorization", "Bot " self.token)
            whr.SetRequestHeader("User-Agent", "Ninju's Discord Library (ahk v2)")
            if !has(requestobj, "headers") || !has(getter(requestobj, "headers"), "Content-Type")
                whr.SetRequestHeader("Content-Type", "application/json")
            whr.Send(has(requestobj, "body") ? getter(requestobj, "body") : "")
            return async ? whr : whr.ResponseText
        }


        identify(*) {
            this.ws.sendText(
                '{"op":2,"d":{"token":"' token '","intents":' intents ',"properties":{"$os":"windows","$browser":"ninju`'s library","$device":"natro macro"},"presence":{"status":"online","activities":[{"name":"natro macro","type":0}],"since": null,"afk": false}}}'
            )
        }
    }
    __heartbeat(*) {
        this.ws.sendText('{"op":1,"d":' this.s '}')
        DllCall("GetSystemTimeAsFileTime", "int64*", &time := 0)
        this.__last_sent := time
    }
    __onmsg(ws, msg) {
        data := JSON.parse(msg)
        (data.Has("s") && data["s"] && this.s := data["s"])
        switch data["op"] {
            case 10: ; HELLO
                heartbeatinterval := data["d"]["heartbeat_interval"]
                SetTimer(s := this.__heartbeat.Bind(this), heartbeatinterval)
                this.DefineProp("__Delete", {
                    Call: this => SetTimer(s, 0)
                })
            case 11: ; HEARTBEAT ACK
                DllCall("GetSystemTimeAsFileTime", "int64*", &time := 0)
                this.ping := Round((time - this.__last_sent) / 10000) ; 100ns to ms
            case 0: ; DISPATCH
                if this.HasMethod("on" . data["t"])
                    return this.%"on" . data["t"]%.Call(this, data["d"])
                if this.HasMethod("onDispatch")
                    return this.onDispatch.Call(this, data["t"], data["d"])
            default: FileAppend(data["op"], "*")
        }
    }
    __onclose(ws, status, reason) {
        try FileAppend("close`nreason: " reason "`n", "*")
        ws.reconnect()
    }
}
Class Intents {
    static GUILDS := 1 << 0
    static GUILD_MEMBERS := 1 << 1
    static GUILD_MODERATION := 1 << 2
    static GUILD_EXPRESSIONS := 1 << 3
    static GUILD_INTEGRATIONS := 1 << 4
    static GUILD_WEBHOOKS := 1 << 5
    static GUILD_INVITES := 1 << 6
    static GUILD_VOICE_STATES := 1 << 7
    static GUILD_PRESENCES := 1 << 8
    static GUILD_MESSAGES := 1 << 9
    static GUILD_MESSAGE_REACTIONS := 1 << 10
    static GUILD_MESSAGE_TYPING := 1 << 11
    static DIRECT_MESSAGES := 1 << 12
    static DIRECT_MESSAGE_REACTIONS := 1 << 13
    static DIRECT_MESSAGE_TYPING := 1 << 14
    static MESSAGE_CONTENT := 1 << 15
    static GUILD_SCHEDULED_EVENTS := 1 << 16
    static AUTO_MODERATION_CONFIGURATION := 1 << 20
    static AUTO_MODERATION_EXECUTION := 1 << 21
    static GUILD_MESSAGE_POLLS := 1 << 22
    static DIRECT_MESSAGE_POLLS := 1 << 23
}