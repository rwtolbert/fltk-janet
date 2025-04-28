(use jfltk)

(fl-init-all)
(fl-register-images)
(fl-lock)

(def *terminal-height* 120)

(var G-win nil)
(var G-box nil)
(var G-tty nil)

(defn timer-fn [data]
  (def current (os/strftime "%c"))
  (var lbl "Timer tick")
  (when data
    (set lbl data))
  (def msg (string/format "%s: \e[32m%s\e[0m\n" lbl current))
  (fl-terminal-printf G-tty msg)
  (fl-repeat-timeout 2.0 (make-timer-callback timer-fn data)))

(defn main [&]
  (fl-init-all)
  (fl-register-images)
  (fl-lock)

  (set G-win (fl-double-window-new 100 100 500 (+ 200 *terminal-height*) "terminal"))
  (fl-double-window-begin G-win)

  (set G-box (fl-box-new 0 0
                         (fl-double-window-width G-win) 200
                         "App GUI in this area.\nDebugging output below."))

  (set G-tty (fl-terminal-new 0 200
                              (fl-double-window-width G-win) *terminal-height* "Console"))
  (fl-terminal-set-ansi G-tty 1)
  (fl-terminal-set-align G-tty (bor Fl-Align-Top Fl-Align-Left))

  (fl-double-window-end G-win)
  (fl-double-window-resizable G-win G-win)
  (fl-double-window-show G-win)
  (fl-add-timeout 2.0 (make-timer-callback timer-fn "Ticker"))
  (fl-run))
