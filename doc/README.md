# Sindarin
Instanciate a UI-less debugger on your execution, allowing you to manipulate and inspect it via scripting.
The API is on the `SindarinDebugger` class.

- Original author: **Thomas Dupriez** (dupriezt on github)
- Research paper: [Sindarin: A Versatile Scripting API for the Pharo Debugger](https://hal.archives-ouvertes.fr/hal-02280915)

## Usage

```Smalltalk
dbg := SindarinDebugger debug: [<your code>].
"Manipulate and inspect the debugged execution by sending messages to dbg"
dbg step; stepOver.
dbg context inspect.
dbg currentNode inspect.
...
```

## Install
```Smalltalk
Metacello new
    baseline: 'Sindarin';
    repository: 'github://dupriezt/ScriptableDebugger';
    load.
```
