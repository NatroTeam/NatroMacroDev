class ModBuilder extends Map {
    changed_functions := []
    __New(name, version) {
        mods[name] := this
        this["name"] := name
        this["version"] := version
        this["config"] := Map()
    }
    change_function(target_function, new_function) {
        target_function.DefineProp("Call", {Call: (self, args*) => (new_function)(args*)})
        this.changed_functions.Push(target_function.name)
        return this
    }
    on(event, callback) {
        ((events.Has(event) && events[event] is Array) || (events[event] := []) && events[event].Push(callback))
        return this
    }
    add_setting(key, value) {
        this["config"][key] := value
        return this
    }
}
