(use ../_build/release/jfltk)

(var count 0)

(defn clicker [widget &opt data]
  (set count (inc count))
  (when (not (nil? data))
    (Fl_Window_set_label data "it worked"))
  (Fl_Widget_set_label widget (string/format "count: %d" count)))

(Fl_init_all)
(Fl_register_images)
(Fl_lock)

(def w (Fl_Window_new_wh 400 300 "Janet"))
(def b (Fl_Button_new 160 210 80 40 "Click me"))

(Fl_Window_end w)
(Fl_Window_show w)

(def cb (make_callback clicker w))

(pp cb)

(Fl_Button_set_callback b cb)

(Fl_run)
