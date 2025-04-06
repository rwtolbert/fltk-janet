(declare-project
  :name "fltk-janet"
  :description ```FLTK wrapper for Janet ```
  :author ```Bob Tolbert ```
  :dependencies @["spork"]
  :version "0.0.0")

(setdyn :verbose true)

(declare-source
  :source ["fltk-janet"])

(declare-native
  :name "jfltk"
  :source @["c/module.cpp"]
  :c++flags @["-I./cfltk/include"]
  :lflags @["-L./cfltk-build" "-lcfltk" "-L./cfltk-build/fltk/lib" "-lfltk"
            "-lfltk_images" "-lfltk_forms" "-lfltk_png" "-lfltk_jpeg" "-lfltk_z"
            "-framework" "Cocoa" "-weak_framework" "ScreenCaptureKit" "-weak_framework" "UniformTypeIdentifiers"]
  )