(use ../_build/release/jfltk)

(defn cb [widget event obj]
  (case event
    1 (pp "HELLO")
    true (pp "GOODBYE")))

(def w (Fl_Window_new 100 100 400 300 "handler"))
(def f (Fl_Box_new 0 0 400 200 ""))
(def b (Fl_Button_new 160 210 80 40 "Click me"))
(Fl_Window_end w)
(Fl_Window_show w)
(Fl_Button_handle b cb f)
(Fl_run)