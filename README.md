# tibi

_(Work in progress)_

Tibi is a toy programming language with its interpreter and compiler implemented in Lean 4.

Features:
- **Statically typed:** ensures type safety at compile-time.  
- **Formally verified:**
    - **Interpreter:** correctness and completeness of evaluation on type-checked source code.
    - **Compiler:** semantic consistency with the target WebAssembly (Wasm) binary.

## Usage

Tibi's interpreter and compiler can be used by either `lake exec tibi` or `./lake/build/bin/tibi` (after running `lake build`).
This requires [Lake](https://lean-lang.org/lean4/doc/setup.html), the package manager for Lean 4.

### Interpreter

```console
$ lake exec tibi
0:> 1
- : Nat := 1
1:> 
```

### Compiler

Tibi can compile to Wasm.
Here's how you compile a simple Tibi script:

```console
$ cat test.tibi
1
$ lake exec tibi test.tibi >test.wasm
$ hexdump -C test.wasm
00000000  00 61 73 6d 01 00 00 00  01 05 01 60 00 01 7e 03  |.asm.......`..~.|
00000010  02 01 00 07 08 01 04 6d  61 69 6e 00 00 0a 06 01  |.......main.....|
00000020  04 00 42 01 0b                                    |..B..|
00000025
$
```

A compiled Wasm binary exports a single function named `main`, that takes no arguments and returns a single integer.
To execute this, you can use the following HTML:

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Wasm Test</title>
</head>
<body>
    <pre id="output"></pre>
    <script>
        WebAssembly.instantiateStreaming(fetch("test.wasm")).then(
            (obj) => { document.getElementById('output').innerText = obj.instance.exports.main() },
        );
    </script>
</body>
</html>
```

You can see the returned integer in the `pre` element.
