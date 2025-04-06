(use ../_build/release/jfltk)

(pp (hello-native))

(Fl_init_all)
(Fl_register_images)
(Fl_lock)

(def w (Fl_Window_new_wh 400 300))

(Fl_Window_end w)
(Fl_Window_show w)

(Fl_run)
