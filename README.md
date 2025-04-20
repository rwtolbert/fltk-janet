# fltk-janet

## Building

use `janet-pm` from spork. Building requires `cmake` on your PATH in order
to build `fltk` and `cfktk`

```
$ janet-pm build
```

## Installing

```
$ janet-pm install
```

## Running examples

All the examples assume installation first, then they can be
run as:

```
$ janet examples/counter.janet
```

![counter.janet example](https://github.com/rwtolbert/fltk-janet/blob/main/examples/counter.png)

## Updating cfltk

First update the cfltk submodule, then re-generate the wrapper C code with

```
$ janet bundle/generate-wrapper.janet
```

Then rebuild and reinstall.
