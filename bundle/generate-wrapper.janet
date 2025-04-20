(import spork/sh)
(use ./utils)

(var- python nil)

(defn- check-python-version [py]
  (when py
    (def out (sh/exec-slurp py "--version"))
    (when out
      (def parts (string/split " " out))
      (when (and (= (length parts) 2) (string/has-prefix? "3" (get parts 1)))
        (break true))))
  false)

(defn- find-python []
  (def py (sh/which "python"))
  (def py3 (sh/which "python3"))
  (when py3
    (set python py3))
  (when py
    (set python py))
  (check-python-version python))

(if (not (find-python))
  (error-exit "Unable to find Python 3 executable."))

(sh/exec python "scripts/wrap_fltk.py")