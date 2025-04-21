# fltk-janet

This is an experimental [FLTK](https://www.fltk.org) wrapper for Janet using the
excellent [CFLTK](https://github.com/MoAlyousef/cfltk) code. Janet native code
is generated via a Python script using `libclang` to parse the cfltk headers.

There are a few examples, just to help with understanding how the wrapper
might work in Janet. And some CFLTK/FLTK functionality is not wrapped yet.

## Platforms

This has been tested on Windows with MSVC and macOS. Linux using X11
also works but does require a number of prerequisite packages to be installed.

Still need to test Wayland support.

### Ubuntu 20, 22, 24

```bash
$ sudo apt-get update
$ sudo apt-get install build-essential cmake ninja-build libx11-dev \
    libxext-dev libxft-dev libxft2-dev libxinerama-dev libxcursor-dev \
    libfontconfig-dev libopengl-dev freeglut3-dev libglu1-mesa-dev
```

## Building

use `janet-pm` from spork. Building requires `cmake` on your PATH in order
to build `fltk` and `cfltk` first.

```
$ janet-pm build
```

## Installing

```
$ janet-pm install
```

## A very simple example

```janet
(use jfltk)

(defn clicker [widget event &opt obj]
  (case event
    Fl_Event_Push (do
                    (Fl_Box_set_label obj "Hello")
                    1)
    true 0))


(def w (Fl_Window_new 100 100 400 300 "handler"))
(def f (Fl_Box_new 0 0 400 200 ""))
(def b (Fl_Button_new 160 210 80 40 "Click me"))
(Fl_Window_end w)
(Fl_Window_show w)

(def cb (make_custom_callback clicker f))

(Fl_Button_handle b cb)
(Fl_run)
```

## Running examples

All the examples assume installation first, then they can be
run as:

```
$ janet examples/counter.janet
```

![counter.janet example](https://github.com/rwtolbert/fltk-janet/blob/main/examples/counter.png)

## Updating cfltk

First update the cfltk submodule, then re-generate the Janet native module code.

Generating the wrapper code requires Python 3 with the `libclang` package installed.

Something like this works, from the root of the source tree:

```
$ python -m venv .venv
$ source .venv/bin/activate
$ pip install libclang
$ janet bundle/generate-wrapper.janet
```

