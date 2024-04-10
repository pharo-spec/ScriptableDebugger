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

### Jump to caret VS skip command usage

[See here](./jump-to-caret.md)

## Install

### For Pharo 12 or +

```Smalltalk
Metacello new
    baseline: 'Sindarin';
    repository: 'github://pharo-spec/ScriptableDebugger';
    load.
```

### For Pharo 11 or -

```Smalltalk
Metacello new
    baseline: 'Sindarin';
    repository: 'github://pharo-spec/ScriptableDebugger:Pharo-11';
    load.
```
