(use jfltk)

(defn clicker [widget event &opt obj]
  (case event
    Fl-Event-Push (do
                    (fl-box-set-label obj "hello")
                    1)
    true 0))


(def w (fl-window-new 100 100 400 300 "handler"))
(def f (fl-box-new 0 0 400 200 ""))
(def b (fl-button-new 160 210 80 40 "click me"))
(fl-window-end w)
(fl-window-show w)

(def cb (make-custom-callback clicker f))

(fl-button-handle b cb)
(fl-run)
