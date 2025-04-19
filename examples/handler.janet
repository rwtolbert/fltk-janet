(use fltk)

(defn clicker [widget event &opt obj]
  (case event
    Fl_Event_Push (do
                    (Fl_Box_set_label obj "Hello")
                    1)
    true 0))


(def w (Fl_Window_new 100 100 400 300 "handler"))
(def f (Fl_Box_new 0 0 400 200 ""))
(def b (Fl_Button_new 160 210 80 40 "Click me"))
(Fl_Window_end w)
(Fl_Window_show w)

(def cb (make_custom_callback clicker f))

(Fl_Button_handle b cb)
(Fl_run)