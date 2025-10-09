(def info (-> (slurp info-file) (parse)))

(import spork/sh)
(import spork/path)

(declare-project
  :name (info :name)
  :description (info :version)
  :dependencies (info :jpm-dependencies)
  :version (info :version))

(def build-type (string (dyn *build-type* :release)))

(setdyn :verbose true)
(setdyn *build-type* :release)

(declare-source
  :source ["jfltk"])

(var cppflags nil)
(var lflags nil)
(case (os/which)
  :windows (do
             (set cppflags @["/bigobj" "-I./cfltk/include" "-DCFLTK_USE_GL" "-DFLTK_BUILD_FORMS"])
             (set lflags (dyn *lflags*)))
  :macos (do
           (set cppflags @["-I./cfltk/include" "-DCFLTK_USE_GL" "-DFLTK_BUILD_FORMS"])
           (set lflags (dyn *lflags*)))
  :linux (do
           (set cppflags @["-fPIC" "-I./cfltk/include" "-DCFLTK_USE_GL" "-DFLTK_BUILD_FORMS"])
           (set lflags (dyn *lflags*))))

(declare-native
  :name "jfltk/widgets"
  :source @["c/module.cpp"]
  :c++flags cppflags
  :lflags lflags)
