# Sindarin
Instanciate a UI-less debugger on your execution, allowing you to manipulate and inspect it via scripting.
The API is on the `SindarinDebugger` class.

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
*This baseline will load [NewTools](https://github.com/pharo-spec/NewTools)*
```Smalltalk
Metacello new
    baseline: 'Sindarin';
    repository: 'github://dupriezt/ScriptableDebugger';
    load.
```
