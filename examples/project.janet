(import jfltk)

(import spork/sh)
(import spork/path)

(setdyn :verbose true)

(declare-project
  :name "fltk-janet-examples"
  :description ```Janet wrapper examples for FLTK```
  :author ```Bob Tolbert```
  :dependencies @["spork"]
  :version "0.1.0")

(def build-type (string (dyn *build-type* :release)))

(setdyn *build-type* :release)

# get lflags from jfltk module?
(def- lflags jfltk/lflags)

(def- examples
  (do
    (var files @[])
    (loop [fname :in (os/dir ".")]
      (when (and (string/has-suffix? ".janet" fname) (not (= fname "project.janet")))
        (array/push files fname)))
    files))

(setdyn :build-dir "_build")

(loop [fname :in examples]
  (declare-executable
    :name (string/replace ".janet" "" fname)
    :entry fname
    :libs lflags
    ))
