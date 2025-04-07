(use ../_build/release/jfltk)

(defn clicker [widget &opt data]
  (Fl_Widget_set_label widget "Hello!"))

(Fl_init_all)
(Fl_register_images)
(Fl_lock)

(def w (Fl_Window_new_wh 400 300 "Janet"))
(def b (Fl_Button_new 160 210 80 40 "Click me"))

(Fl_Window_end w)
(Fl_Window_show w)

# (Fl_Button_set_callback b clicker)

(Fl_run)
