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

(defn- cmake
  "Make a call to cmake."
  [& args]
  (printf "cmake %j" args)
  (sh/exec (dyn *cmakepath* "cmake") ;args))

(defn- update-submodules []
  (pm/git "submodule" "update" "--init" "--recursive"))

(defn- lib-prefix []
  (if (= (os/which) :windows)
    ""
    "lib"))

(defn- lib-suffix []
  (if (= (os/which) :windows)
    ".lib"
    ".a"))

(def- cfltk-lib
  (string (lib-prefix) "cfltk2" (lib-suffix)))

(def- fltk-build-dir (string/format "_build/cfltk-build/fltk/lib"))
(def- fltk-libs
  (do
    (var results @[])
    (loop [item :in ["fltk" "fltk_gl" "fltk_forms" "fltk_images" "fltk_png" "fltk_jpeg" "fltk_z"]]
      (array/push results (string (lib-prefix) item (lib-suffix))))
    results))

(def- cfltk-build-dir (string/format "_build/cfltk-build"))

(def- fltk-flags @["-DFLTK_USE_SYSTEM_LIBJPEG=OFF"
                   "-DFLTK_USE_SYSTEM_LIBPNG=OFF"
                   "-DFLTK_USE_SYSTEM_ZLIB=OFF"
                   "-DFLTK_BUILD_FORMS=ON"])
(def- cfltk-flags @["-B" cfltk-build-dir "-S" "cfltk" "-G" "Ninja"
                    "-DCMAKE_BUILD_TYPE=Release" "-DCFLTK_USE_OPENGL=ON" "-DFLTK_BUILD_EXAMPLES=OFF"])

(when (= (os/which) :linux)
  (array/push fltk-flags "-DCFLTK_USE_FPIC=ON")
  (array/push fltk-flags "-DFLTK_BACKEND_WAYLAND=ON"))

(def- cmake-flags (array/concat cfltk-flags fltk-flags))
(def- cmake-build-flags @["--build" cfltk-build-dir "--parallel" "--config" "Release"])

(defn- copy-static-libs []
  (sh/copy (string/format "%s/%s" cfltk-build-dir cfltk-lib) (string/format "./jfltk/%s" cfltk-lib))
  (loop [fname :in fltk-libs]
    (let [fullname (string/format "%s/%s" fltk-build-dir fname)
          outname (string/format "./jfltk/%s" fname)]
      (when (sh/exists? fullname)
        (sh/copy fullname outname )))))

(defn- clean-static-libs []
  (loop [fname :in (sh/list-all-files "jfltk")]
    (when (string/has-suffix? (lib-suffix) fname)
      (sh/rm fname))))

(defn build-cfltk []
  (unless (and (sh/exists? "cfltk") (sh/exists? "cfltk/fltk"))
    (update-submodules))
  # remove old static libs, might be stale
  (clean-static-libs)
  (unless (sh/exists? (string/format "%s/%s" cfltk-build-dir cfltk-lib))
    (unless (sh/exists? (string/format "%s/%s" cfltk-build-dir "build.ninja"))
      (cmake ;cmake-flags))
    (do (cmake ;cmake-build-flags)))
  # copy static libs, assuming they have been built
  (copy-static-libs))

(set-command "cmake" *cmakepath*)
(set-command "ninja" *ninjapath*)

(var cfltk-lib-path nil)
(var fltk-lib-path nil)
(if (= (os/which) :windows)
  (do
    (set cfltk-lib-path (string/format "/LIBPATH:./%s/" cfltk-build-dir))
    (set fltk-lib-path (string/format "/LIBPATH:./%s/fltk/lib" cfltk-build-dir)))
  (do
    (set cfltk-lib-path (string/format "-L./%s" cfltk-build-dir))
    (set fltk-lib-path (string/format "-L./%s/fltk/lib" cfltk-build-dir))))

(def- fltk-config (path/join (os/cwd) (string/format "%s/fltk/fltk-config" cfltk-build-dir)))

(def- windows-fltk-link-libs
  @[cfltk-lib-path "cfltk2.lib" fltk-lib-path
    "fltk.lib" "fltk_forms.lib" "fltk_gl.lib" "fltk_images.lib" "fltk_png.lib" "fltk_jpeg.lib" "fltk_z.lib"
    "glu32.lib" "opengl32.lib" "ole32.lib" "uuid.lib" "comctl32.lib" "gdi32.lib" "gdiplus.lib"
    "user32.lib" "shell32.lib" "comdlg32.lib" "ws2_32.lib" "winspool.lib"])

(defn fltk-link-libs []
  (if (sh/exists? fltk-config)
    (if (not (= (os/which) :windows))
      (do
        (def out (sh/exec-slurp fltk-config "--use-gl" "--use-images" "--use-glut" "--use-forms" "--use-cairo" "--ldflags"))
        (string/split " " out))
      @[])
    (do (build-cfltk)
        (fltk-link-libs))))

(defn gen-lflags []
  (if (= (os/which) :windows)
    windows-fltk-link-libs
    (array/join @[cfltk-lib-path "-lcfltk2"] (fltk-link-libs))))

(defdyn *lflags* "Linker flags")
(setdyn *lflags* (gen-lflags))

(task "pre-build" ["build-cfltk" "create-flags"])

(dofile "project.janet" :env (jpm-shim-env))

(task "build-cfltk" []
      (build-cfltk))

# this creates a file in jfltk that can be used to get to the
# platform specific linker flags to compile Janet+FLTK apps into
# full executables. Have a look in "examples/" for an example
(task "create-flags" []
      (def flags (gen-lflags))
      (var real-flags @[])
      (loop [item :in flags]
        (if (and (string/has-prefix? "-L" item) (not (string/find "/usr" item)))
          (array/push real-flags '(get-libdir))
          (array/push real-flags item)))
      (def fname (string (os/cwd) "/jfltk/flags.janet"))
      (def ofs (file/open fname :w))
      (file/write ofs "(import spork/path)\n")
      (file/write ofs "(defn get-libdir [] (string \"-L\" (path/abspath (path/dirname (dyn *current-file*)))))\n")
      (file/write ofs (string/format "(def lflags %j)\n" real-flags))
      (file/write ofs "(defn print-lflags [] (pp lflags))\n")
      (file/close ofs))


