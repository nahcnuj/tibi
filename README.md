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

### Interpreter (REPL)

Tibi can execute a Read-Eval-Print Loop (REPL).

```console
$ lake exec tibi
0:> 42
- : Int = 42
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

## Language Specification

### Syntax

```ebnf
            ws = { " " | "\n" | "\r" | "\t" } ;

non-zero-digit = "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
         digit = "0" | non-zero-digit ;
    nat-number = "0"
               | non-zero-digit , { digit } ;

          sign = "+" | "-" ;
    int-number = sign , nat-number ;

          expr = nat-number , ws
               | int-number , ws;
```

<!--
### Semantics

-->

## Formal Verification

### Type Safety

If Tibi's expressions are typable, their evaluation succeeds and evaluates in a value of the corresponding type.
[`Tibi.type_safe`](./Tibi/Props/Typing.lean) provides proof of the following statement:
```math
\forall e \in \mathrm{Expr}.~\forall \tau \in \mathrm{Type}.~\forall r \in \mathrm{Result}.~
\vdash e : \tau \land \vdash e \Downarrow r \implies \exists v \colon \tau .~ r \equiv v,
```
where
- $\vdash e : \tau$ denotes (or, is implemented in) [`Tibi.HasType e τ`](./Tibi/Typing.lean), and
- $\vdash e \Downarrow r$ denotes (or, is implemented in) [`Tibi.Eval e r`](./Tibi/Semantics.lean),

### Semantic Consistency

When expressions in Tibi that are typable are compiled into Wasm binaries,
the semantics of Tibi must align with [the semantics of Wasm](https://webassembly.github.io/spec/core/exec/index.html) to ensure consistency.
[`Wasm.Reduction.of_has_type_of_eval_ok_of_compile_ok`](./Tibi/Props/Compiler.lean) provides proof of the following statement:
```math
\forall e \in \mathrm{Expr}.~\forall \tau \in \mathrm{Type}.~\forall v \colon \tau.~
\vdash e \colon \tau \land \vdash e \Downarrow v
\implies \mathop{\mathtt{Expr.compile}}(e)~\mathit{instr}^* \hookrightarrow (\mathop{\mathsf{i64.const}} v)~\mathit{instr}^*
,
```
where $\mathit{instr}^*$ is a continuation.
