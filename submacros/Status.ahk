/************************************************************************
 * @description Status.ahk for Natro Macro
 * @author Natro Team
 * @date 2025/04/07
 * @version 0.0.1
 * @copyright
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
 ***********************************************************************/

#NoTrayIcon
#SingleInstance Force
#MaxThreads 255
#Warn VarUnset, Off

#include %A_ScriptDir%\..\lib
#include Gdip_All.ahk
#include JSON.ahk
#include DurationFromSeconds.ahk
#include Roblox.ahk
#Include DISCORD.ahk
#include AttachmentBuilder.ahk
#include EmbedBuilder.ahk
#include FormData.ahk
#include Routes.ahk
#include SlashCommandBuilder.ahk

(commands := Map()).CaseSense := false
#include commands.ahk

bot := Discord(Intents.GUILDS | Intents.GUILD_MESSAGES | Intents.MESSAGE_CONTENT, {
    onReady: ready_handler,
    onDispatch: dispatch_handler
}, "MTA2OTYzNzk3ODExNDI0MDYxMg.GMs5R6.Yo3YyYrbmyQ6sRzC_CJQESo5xc3tOkOyb_05Eg")
dispatch_handler(self, event, data) {

}
ready_handler(self, data) {
    self.application_id := data["application"]["id"]
    command_str := '[', count := 0
    for name, command in commands {
        if !command.HasProp("command") {
            continue
        }
        if (command.command.HasProp("name") && command.command.HasProp("description")) {
            if StrLen(command.command.name) > 32 {
                throw TypeError("Command name is too long")
            }
            if StrLen(command.command.description) > 100 {
                throw TypeError("Command description is too long")
            }
            if command.command.options.Length > 25 {
                throw TypeError("Command has too many options")
            }
            cmd := command.command.to_string()
            command_str .= cmd . ","
            count++
        }
    }
    command_str := SubStr(command_str, 1, -1) . ']'
    return self.rest.put(Routes.applicationCommands(self.application_id), {
        body: A_Clipboard := command_str,
        async: true
    })
}