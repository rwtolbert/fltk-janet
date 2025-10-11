(use spork/declare-cc)

# force default to release unless specifically requested
(when (not (os/getenv "JANET_BUILD_TYPE"))
  (setdyn :build-type :release))

# pull info.jdn so we don't duplicate symbols there and
# in declare-project below
(def info (-> (slurp "./bundle/info.jdn") parse))

(declare-project
  :name (info :name)
  :description (info :description)
  :version (info :version)
  :dependencies (info :jpm-dependencies))

###########
(try
  (import janet-native-tools :as jnt)
  ([err fib]
    (print "please run `janet-pm deps` or `jeep prep` first")))

(import spork/pm)
(import spork/sh)
(import spork/path)
(use ./utils)

# make sure we can find cmake and make
(jnt/require-git)
(jnt/require-cmake)
(jnt/require-ninja)

(defn- update-submodules []
  (jnt/git "submodule" "update" "--init" "--recursive"))

(def- cfltk-lib
  (string (jnt/gen-static-libname "cfltk2")))

(def- fltk-build-dir (string/format "_build/cfltk-build/fltk/lib"))
(def- fltk-libs
  (do
    (var results @[])
    (loop [item :in ["fltk" "fltk_gl" "fltk_forms" "fltk_images" "fltk_png" "fltk_jpeg" "fltk_z"]]
      (array/push results (string (jnt/gen-static-libname item))))
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

(def [build-cfltk-fn clean-cfltk-fn]
  (jnt/declare-cmake :name "cfltk"
                     :source-dir "cfltk"
                     :build-dir cfltk-build-dir
                     :cmake-flags cmake-flags
                     :build-type "Release"))

(defn- copy-static-libs []
  (sh/copy-file (string/format "%s/%s" cfltk-build-dir cfltk-lib) (string/format "./jfltk/%s" cfltk-lib))
  (loop [fname :in fltk-libs]
    (let [fullname (string/format "%s/%s" fltk-build-dir fname)
          outname (string/format "./jfltk/%s" fname)]
      (when (sh/exists? fullname)
        (sh/copy-file fullname outname)))))

(defn- clean-static-libs []
  (loop [fname :in (sh/list-all-files "jfltk")]
    (each libname fltk-libs
      (when (string/has-suffix? libname fname)
        (sh/rm fname)))))

(defn- build-cfltk
  []
  (update-submodules)
  (clean-static-libs)
  (build-cfltk-fn)
  (copy-static-libs))

(task "pre-build" [] (build-cfltk))

(task "clean-cfltk" [] (clean-cfltk-fn))

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

(defn- fltk-link-libs []
  (if (sh/exists? fltk-config)
    (if (not (= (os/which) :windows))
      (do
        (def out (sh/exec-slurp fltk-config "--use-gl" "--use-images" "--use-glut" "--use-forms" "--use-cairo" "--ldflags"))
        (string/split " " out))
      @[])
    (do (build-cfltk)
      (fltk-link-libs))))

(defn- gen-lflags []
  (if (= (os/which) :windows)
    windows-fltk-link-libs
    (array/join @[cfltk-lib-path "-lcfltk2"] (fltk-link-libs))))

(var cppflags nil)
(def- lflags (gen-lflags))
(case (os/which)
  :windows (set cppflags @["/bigobj" "-I./cfltk/include" "-DCFLTK_USE_GL" "-DFLTK_BUILD_FORMS"])
  :macos (set cppflags @["-I./cfltk/include" "-DCFLTK_USE_GL" "-DFLTK_BUILD_FORMS"])
  :linux (set cppflags @["-fPIC" "-I./cfltk/include" "-DCFLTK_USE_GL" "-DFLTK_BUILD_FORMS"]))

(declare-source
  :source ["jfltk"])

(declare-native
  :name "jfltk/widgets"
  :source @["c/module.cpp"]
  :c++flags cppflags
  :lflags lflags)

# create a new task to run the ldflags fixup
(task "fix-up-ldflags" [] (jnt/fix-up-ldflags "jfltk" "widgets.meta.janet"))

# attach this task to the post-install hook
(task "post-install" ["fix-up-ldflags"])
