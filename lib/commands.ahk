commands["help"] := {
    command: SlashCommandBuilder()
        .set_name("help")
        .set_description("Get help with Natro Macro Remote Control")
        .add_string_option(
            option => option
                .set_name("command")
                .set_description("The command to get help with")
                .set_required(false)
                .add_choices({
                    name: "advanced",
                    value: "advanced"
                }, {
                    name: "priority",
                    value: "priority"
                }, {
                    name: "settings",
                    value: "settings"
                }
                )
        ),
    help: 'Displays help information for Natro Macro Remote Control. You can specify a command to get help with, or leave it blank to get general help information.',
    example: '/help command:Settings'
}
commands["screenshot"] := {
    command: SlashCommandBuilder()
        .set_name("screenshot")
        .set_description("Take a screenshot of the current screen")
        .add_boolean_option(
            option => option
                .set_name("only_roblox")
                .set_description("Take a screenshot of only the Roblox window")
                .set_required(false)
        ),
    help: 'Takes a screenshot of the current screen or the Roblox window. You can specify whether to take a screenshot of only the Roblox window or not.',
    example: '/screenshot only_roblox:true'
}
commands["stop"] := {
    command: SlashCommandBuilder()
        .set_name("stop")
        .set_description("Stop the current macro"),
    help: 'Stops the currently running macro. If no macro is running, it will reload the macro.',
    example: '/stop'
}
commands["pause"] := {
    command: SlashCommandBuilder()
        .set_name("pause")
        .set_description("Pause the current macro"),
    help: 'Pauses/resumes the macro.',
    example: '/pause'
}
commands["start"] := {
    command: SlashCommandBuilder()
        .set_name("start")
        .set_description("Start the macro"),
    help: 'Starts the macro',
    example: '/start'
}
commands["close"] := {
    command: SlashCommandBuilder()
        .set_name("close")
        .set_description("Close a window")
        .add_string_option(
            option => option
                .set_name("window")
                .set_description("The window to close")
                .set_required(true)
        ),
    help: 'Closes the specified window. You can specify the window to close.',
    example: '/close window:Roblox'
}
commands["activate"] := {
    command: SlashCommandBuilder()
        .set_name("activate")
        .set_description("Activate a window")
        .add_string_option(
            option => option
                .set_name("window")
                .set_description("The window to activate")
                .set_required(true)
        ),
    help: 'Activates the specified window. You can specify the window to activate.',
    example: '/activate window:Roblox'
}
commands["minimize"] := {
    command: SlashCommandBuilder()
        .set_name("minimize")
        .set_description("Minimize a window")
        .add_string_option(
            option => option
                .set_name("window")
                .set_description("The window to minimize")
                .set_required(true)
        ),
    help: 'Minimizes the specified window. You can specify the window to minimize.',
    example: '/minimize window:Roblox'
}
commands["rejoin"] := {
    command: SlashCommandBuilder()
        .set_name("rejoin")
        .set_description("Rejoin the game")
        .add_integer_option(
            option => option
                .set_name("delay")
                .set_description("The delay before rejoining the game")
                .set_required(false)
        ),
    help: 'Rejoins the game. You can specify a delay before rejoining the game.',
    example: '/rejoin delay:5'
}
commands["logs"] := {
    command: SlashCommandBuilder()
        .set_name("logs")
        .set_description("Get the logs"),
    help: 'Gets the logs of the macro.',
    example: '/logs'
}
commands["keep"] := {
    command: SlashCommandBuilder()
        .set_name("keep")
        .set_description("Keeps an old amulet if prompt is shown")
}
commands["replace"] := {
    command: SlashCommandBuilder()
        .set_name("replace")
        .set_description("Replaces an amulet if prompt is shown")
}
commands["planter"] := {
    command: SlashCommandBuilder()
        .set_name("planter")
        .set_description("Interact with the planters")
        .add_subcommand(command =>
            command
                .set_name("harvest")
                .set_description("Harvest a planter")
                .add_integer_option(
                    option => option
                        .set_name("planter")
                        .set_description("The planter to harvest")
                        .add_choices(
                            {
                                name: 1,
                                value: 1
                            },
                            {
                                name: 2,
                                value: 2
                            },
                            {
                                name: 3,
                                value: 3
                            }
                        )
                        .set_required(true)
                )
        )
        .add_subcommand(command =>
            command
                .set_name("smoking")
                .set_description("Set a planter to smoking")
                .add_integer_option(
                    option => option
                        .set_name("planter")
                        .set_description("The planter to set to smoking")
                        .add_choices(
                            {
                                name: 1,
                                value: 1
                            },
                            {
                                name: 2,
                                value: 2
                            },
                            {
                                name: 3,
                                value: 3
                            }
                        )
                        .set_required(true)
                )    
        )
        .add_subcommand(command =>
            command
                .set_name("add")
                .set_description("Add time to a planter")
                .add_integer_option(
                    option => option
                        .set_name("planter")
                        .set_description("The planter to add time to")
                        .add_choices(
                            {
                                name: 1,
                                value: 1
                            },
                            {
                                name: 2,
                                value: 2
                            },
                            {
                                name: 3,
                                value: 3
                            }
                        )
                        .set_required(true)
                )
                .add_string_option(
                    option => option
                        .set_name("time")
                        .set_description("this time in HH:MM:SS format. Needs to be below 24 hours")
                        .set_required(true)
                )
        )
        .add_subcommand(command =>
            command
                .set_name("subtract")
                .set_description("Subtract time from a planter")
                .add_integer_option(
                    option => option
                        .set_name("planter")
                        .set_description("The planter to subtract time from")
                        .add_choices(
                            {
                                name: 1,
                                value: 1
                            },
                            {
                                name: 2,
                                value: 2
                            },
                            {
                                name: 3,
                                value: 3
                            }
                        )
                        .set_required(true)
                )
                .add_string_option(
                    option => option
                        .set_name("time")
                        .set_description("this time in HH:MM:SS format. Needs to be below 24 hours")
                        .set_required(true)
                )
        )
        .add_subcommand(command =>
            command
                .set_name("clear")
                .set_description("Clear a planter")
                .add_integer_option(
                    option => option
                        .set_name("planter")
                        .set_description("The planter to clear")
                        .add_choices(
                            {
                                name: 1,
                                value: 1
                            },
                            {
                                name: 2,
                                value: 2
                            },
                            {
                                name: 3,
                                value: 3
                            }
                        )
                        .set_required(true)
                )
        )
        .add_subcommand(command =>
            command
                .set_name("screenshot")
                .set_description("Take a screenshot of the planter")
                .add_integer_option(
                    option => option
                        .set_name("planter")
                        .set_description("The planter to take a screenshot of")
                        .add_choices(
                            {
                                name: 1,
                                value: 1
                            },
                            {
                                name: 2,
                                value: 2
                            },
                            {
                                name: 3,
                                value: 3
                            }
                        )
                        .set_required(true)
                )
        )
        .add_subcommand(command =>
            command
                .set_name("view")
                .set_description("View the planters")
        )
}
;TODO: Implement timers command
commands["timers"] := {

}
;TODO: Implement settings command
commands["settings"] := {

}
commands["send"] := {
    command: SlashCommandBuilder()
        .set_name("send")
        .set_description("Send a message to the specified channel")
        .add_string_option(
            option => option
                .set_name("keys")
                .set_description("The keys to send (see ahk docs)")
                .set_required(true)
        )
}
commands["upload"] := {
    command: SlashCommandBuilder()
        .set_name("upload")
        .set_description("Upload a file to the specified channel")
        .add_string_option(
            option => option
                .set_name("file")
                .set_description("The file to upload")
                .set_required(true)
        )
}
commands["download"] := {
    command: SlashCommandBuilder()
        .set_name("download")
        .set_description("Download a file from the specified channel")
        .add_attachment_option(
            option => option
                .set_name("file")
                .set_description("The file to download")
                .set_required(true)
        )
        .add_string_option(
            option => option
                .set_name("path")
                .set_description("The path to save the file to")
                .set_required(true)
        )
}
commands["click"] := {
    command: SlashCommandBuilder()
        .set_name("click")
        .set_description("Click at the specified coordinates")
        .add_integer_option(
            option => option
                .set_name("x")
                .set_description("The x coordinate to click at")
                .set_required(true)
        )
        .add_integer_option(
            option => option
                .set_name("y")
                .set_description("The y coordinate to click at")
                .set_required(true)
        )
        .add_string_option(
            option => option
                .set_name("mode")
                .set_description("The CoordMode to use")
                .set_required(false)
                .add_choices(
                    {
                        name: "Screen",
                        value: "Screen"
                    },
                    {
                        name: "Client",
                        value: "Client"
                    },
                    {
                        name: "Window",
                        value: "Window"
                    },
                    {
                        name: "Relative",
                        value: "Relative"
                    }
                )
        )
        .add_string_option(
            option => option
                .set_name("button")
                .set_description("The mouse button to click with")
                .set_required(false)
                .add_choices(
                    {
                        name: "Left",
                        value: "Left"
                    },
                    {
                        name: "Right",
                        value: "Right"
                    },
                    {
                        name: "Middle",
                        value: "Middle"
                    },
                    {
                        name: "X1",
                        value: "X1"
                    },
                    {
                        name: "X2",
                        value: "X2"
                    },
                    {
                        name: "WheelUp",
                        value: "WheelUp"
                    },
                    {
                        name: "WheelDown",
                        value: "WheelDown"
                    }
                )
        )
        .add_integer_option(
            option => option
                .set_name("amount")
                .set_description("The amount of clicks to perform")
                .set_required(false)
        )
}
commands["shiftlock"] := {
    command: SlashCommandBuilder()
        .set_name("shiftlock")
        .set_description("Toggle shiftlock on or off")
        .add_boolean_option(
            option => option
                .set_name("state")
                .set_description("The state to set shiftlock to")
                .set_required(true)
        )
}
commands["restart"] := {
    command: SlashCommandBuilder()
        .set_name("restart")
        .set_description("Restart the system")
}
commands["shrine"] := {
    command: SlashCommandBuilder()
        .set_name("shrine")
        .set_description("Interact with the shrine")
        .add_subcommand(command =>
            command
                .set_name("ready")
                .set_description("Set the shrine to ready")
                .add_integer_option(
                    option => option
                        .set_name("slot")
                        .set_description("The slot to set the shrine to ready in")
                        .add_choices(
                            {
                                name: 1,
                                value: 1
                            },
                            {
                                name: 2,
                                value: 2
                            },
                            {
                                name: 3,
                                value: 3
                            }
                        )
                )
        )
        .add_subcommand(command =>
            command
                .set_name("clear")
                .set_description("Clear the shrine")
                .add_integer_option(
                    option => option
                        .set_name("slot")
                        .set_description("The slot to clear the shrine in")
                        .add_choices(
                            {
                                name: 1,
                                value: 1
                            },
                            {
                                name: 2,
                                value: 2
                            },
                            {
                                name: 3,
                                value: 3
                            }
                        )
                )
        )
        .add_subcommand(command =>
            command
                .set_name("view")
                .set_description("View the shrine status")
        )
}
commands["blender"] := {
    command: SlashCommandBuilder()
        .set_name("blender")
        .set_description("Interact with the blender")
        .add_subcommand(command =>
            command
                .set_name("ready")
                .set_description("Set the blender to ready")
                .add_integer_option(
                    option => option
                        .set_name("slot")
                        .set_description("The slot to set the blender to ready in")
                        .add_choices(
                            {
                                name: 1,
                                value: 1
                            },
                            {
                                name: 2,
                                value: 2
                            },
                            {
                                name: 3,
                                value: 3
                            }
                        )
                )
        )
        .add_subcommand(command =>
            command
                .set_name("clear")
                .set_description("Clear the blender")
                .add_integer_option(
                    option => option
                        .set_name("slot")
                        .set_description("The slot to clear the blender in")
                        .add_choices(
                            {
                                name: 1,
                                value: 1
                            },
                            {
                                name: 2,
                                value: 2
                            },
                            {
                                name: 3,
                                value: 3
                            }
                        )
                )
        )
        .add_subcommand(command =>
            command
                .set_name("view")
                .set_description("View the blender status")
        )
}
;TODO: Implement memorymatch command
commands["memorymatch"] := {

}
commands["finditem"] := {
    command: SlashCommandBuilder()
        .set_name("finditem")
        .set_description("Find an item in the inventory")
        .add_string_option(
            option => option
                .set_name("item")
                .set_description("The item to find")
                .set_required(true)
        )
}