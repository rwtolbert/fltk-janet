(import spork/sh)

(defn error-exit [msg &opt code]
  (default code 1)
  (printf msg)
  (os/exit code))

(defn set-command [cmd todyn]
  "Look for executable on PATH"
  (if (sh/which cmd)
    (setdyn todyn (sh/which cmd))
    (error-exit (string/format "Unable to find command: %s" cmd))))