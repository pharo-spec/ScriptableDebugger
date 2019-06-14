# ScriptableDebugger
Instanciate a UI-less debugger on your execution, allowing you to manipulate and inspect it via scripting.
The API is on the `ScriptableDebugger` class.

## Usage

```Smalltalk
dbg := ScriptableDebugger debug: [<your code>].
"Manipulate and inspect the debugged execution by sending messages to dbg"
dbg step; stepOver.
dbg context inspect.
dbg currentNode inspect.
...
```

## Install
```Smalltalk
Metacello new
    baseline: 'ScriptableDebugger';
    repository: 'github://dupriezt/ScriptableDebugger';
    load.
```
