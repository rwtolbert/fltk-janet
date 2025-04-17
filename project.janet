(declare-project
  :name "fltk-janet"
  :description ```Janet wrapper for FLTK```
  :author ```Bob Tolbert ```
  :dependencies @["spork"]
  :version "0.1.0")

(setdyn :verbose true)

(declare-source
  :source ["fltk-janet"])

(var cppflags nil)
(var lflags nil)

(case (os/which)
  :windows (do
    )
  :macos (do
           (set cppflags @["-I./cfltk/include" "-DCFLTK_USE_GL"])
           (set lflags @["-L./cfltk-build" "-lcfltk2" "-L./cfltk-build/fltk/lib"
                        "-lfltk_images" "-lfltk_forms" "-lfltk_gl" "-lfltk_png""-lfltk_jpeg" "-lfltk_z"
                        "-framework" "Cocoa" "-framework" "OpenGL" "-weak_framework" "ScreenCaptureKit" "-weak_framework" "UniformTypeIdentifiers"]))
  :linux (do
           (set cppflags @["-fPIC" "-I./cfltk/include" "-DCFLTK_USE_GL"])
           (set lflags @["-L./cfltk-build" "-lcfltk2" "-L./cfltk-build/fltk/lib"
                         "-lfltk_images" "-lfltk_forms" "-lfltk_gl" "-lfltk" "-lfltk_png" "-lfltk_jpeg" "-lfltk_z" "-lGL" "-lGLU" "-lglut"
                         "-lm" "-lX11" "-lXext" "-lpthread" "-lXrender" "-lfontconfig" "-ldl"])))

(declare-native
  :name "jfltk"
  :source @["c/module.cpp"]
  :c++flags cppflags
  :lflags lflags
  )
