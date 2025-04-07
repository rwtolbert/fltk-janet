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
  :c++flags @["-I./cfltk/include" "-DCFLTK_USE_GL"]
  :lflags @["-L./cfltk-build" "-lcfltk" "-L./cfltk-build/fltk/lib"
            "-lfltk_images" "-lfltk_forms" "-lfltk_gl"  "-lfltk" "-lfltk_png""-lfltk_jpeg" "-lfltk_z"
            "-framework" "Cocoa" "-framework" "OpenGL" "-weak_framework" "ScreenCaptureKit" "-weak_framework" "UniformTypeIdentifiers"]
  )