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
             (set lflags @[cfltk-lib-path "cfltk2.lib" fltk-lib-path
                           "fltk.lib" "fltk_forms.lib" "fltk_gl.lib" "fltk_images.lib" "fltk_png.lib" "fltk_jpeg.lib" "fltk_z.lib"
                           "glu32.lib" "opengl32.lib" "ole32.lib" "uuid.lib" "comctl32.lib" "gdi32.lib" "gdiplus.lib" "user32.lib" "shell32.lib" "comdlg32.lib" "ws2_32.lib" "winspool.lib"]))
  :macos (do
           (set cppflags @["-I./cfltk/include" "-DCFLTK_USE_GL"])
           (set lflags @[cfltk-lib-path "-lcfltk2" fltk-lib-path "-lfltk"
                         "-lfltk_images" "-lfltk_forms" "-lfltk_gl" "-lfltk_png" "-lfltk_jpeg" "-lfltk_z"
                         "-framework" "Cocoa" "-framework" "OpenGL" "-weak_framework" "ScreenCaptureKit" "-weak_framework" "UniformTypeIdentifiers"]))
  :linux (do
           (set cppflags @["-fPIC" "-I./cfltk/include" "-DCFLTK_USE_GL"])
           (set lflags (dyn *lflags*))))

(declare-native
  :name "jfltk/widgets"
  :source @["c/module.cpp"]
  :c++flags cppflags
  :lflags lflags)
