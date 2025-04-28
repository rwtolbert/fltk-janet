(if (dyn :install-time-syspath)
  (use @install-time-syspath/spork/declare-cc)
  (use spork/declare-cc))

(setdyn :verbose true)
(def- build-type "release")

(import spork/pm)
(import spork/sh)
(use ./utils)

(defdyn *cmakepath* "What cmake command to use")
(defdyn *ninjapath* "What ninja command to use")

(def- cfltk-lib
  (if (= (os/which) :windows)
    "cfltk2.lib"
    "cfltk2.a"))

(defn- cmake
  "Make a call to cmake."
  [& args]
  (sh/exec (dyn *cmakepath* "cmake") ;args))

(defn- update-submodules []
  (pm/git "submodule" "update" "--init" "--recursive"))

(def- cfltk-build-dir (string/format "_build/%s/cfltk-build" build-type))
(def- fltk-flags @["-DFLTK_USE_SYSTEM_LIBJPEG=OFF" "-DFLTK_USE_SYSTEM_LIBPNG=OFF" "-DFLTK_USE_SYSTEM_ZLIB=OFF"])
(def- cfltk-flags @["-B" cfltk-build-dir "-S" "cfltk" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Release" "-DCFLTK_USE_OPENGL=ON" "-DFLTK_BUILD_EXAMPLES=OFF"])

(when (= (os/which) :linux)
  (array/push fltk-flags "-DCFLTK_USE_FPIC=ON"))
(when (= (os/which) :linux)
  (array/push fltk-flags "-DFLTK_BACKEND_WAYLAND=ON"))

(def- cmake-flags (array/concat cfltk-flags fltk-flags))
(def- cmake-build-flags @["--build" cfltk-build-dir "--parallel" "--config" "Release"])

(defn build-cfltk []
  (unless (sh/exists? (string/format "%s/%s" cfltk-build-dir cfltk-lib))
    (unless (sh/exists? (string/format "%s/%s" cfltk-build-dir "build.ninja"))
      (cmake ;cmake-flags))
    (cmake ;cmake-build-flags)))

(set-command "cmake" *cmakepath*)
(set-command "ninja" *ninjapath*)

# (update-submodules)
# (build-cfltk)

(dofile "project.janet" :env (jpm-shim-env))

(task "pre-build" ["build-cfltk"])
(task "build-cfltk" [] (do
                        (update-submodules)
                        (build-cfltk)))