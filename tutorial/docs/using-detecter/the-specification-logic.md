--8<-- "includes/common.md"

# The Specification Logic
---

## Overview

For the sake of simplicity, the script `hello_prop.hml` used in our hello world example specifies a sHML property that every system necessarily violates, namely, the formula `#!shml ff` that denotes falsity.
We now look at the full sHML grammar that enables us to express more interesting and useful properties *about programs* (not traces).
Specifications in sHML---also called *formulae*---are interpreted over the *states* of transition models of programs we wish to analyse.
sHML is a syntactic subset of the more expressive Hennessy-Milner Logic with recursion, and is used to specify [safety properties](getting-started.md#safety-properties).
Recall safety properties state that "something bad should never happen".
sHML formulae are generated from the following grammar:

```{ .shml .annotate }
sHML ::=  ff  |  tt                        (1) 
       |  X                                (2)
       |  max(X. sHML)                     (3) 
       |  and([Act]sHML, ..., [Act]sHML)   (4)
```

1. Formula `#!shml ff` and `#!shml tt` denote *falsity* and *truth* respectively,

2. `#!shml X` is a *logical variable*,

3. The *maximal fix-point* construct specifies *recursion* via the logical variable `#!shml X` and *binds* the free occurrences of `#!shml X` in the sub-formula `#!shml sHML`, and,

4. `#!shml and(...)` is a sequence of comma-separated *conjunctions* where each conjunct is a sub-formula `#!shml sHML` *guarded* by the universal modal operator `#!shml [Act]` (also called a *necessity*).

To handle reasoning over program event data, the modal operator is equipped with *symbolic actions* `#!shml Act` of the form `#!shml P when C`, where `#!shml P` is an *event pattern* and `#!shml C`, a *decidable Boolean constraint*.
Patterns correspond to events that the program under analysis exhibits. 
These patterns contain *data variables* that are instantiated with values learnt at runtime from *matched* events.
Pattern variables *bind* the free variables in constraints `#!shml C`, and this binding scope *extends* to the continuation formula `#!shml sHML`.
Symbolic action patterns follow the pattern-matching syntax of Erlang and Elixir, where atoms are matched directly, and the 'don't care' pattern `_` matches any data value.
We say that a program (or a program state) satisfies the formula `#!shml [P when C]sHML` *whenever* it exhibits an event that matches pattern `#!shml P`, fulfils the constraint `#!shml C`, *and* the ensuing program behaviour then satisfies `#!shml sHML`. 
When the constraint is `#!shml true`, the expression `#!shml when C` may be omitted for readability.


## Pattern and constraint expressions

detectEr supports five event patterns describing the lifecycle of processes.
A `fork` action is exhibited by a process when it spawns a new child process; its dual, `init`, is exhibited by the corresponding child upon initialisation.
Process `exit` actions signal termination, while `send` and `recv` describe process interaction.

| Program event  | Event pattern                             | Pattern variable    | Description                                                         |
| :-----------: | :----------------------------------------: | :-----------------: | :------------------------------------------------------------------ |
| `fork`        | *P~1~* **-->** *P~2~*, *Mod*:*Fun*(*Args*) | *P~1~*              | PID of the parent process spawning *P~2~*                           |
|               |                                            | *P~2~*              | PID of the child process spawned by *P~1~*                          |
|               |                                            | *Mod*:*Fun*(*Args*) | Function signature consisting of the module, function and arguments |
| `init`        | *P~1~* **<--** *P~2~*, *Mod*:*Fun*(*Args*) | *P~1~*              | PID of the parent process spawning *P~2~*                           |
|               |                                            | *P~2~*              | PID of the child process spawned by *P~1~*                          |
|               |                                            | *Mod*:*Fun*(*Args*) | Function signature consisting of the module, function and arguments |
| `exit`        | *P~1~* __**__ *Data*                       | *P~1~*              | PID of the terminated process                                       |
|               |                                            | *Data*              | Termination data                                                    |
| `send`        | *P~1~* **:** *P~2~* **!** *Msg*            | *P~1~*              | PID of the process issuing the message                              |
|               |                                            | *P~2~*              | PID of the recipient process                                        |
|               |                                            | *Msg*               | Message payload                                                     |
| `recv`        | *P~2~* **?** *Msg*                         | *P~2~*              | PID of the recipient process                                        |
|               |                                            | *Msg*               | Request payload consisting of data                                  |

The variables *P~1~* and *P~2~* in event patterns must be a port ID or PID, whereas *Data* and *Msg* may be any [Erlang data type](http://erlang.org/documentation/doc-6.0/doc/reference_manual/data_types.html), *i.e.*, one of atom, Boolean, integer, float, string, bit string, reference, fun, port ID, PID, tuple, map, and list.
*Mod* and *Fun* must be atoms, and *Args*, an arbitrary list comprised of the aforementioned data types.

!!! note "Pattern matching"
    Our current detectEr syntax does not yet implement full Erlang pattern matching, including $, map, record and bit string expressions; these will be added in future releases of the tool.
    Note that these data values can still be used in patterns, so long as the pattern matching expression does not *unwrap* the individual data components of these values.
    For instance, the pattern `Var = Map` is acceptable whereas `#{K := V} = Map` is not; similarly, `Var = List` may be used but not `[$d, $a | _] = List`.
    
Constraint definitions on pattern variables used by detectEr correspond to Erlang [guard sequences](https://erlang.org/doc/reference_manual/expressions.html#guard-sequences) consisting of [guard expressions](https://erlang.org/doc/reference_manual/expressions.html#guard-sequences).
The set of valid Erlang guards supported by detectEr are the following:

* Variables.
* Values, *i.e.*, atom, Boolean, integer, float, string, bit string, reference, fun, port ID, PID, tuple, map, and list.
* Expressions constructing atoms, integer, floats, lists, and tuples.



* Term comparisons.

    | Operator       | Description              |
    | :------------: | :----------------------- |
    | `#!erlang ==`  | Equal to                 |
    | `#!erlang /=`  | Not equal to             |
    | `#!erlang =<`  | Less than or equal to    |
    | `#!erlang <`   | Less than                |
    | `#!erlang >=`  | Greater than or equal to |
    | `#!erlang >`   | Greater than             |
    | `#!erlang =:=` | Exactly equal to         |
    | `#!erlang =/=` | Exactly not equal to     |

* Arithmetic expressions.

    | Operator        | Description               | Argument Type |
    | :-------------: | :------------------------ | :-----------: |
    | `#!erlang +`    | Unary addition            | Number        |
    | `#!erlang -`    | Unary subtraction         | Number        |
    | `#!erlang +`    | Addition                  | Number        |
    | `#!erlang -`    | Subtraction               | Number        |
    | `#!erlang *`    | Multiplication            | Number        |
    | `#!erlang /`    | Floating point division   | Number        |
    | `#!erlang bnot` | Unary bitwise NOT	        | Integer       |
    | `#!erlang div`  | Integer division          | Integer       |
    | `#!erlang rem`  | Integer remainder of X/Y  | Integer       |
    | `#!erlang band` | Bitwise AND               | Integer       |
    | `#!erlang bor`  | Bitwise OR                | Integer       |
    | `#!erlang bxor` | Arithmetic bitwise XOR    | Integer       |
    | `#!erlang bsl`  | Arithmetic bit shift left | Integer       |
    | `#!erlang bsr`  | Bit shift right           | Integer       |

* Boolean expressions.

    | Operator       | Description       |
    | :------------: | :---------------: |
    | `#!erlang not` | Unary logical NOT |
    | `#!erlang and` | Logical AND       |
    | `#!erlang or`  | Logical OR        |
    | `#!erlang xor` | Logical XOR       |

* Short-circuit expressions `#!erlang andalso`, `#!erlang orelse`.

<!-- * Invocations to the type test BIF predicates.
    
    | BIF                       | Description                   | 
    | :------------------------ | :---------------------------- |
    | `#!erlang is_atom/1`      | Is atom                       |
    | `#!erlang is_boolean/1`   | Is Boolean                    |
    | `#!erlang is_float/1`     | Is floating point number      |
    | `#!erlang is_function/1`  | Is function                   |
    | `#!erlang is_function/2`  | Is function with N parameters |
    | `#!erlang is_integer/1`   | Is integer                    |
    | `#!erlang is_list/1`      | Is list                       |
    | `#!erlang is_number/1`    | Is number                     |
    | `#!erlang is_pid/1`       | Is PID                        |
    | `#!erlang is_port/1`      | Is port                       |
    | `#!erlang is_reference/1` | Is reference                  |
    | `#!erlang is_tuple/1`     | Is tuple                      |

* Invocations to the BIFs allowed in guards.

    | BIF                     | Description            | Argument Type    |
    | :---------------------- | :--------------------- | :--------------: |
    | `#!erlang abs/1`        | Absolute               | Number           |
    | `#!erlang element/2`    | N^th^ tuple element    | Integer, Tuple   |
    | `#!erlang float/1`      | Floating point number  | Term             |
    | `#!erlang hd/1`         | List head              | List             |
    | `#!erlang length/1`     | List length            | List             |
    | `#!erlang node/0`       | EVM node               | ---              |
    | `#!erlang node/1`       | EVM node of expression | Pid, Ref or Port |
    | `#!erlang round/1`      | Round                  | Number           |
    | `#!erlang self/0`       | Calling process PID    | ---              |
    | `#!erlang size/1`       | Tuple size             | Tuple            |
    | `#!erlang tl/1`         | List tail              | List             |
    | `#!erlang trunc/1`      | Truncate               | Number           |
    | `#!erlang tuple_size/1` | Tuple size             | Tuple            | -->

## Suppressing program actions

Let us try to specify a safety requirement on the behaviour of our [calculator program](getting-started.md#calculator-program).
The sHML formula with symbolic action `Srv:Clt ! {bye,Tot} when Tot < 0` describes the property requiring that "the program state does *not* exhibit the send event whose payload consists of `#!erlang {bye, Tot}` with a negative total:

```shml
and([Srv:Clt ! {bye,Tot} when Tot < 0])ff
```

Recall that the universal modality states that, for any program event satisfying the symbolic action `#!shml P when C` in `#!shml [P when C]sHML`, the ensuing program behaviour must then satisfy the continuation formula `#!shml sHML`.
However, *no* program state can satisfy the continuation `#!shml ff`! 
This means that the formula `#!shml and([Srv:Clt ! {bye,Tot} when Tot < 0])ff` can only be satisfied when  our calculator program does not exhibit the event described by the symbolic action `#!erlang Srv:Clt ! {bye,Tot} when Tot < 0`.

Suppose our server with PID `#!erlang <0.10.0>` exhibits the `send` event `#!erlang <0.10.0>:<0.16.0> ! {bye,-1}` in response to a request issued by a client with PID `#!erlang <0.16.0>`.
It matches pattern `#!shml Srv:Clt ! {bye,Tot}`, instantiating the variables `#!erlang Srv = <0.10.0>`, `#!erlang Clt = <0.16.0>`, and `#!erlang Tot = -1`.
The constraint `#!erlang when Tot < 0` is also satisfied by `#!erlang Tot`, leading to a violation, *i.e.*, `#!shml ff`.
For a different `send` event `#!erlang <0.10.0>:<0.16.0> ! {bye,1}`, the symbolic action in the modality `#!shml [Srv:Clt ! {bye,Tot} when Tot < 0]` is not satisfied, and consequently, `#!shml and([Srv:Clt ! {bye,Tot} when Tot < 0])ff` is not violated.
Analogously, the `exit` event `#!erlang <0.10.0> ** killed` does not lead to a violation of the formula since the pattern `#!shml Srv:Clt ! {bye,Tot}` fails to match the event shape.

!!! note "Cheat sheet"
    The formula `#!shml [Act]ff` means that the program must not exhibit the symbolic action `#!shml Act`.

---
LINK TO NEXT SECTION