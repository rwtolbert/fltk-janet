(if (dyn :install-time-syspath)
  (use @install-time-syspath/spork/declare-cc)
  (use spork/declare-cc))

(setdyn :verbose true)
(def build-type "release")

(import spork/pm)
(import spork/sh)

(defdyn *cmakepath* "What cmake command to use")
(defdyn *ninjapath* "What ninja command to use")

(def cfltk-lib
  (if (= (os/which) :windows)
    "cfltk2.lib"
    "cfltk2.a"))

(defn error-exit [msg &opt code]
  (default code 1)
  (printf msg)
  (os/exit code))

(defn- cmake
  "Make a call to cmake."
  [& args]
  (sh/exec (dyn *cmakepath* "cmake") ;args))

(defn update-submodules []
  (pm/git "submodule" "update" "--init" "--recursive"))

(defn set-command [cmd todyn]
  "Look for executable on PATH"
  (if (sh/which cmd)
    (setdyn todyn (sh/which cmd))
    (error-exit (string/format "Unable to find command: %s" cmd))))

(def cfltk-build-dir (string/format "_build/%s/cfltk-build" build-type))
(def fltk-flags @["-DFLTK_USE_SYSTEM_LIBJPEG=OFF" "-DFLTK_USE_SYSTEM_LIBPNG=OFF" "-DFLTK_USE_SYSTEM_ZLIB=OFF"])
(def cfltk-flags @["-B" cfltk-build-dir "-S" "cfltk" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Release" "-DCFLTK_USE_OPENGL=ON" "-DFLTK_BUILD_EXAMPLES=OFF"])

(def cmake-flags (array/concat cfltk-flags fltk-flags))
(def cmake-build-flags @["--build" cfltk-build-dir "--parallel" "--config" "Release"])

(defn build-cfltk []
  (unless (sh/exists? (string/format "%s/%s" cfltk-build-dir cfltk-lib))
    (cmake ;cmake-flags)
    (cmake ;cmake-build-flags)))

(set-command "cmake" *cmakepath*)
(set-command "ninja" *ninjapath*)

(update-submodules)
(build-cfltk)

(dofile "project.janet" :env (jpm-shim-env))
