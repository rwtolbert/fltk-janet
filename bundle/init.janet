(if (dyn :install-time-syspath)
  (use @install-time-syspath/spork/declare-cc)
  (use spork/declare-cc))

(setdyn :verbose true)
(def- build-type "release")

(import spork/pm)
(import spork/sh)
(import spork/path)
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

(def- cfltk-build-dir (string/format "_build/cfltk-build"))
(def- fltk-flags @["-DFLTK_USE_SYSTEM_LIBJPEG=OFF"
                   "-DFLTK_USE_SYSTEM_LIBPNG=OFF"
                   "-DFLTK_USE_SYSTEM_ZLIB=OFF"])
(def- cfltk-flags @["-B" cfltk-build-dir "-S" "cfltk" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Release" "-DCFLTK_USE_OPENGL=ON" "-DFLTK_BUILD_EXAMPLES=OFF"])

(when (= (os/which) :linux)
  (array/push fltk-flags "-DCFLTK_USE_FPIC=ON")
  (array/push fltk-flags "-DFLTK_BACKEND_WAYLAND=ON"))

(def- cmake-flags (array/concat cfltk-flags fltk-flags))
(def- cmake-build-flags @["--build" cfltk-build-dir "--parallel" "--config" "Release"])

(defn build-cfltk []
  (unless (and (sh/exists? "cfltk") (sh/exists? "cfltk/fltk"))
    (update-submodules))
  (unless (sh/exists? (string/format "%s/%s" cfltk-build-dir cfltk-lib))
    (unless (sh/exists? (string/format "%s/%s" cfltk-build-dir "build.ninja"))
      (cmake ;cmake-flags))
    (cmake ;cmake-build-flags)))

(set-command "cmake" *cmakepath*)
(set-command "ninja" *ninjapath*)

(var cfltk-lib-path nil)
(var fltk-lib-path nil)
(if (= (os/which) :windows)
  (do
    (set cfltk-lib-path (string/format "/LIBPATH:./%s/cfltk-build" cfltk-build-dir))
    (set fltk-lib-path (string/format "/LIBPATH:./%s/cfltk-build/fltk/lib" cfltk-build-dir)))
  (do
    (set cfltk-lib-path (string/format "-L./%s" cfltk-build-dir))
    (set fltk-lib-path (string/format "-L./%s/fltk/lib" cfltk-build-dir))))

(def- fltk-config (path/join (os/cwd) (string/format "%s/fltk/fltk-config" cfltk-build-dir)))

(def- windows-fltk-libs
  @[cfltk-lib-path "cfltk2.lib" fltk-lib-path
    "fltk.lib" "fltk_forms.lib" "fltk_gl.lib" "fltk_images.lib" "fltk_png.lib" "fltk_jpeg.lib" "fltk_z.lib"
    "glu32.lib" "opengl32.lib" "ole32.lib" "uuid.lib" "comctl32.lib" "gdi32.lib" "gdiplus.lib"
    "user32.lib" "shell32.lib" "comdlg32.lib" "ws2_32.lib" "winspool.lib"])

(defn fltk-libs []
  (if (sh/exists? fltk-config)
    (if (not (= (os/which) :windows))
      (do
        (def out (sh/exec-slurp fltk-config "--use-gl" "--use-images" "--use-glut" "--use-forms" "--use-cairo" "--ldflags"))
        (string/split " " out))
      @[])
    (do (build-cfltk)
        (fltk-libs))))

(defdyn *lflags* "Linker flags")
(setdyn *lflags* (if (= (os/which) :windows)
                   windows-fltk-libs
                   (array/join @[cfltk-lib-path "-lcfltk2"] (fltk-libs))))

(dofile "project.janet" :env (jpm-shim-env))

(task "pre-build" ["build-cfltk"])
(task "build-cfltk" [] (build-cfltk))
