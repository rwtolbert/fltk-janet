(import spork/sh)
(import spork/path)

(declare-project
  :name "fltk-janet"
  :description ```Janet wrapper for FLTK```
  :author ```Bob Tolbert ```
  :dependencies @["spork"]
  :version "0.1.0")

(def build-type (string (dyn *build-type* :release)))

(setdyn :verbose true)
(setdyn *build-type* :release)

(declare-source
  :source ["jfltk"])

(var cppflags nil)
(var lflags nil)
(case (os/which)
  :windows (do
             (set cppflags @["/bigobj" "-I./cfltk/include" "-DCFLTK_USE_GL"])
             (set lflags (dyn *lflags*)))
  :macos (do
           (set cppflags @["-I./cfltk/include" "-DCFLTK_USE_GL"])
           (set lflags (dyn *lflags*)))
  :linux (do
           (set cppflags @["-fPIC" "-I./cfltk/include" "-DCFLTK_USE_GL"])
           (set lflags (dyn *lflags*))))

(declare-native
  :name "jfltk/widgets"
  :source @["c/module.cpp"]
  :c++flags cppflags
  :lflags lflags)
