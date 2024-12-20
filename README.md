# Sindarin
Sindarin is a versatile and interactive debugger scripting API
for object-oriented programming languages. Sindarin is designed to help building dedicated debugging tools targeting specific problems or domains. 
To do this, Sindarin attaches to a running process then exposes stepping and introspection operations to control, manipulate and observe that process’ execution. 
It simplifies the creation of personalized debugging scripts by providing an AST-based API, thus also proposing different stepping granularity over the debugging session. 
Once written, scripts are extensible and reusable on other scenario, and can be used to build more complex debugging tools.

**Research paper:** [Sindarin: A Versatile Scripting API for the Pharo Debugger](https://hal.archives-ouvertes.fr/hal-02280915)

### Main authors
- [Steven Costiou](https://github.com/StevenCostiou) (2019 - ...)
- [Adrien Vanègue](https://github.com/adri09070) (2022 - 2024)

### Original author
- [Thomas Dupriez](https://github.com/dupriezt) (2019 - 2021)

## Usage

Instanciate a UI-less debugger on your execution, allowing you to manipulate and inspect it via scripting.
The API is on the `SindarinDebugger` class.

```Smalltalk
dbg := SindarinDebugger debug: [<your code>].
"Manipulate and inspect the debugged execution by sending messages to dbg"
dbg step; stepOver.
dbg context inspect.
dbg currentNode inspect.
...
```

### Jump to caret VS skip command usage

[See here](./doc/jump-to-caret.md)

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
