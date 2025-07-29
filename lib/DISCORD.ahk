#Include %A_LineFile%\..\WebSocket.ahk
#include %A_LineFile%\..\FormData.ahk
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
        sender(input) {
            if (input is String || input is ComObjArray)
                return input
            return JSON.stringify(input)
        }
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
            whr.Send(has(requestobj, "body") ? sender(getter(requestobj, "body")) : "")
            return async ? whr : whr.ResponseText
        }
        POST(self, url, requestobj) {
            getter := Type(requestobj) = "Map" ? Map.Prototype.Get : (obj, key) => obj.%key%
            has := Type(requestobj) = "Map" ? Map.Prototype.Has : (obj, key) => obj.HasProp(key)
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("POST", self.base_url . url, async := has(requestobj, "async") ? !!getter(requestobj, "async") : false)
            if has(requestobj, "headers") {
                for key, value in getter(requestobj, "headers") is Map ? getter(requestobj, "headers") : getter(requestobj, "headers").OwnProps() {
                    whr.SetRequestHeader(key, value)
                }
            }
            whr.SetRequestHeader("Authorization", "Bot " self.token)
            whr.SetRequestHeader("User-Agent", "Ninju's Discord Library (ahk v2)")
            if !has(requestobj, "headers") || !has(getter(requestobj, "headers"), "Content-Type")
                whr.SetRequestHeader("Content-Type", "application/json")
            whr.Send(has(requestobj, "body") ? sender(getter(requestobj, "body")) : "")
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
            whr.Send(has(requestobj, "body") ? sender(getter(requestobj, "body")) : "")
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
            whr.Send(has(requestobj, "body") ? sender(getter(requestobj, "body")) : "")
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
            whr.Send(has(requestobj, "body") ? sender(getter(requestobj, "body")) : "")
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
        data := JSON.parse(msg,, false)
        (data.HasProp("s") && data.s && this.s := data.s)
        switch data.op {
            case 10: ; HELLO
                heartbeatinterval := data.d.heartbeat_interval
                SetTimer(s := this.__heartbeat.Bind(this), heartbeatinterval)
                this.DefineProp("__Delete", {
                    Call: this => SetTimer(s, 0)
                })
            case 11: ; HEARTBEAT ACK
                DllCall("GetSystemTimeAsFileTime", "int64*", &time := 0)
                this.ping := Round((time - this.__last_sent) / 10000) ; 100ns to ms
            case 0: ; DISPATCH
                if data.t = "READY" {
                    this.user := data.d.user
                    this.guilds := data.d.guilds
                    this.session_id := data.d.session_id
                    this.application := data.d.application
                    this.resume_gateway_url := data.d.resume_gateway_url
                }
                if this.HasMethod("on" . data.t)
                    return this.%("on" . data.t)%.Call(this, data.d)
                if this.HasMethod("onDispatch")
                    return this.onDispatch.Call(this, data.t, data.d)
            default: msgbox "Unhandled opcode: " data.op "`n" msg
        }
    }
    __onclose(ws, status, reason) {
        try FileAppend("close`nreason: " reason "`n", "*")
        ws.reconnect()
    }
    Class Interaction {
        static Call(self, obj) {
            if !(self is Discord)
                throw TypeError("Expected a Discord but received a " Type(self))
            if !(obj is Object)
                throw TypeError("Expected an object but received a " Type(obj))
            for i, j in ["id", "type", "data", "channel_id"]
                if !obj.HasProp(j)
                    throw TypeError("Missing property " j)
            data := obj
            data.base := this.Prototype
            data.self := self
            data.reply := ObjBindMethod(this, "Reply")
            data.deferReply := ObjBindMethod(this, "DeferReply")
            data.EditReply := ObjBindMethod(this, "EditReply")
            data.delete := ObjBindMethod(this, "Delete")
            data.followUp := ObjBindMethod(this, "followUp")
            for i, j in Map("String", 3, "Integer", 4, "Boolean", 5, "User", 6, "Channel", 7, "Role", 8, "Mentionable", 9, "Number", 10, "Attachment", 11)
                data.get%i%option := ObjBindMethod(this, "getOption", j), data.getSub%i%option := ObjBindMethod(this, "getSubcommandOption", j)
            return data
        }
        static Reply(data, Message, ephemeral := false) {
            if !(data is Discord.Interaction)
                throw TypeError("Expected a Discord.Interaction but received a " Type(data))
            for i, j in ["id", "type", "data", "channel_id"]
                if !data.HasProp(j)
                    throw TypeError("Missing property " j)
            rest := data.self.rest
            if ephemeral
                Message.flags := 64
            if message.HasProp("embeds") {
                for i, embed in Message.embeds
                    if embed is EmbedBuilder
                        Message.embeds[i] := embed.to_json()
            }
            if !Message.hasProp("files") || !message.files.length
                return rest.POST(Routes.interactionCallback(data.id, data.token), {body:A_Clipboard:=JSON.stringify({ type: 4, data: Message })})
            fd := FormData()
            files := Message.files
            Message.DeleteProp("files")
            fd.append("payload_json", s := JSON.stringify({ type: 4, data: Message }), StrLen(s), "application/json")
            for i, j in files
                fd.append("files[" i - 1 "]", j.ptr, j.size, j.contentType, j.filename)
            return rest.POST("/interactions/" data.id "/" data.token "/callback", {
                body: fd.data,
                headers: { %"Content-Type"%: fd.contentType }
            })
        }
        static DeferReply(self, data?) {
            if !(self is Discord.Interaction)
                throw TypeError("Expected a Discord.Interaction but received a " Type(self))
            for i, j in ["id", "type", "data", "channel_id"]
                if !self.HasProp(j)
                    throw TypeError("Missing property " j)
            rest := self.self.rest
            reqData := { type: 5 }
            if data
                reqData.data := data
            return rest("POST", "/interactions/" self.id "/" self.token "/callback", {body:JSON.stringify(reqData)})
        }
        static EditReply(data, Message) {
            if !(data is Discord.Interaction)
                throw TypeError("Expected a Interaction but received a " Type(data))
            for i, j in ["id", "type", "data", "channel_id"]
                if !data.HasProp(j)
                    throw TypeError("Missing property " j)
            rest := data.self.rest
            if message.HasProp("embeds") {
                for i, embed in Message.embeds
                    if embed is EmbedBuilder
                        Message.embeds[i] := embed.to_json()
            }
            if !Message.hasProp("files") || !Message.files.length
                return rest.PATCH(Routes.webhookMessage(data.self.user.id, data.token), {body:JSON.stringify(Message)})
            fd := FormData()
            files := Message.files
            Message.DeleteProp("files")
            fd.append("payload_json", s := JSON.stringify(Message), StrLen(s), "application/json")
            for i, j in files
                fd.append("files[" i - 1 "]", j.ptr, j.size, j.contentType, j.filename)
            return rest.PATCH("/webhooks/" data.self.user.id "/" data.token "/messages/@original", {body:fd.data, headers: { %"Content-Type"%: fd.contentType }})
        }
        static getOption(optionType, self, option) {
            for i, j in self.data.options
                if j.type = optionType && j.name = option
                    return Discord.Result(j.value)
            return Discord.Result()
        }
        static getSubcommandOption(optionType, self, subcommand, option) {
            for i, j in self.data.options
                if j.type = 1 && j.name = subcommand
                    for k, l in j.options
                        if l.type = optionType && l.name = option
                            return l.value
        }
        static Delete(data) {
            if !(data is Discord.Interaction)
                throw TypeError("Expected a Discord.Interaction but received a " Type(data))
            rest := data.self.rest
            return rest.DELETE("/webhooks/" data.self.user.id "/" data.token "/messages/@original")
        }
        static followUp(data, Message) {
            if !(data is Discord.Interaction)
                throw TypeError("Expected a Discord.Interaction but received a " Type(data))
            for i, j in ["id", "type", "data", "channel_id"]
                if !data.HasProp(j)
                    throw TypeError("Missing property " j)
            rest := data.self.rest
            if message.HasProp("embeds") {
                for i, embed in Message.embeds
                    if embed is EmbedBuilder
                        Message.embeds[i] := embed.to_json()
            }
            if !Message.hasProp("files") || !Message.files.length
                return rest("POST", "/webhooks/" data.self.user.id "/" data.token, JSON.stringify(Message.obj), { %"Content-Type"%: "application/json" })
            fd := FormData()
            files := Message.files
            Message.DeleteProp("files")
            fd.append("payload_json", s := JSON.stringify(Message.obj), StrLen(s), "application/json")
            for i, j in files
                fd.append("files[" i - 1 "]", j.ptr, j.size, j.contentType, j.filename)
            return rest("POST", "/webhooks/" data.self.user.id "/" data.token, fd.data, { %"Content-Type"%: fd.contentType })
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
    class Result {
        __New(success?) {
            this.success := IsSet(success)
            this.successValue := success ?? ''
        }
        unwrap_or(default) {
            if this.success
                return this.successValue
            return default
        }
        unwrap() {
            if this.success
                return this.successValue
            throw Error("Unwrap failed: Result is not successful")
        }
    }
}