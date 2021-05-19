--8<-- "includes/common.md"

# Quickstart
---


## Launching detectEr from the shell

The `detecter/ebin` directory created [previously](setting-up-detecter.md#compiling-detecter) needs to be included in the Erlang runtime path to preload all the binaries required to be able to use detectEr.
This is done by using the `-pa` switch when launching the Erlang shell.

```console
[duncan@local]:$ erl -pa /path/to/detecter/ebin
```

Once loaded, detectEr can be used to monitor systems that execute on the Erlang Virtual Machine.
It also supports the monitoring of systems that run outside of the EVM, provided that these record their logs in files following a predetermined formatting that enables detectEr to extract runtime information.
This topic is covered in more depth in the [Instrumentation](../using-detecter/instrumentation.md) section.
For now, we establish the workflow required to use detectEr by way of the traditional 'hello world' example.


## Hello world

Before using detectEr, you should get an intuitive grasp of what monitoring is, and the steps one needs to follow to initialise and start the monitoring process.
If this is your first time using Erlang, the following wil help you get acquainted with the Erlang shell.

Launch a new terminal emulator window (*e.g.* Terminal on Ubuntu or macOS), navigate to the *root* detectEr directory, and:

1. Change the directory to `examples/erlang`.

    ```console
    [duncan@local]:/detecter$ cd examples/erlang
    [duncan@local]:/detecter/examples/erlang$ ls -l
    -rw-rw-r-- 1 duncan duncan  996 May 17 17:16 Makefile
    drwxrwxr-x 2 duncan duncan 4096 May 17 17:16 props
    drwxrwxr-x 3 duncan duncan 4096 May 17 17:16 src
    ```

2. Execute `make` to compile all of the Erlang source code modules located in `examples/erlang/src`. 
   A new `ebin` directory containing the compiled `*.beam` files is created.
   BEAM files are (fairly) portable binaries consisting of *bytecode* that is interpreted by the EVM, similar to how Java operates.

    ```console hl_lines="6"
    [duncan@local]:/detecter/examples/erlang$ make
    rm -f ebin/*.beam ebin/*.E ebin/*.tmp erl_crash.dump ebin/*.app
    ...
    [duncan@local]:/detecter/examples/erlang$ ls -l
    -rw-rw-r-- 1 duncan duncan  996 May 17 17:16 Makefile
    drwxrwxr-x 7 duncan duncan 224 May 17 17:16 ebin
    drwxrwxr-x 2 duncan duncan 4096 May 17 17:16 props
    drwxrwxr-x 3 duncan duncan 4096 May 17 17:16 src
    ```
3. Launch the Erlang shell `erl`. 
   We add the binaries of the `ebin` directory to the Erlang code path via the `-pa` flag to load and make them accessible from the shell.

    ```console
    [duncan@local]:/detecter/examples/erlang$ erl -pa ebin
    Erlang/OTP 23 [erts-11.2.1] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe] [dtrace]
    Eshell V11.2.1  (abort with ^G)
    1>
    ```
4. The Erlang shell allows you to type *expressions* and execute them by pressing ++return++. 
   Every expression typed on the shell *must* be terminated with a full-stop.
   Try invoking the function `#!erlang greet` of the `#!erlang hello` module.
   The function `#!erlang greet` accepts one argument, the name of the person to greet, specified as a string enclosed within double quotes.
   
    ```erlang
    1> hello:greet("Duncan").
    Hello there, Duncan!
    ok
    2> 
    ```
5. Quit the Erlang shell by typing `q().`

!!! note "Function signatures"
    In Erlang (and Elixir), functions are uniquely identified via the triple `#!erlang mod:fun/arity`, where `#!erlang mod` is the *module* name, `#!erlang fun`, the name of the *function* contained in the module, and `#!erlang arity`, the number of *arguments* that the function accepts.
    This reference format is commonly known as MFA.
    For example, our `#!erlang greet` function inside the module `#!erlang hello` can be concisely referred to as `#!erlang hello:greet/1`.

## Hello world, the asynchronous way

You might have noticed that `#!erlang hello:greet/1` pauses the Erlang shell momentarily before the greeting is displayed.
During this interval, the shell is inoperable and cannot accept user input. 
Such function calls are called *synchronous* invocations, since they block the caller until the called function returns, *i.e.* the body of the called function is executed in its *entirety* and a value is returned to the caller.
Examining the body of `#!erlang greet` below makes it clear why the Erlang shell stops responding when the function call is effected.

```erlang linenums="1" hl_lines="2"
greet(Name) ->
  timer:sleep(5000), % Pause for 5 seconds to simulate some work..
  io:format("Hello there, ~s!~n", [Name]).
```

Line `1` defines the function `#!erlang greet` that accepts `#!erlang Name` as parameter, while line `3` prints the greeting on the Erlang shell via call to `#!erlang io:format/2`.
The call `#!erlang timer:sleep(5000)` on line `2` pauses the caller process (*i.e.* the Erlang shell, in this case) for `#!erlang 5000` ms before executing the rest of the function body.
In Erlang, the function return value is the result of the *last expression* in the function body; for the case of `#!erlang greet`, this value is the *atom* `#!erlang ok` that is returned by `#!erlang io:format/2`.

!!! note "Synchronous calls"
    Synchronous function calls are useful when one needs to ensure that certain processes execute in some prescribed order with respect to one another, *e.g.* in lock step.
    This mode of interaction is common to many standard communication protocols such as HTTP, SMTP, DNS, *etc.*

Unwanted synchrony can be easily avoided by launching functions to execute as *independent* processes that run *concurrently* with other processes in the system.
To this end, Erlang provides the Built-in Functions `#!erlang spawn/{1-4}`, and their variations.
We slightly tweak our hello world example to *spawn* `#!erlang hello:greet/1` as a separate process that executes concurrently with the Erlang shell process.

```erlang linenums="4" hl_lines="2"
start_greet(Name) when is_list(Name) -> 
  spawn(?MODULE, greet, [Name]).
```

The function `#!erlang hello:start_greet/1` implements this modification.
It uses the BIF `#!erlang spawn/3` (line `2`) to launch the `#!erlang hello:greet/1` function as a process, returning its process ID.
The Process ID (also called the PID) is a triple that uniquely identifies an Erlang process executing on the EVM.
Function `#!erlang start_greet` makes use of the predefined macro `#!erlang ?MODULE`, that gets replaced with the name of the module it appears in when the source code of the `#!erlang hello` module is *preprocessed* by the Erlang compiler. 
Concretely, the invocation to `spawn/3` on line `5` yields the source code `#!erlang spawn(hello, greet, [Name])` prior to compilation.




Restart the Erlang shell and invoke `#!erlang hello:start_greet/1`.

```erlang
1> hello:start_greet("Duncan").
<0.84.0>
Hello there, Duncan! % Shown after a slight pause.
2> 
```

Observe that now:

1. The return value of `#!erlang start_greet` is the PID `<0.84.0>` instead of the atom `#!erlang ok`;

2. The Erlang shell does not block, but returns immediately;

3. After the predefined sleep time elapses, the greeting is printed to the shell.


## Outline runtime monitoring

In this quickstart demo, we monitor the execution of our asynchronous hello world example using the [outline](../using-detecter/instrumentation.md#outline-instrumentation) form of instrumentation. 

<!-- Outline monitoring is operates asynchronously as well, and is described at length in XXX. -->


1. Launch the shell as previous, adding the hello world binaries in `ebin` to the Erlang code path.
   The detectEr binaries compiled [earlier](setting-up-detecter.md#compiling-detecter) are also included.

    ```console hl_lines="1"
    [duncan@local]:/detecter/examples/erlang$ erl -pa ebin ../../detecter/ebin
    Erlang/OTP 23 [erts-11.2.1] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe] [dtrace]
    Eshell V11.2.1  (abort with ^G)
    1>
    ```

2. Compile the sample `hello_prop.hml` property script to generate the corresponding analyser binary.

    ```erlang
    1> hml_eval:compile("props/hello_prop.hml", [{outdir,"ebin"}, v]).
    ```

    This compilation procedure, known as the *synthesis*, translates sHML specifications written in `*.hml`  script files to their analyser equivalents.
    For now, it suffices to know that sHML---the *logic* used by detectEr---expresses properties of the system one wishes to runtime verify.
    Our analyser Erlang binary generated from the sample property is placed in `/detecter/examples/erlang/ebin` and automatically loaded for use in the shell code path.

    ```erlang hl_lines="3"
    2> ls("ebin").                                                   
    hello.beam                  
    hello_prop.beam
    ...
    ```

    <!-- We focus on synthesising the analyser from `props/hello_prop.hml`; expressing properties in sHML is treated at length in [The Specification Logic](../using-detecter/the-specification-logic) and [Properties](../using-detecter/system-properties) sections.     -->

    The analyser `#!erlang hello_prop` exposes a single function, `#!erlang mfa_spec/1`, that accepts the MFArgs triple `#!erlang {Mod, Fun, Args}` designating the Erlang process to be analysed.
    Specifically, `#!erlang Mod`, `#!erlang Fun` and `#!erlang Args` are the components of the function passed as arguments to `#!erlang spawn/3`.
    For our hello world example, `#!erlang Mod` is the atom `#!erlang hello`, `#!erlang Fun` is the function name `#!erlang greet`, and `#!erlang Args`, the singleton argument list containing the name of the person to be greeted.
    You can test `#!erlang hello_prop:mfa_spec/1` analyser function by providing the triple `#!erlang {hello, greet, ["Duncan"]}`.

    ```erlang
    3> hello_prop:mfa_spec({hello,greet,["Duncan"]}).
    *** [<0.82.0>] Instrumenting monitor for MFA pattern '{hello,greet,["Duncan"]}'.
    *** [<0.82.0>] Reached verdict 'no'.
    ```

4. Launch the monitored system.

    ```{ .erlang .annotate}
    4> monitor:start_online({hello,start_greet,["Duncan"]}, fun hello_prop:mfa_spec/1, []). % {++(1)++}
    ```

    The function `#!erlang monitor:start_online/3` accepts three arguments: a MFArgs describing the function that is to be spawned as an Erlang process, the analyser function, and a list of [options](../using-detecter/instrumentation.md#online-instrumentation).
    Setting MFArgs to `#!erlang {hello,start_greet,["Duncan"]}` and the analyser to `#!erlang fun hello_prop:mfa_spec/1` launches the hello world and analyser processes to execute concurrently.
    

In the simple instance of the analyser `#!erlang hello_prop`, monitoring terminates promptly with the verdict `no`{.verdict-no} as soon as the system starts executing.
This `no`{.verdict-no} verdict informs us that our hello world program violated the sHML specification in `hello_prop.hml`.
We next learn how sHML can be used to express useful properties that *precisely and unambiguously* describe the behaviour we want our systems *not to* infringe.


<!-- --8<-- "includes/footer.md" -->