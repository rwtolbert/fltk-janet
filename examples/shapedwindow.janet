(use ../fltk-janet/jfltk)
(use ../fltk-janet/enums)

(def dim 200)
(def factor 1.3)

(defn cb [w data]
  (Fl_Window_hide (Fl_Widget_window w)))

(defn shrink [w data]
  (def win (Fl_Widget_window w))
  (def old (Fl_Window_decorated_w win))
  (def new-dim (div old factor))
  (def x (Fl_Window_x_root win))
  (def y (Fl_Window_y_root win))
  (Fl_Widget_resize win x y new-dim new-dim)
  (when (< (Fl_Window_decorated_w win) data)
    (Fl_Button_deactivate w)))

(defn enlarge [w shrink-button]
  (def win (Fl_Widget_window w))
  (def old (Fl_Window_decorated_w win))
  (def new-dim (math/floor (* old factor)))
  (def x (Fl_Window_x_root win))
  (def y (Fl_Window_y_root win))
  (Fl_Widget_resize win x y new-dim new-dim)
  (Fl_Button_activate shrink-button))

(defn prepare-shape [dim]
  (def surf (Fl_Image_Surface_new dim dim 0))
  (Fl_Surface_Device_push_current surf)
  (Fl_set_color_int Fl_Color_Black)
  (Fl_rectf -1 -1 (+ dim 2) (+ dim 2))
  (Fl_set_color_int Fl_Color_White)
  (Fl_pie 2 2 (- dim 4) (- dim 4) 0 360)
  (Fl_set_color_int Fl_Color_Black)
  (Fl_pie (* 0.7 dim) (/ dim 2) (/ dim 4) (/ dim 4) 0 360)
  (def img (Fl_Image_Surface_image surf))
  (Fl_Image_Surface_delete surf)
  (Fl_Surface_Device_pop_current)
  img)

(defn main [&]
  (Fl_init_all)
  (Fl_register_images)
  (Fl_lock)

  (def win (Fl_Double_Window_new 100 100 dim dim "Testing1"))
  (def img (prepare-shape dim))
  (pp img)
  (Fl_Double_Window_set_shape win img)

  (def g (Fl_Group_new 10 20 80 20 ""))
  (Fl_Group_set_box g Fl_BoxType_NoBox)
  (def b (Fl_Button_new 10 20 80 20 "Close"))
  (def button_cb (make_callback cb b))
  (Fl_Button_set_callback b button_cb)
  (Fl_Group_end g)
  (Fl_Group_resizable g g)

  (def g2 (Fl_Group_new 60 70 80 40 "Drag me"))
  (Fl_Group_set_box g2 Fl_BoxType_NoBox)
  (Fl_Group_set_align g2 Fl_Align_Top)
  (def bs (Fl_Button_new 60 70 80 20 "Shrink"))
  (def shrink_cb (make_callback shrink dim))
  (Fl_Button_set_callback bs shrink_cb)

  (def be (Fl_Button_new 60 90 80 20 "Enlarge"))
  (def enlarge_cb (make_callback enlarge bs))
  (Fl_Button_set_callback be enlarge_cb)
  (Fl_Group_end g2)
  (Fl_Group_resizable g2 g2)

  (Fl_Double_Window_end win)
  (Fl_Double_Window_resizable win win)
  (Fl_Double_Window_show win)

  (Fl_run))
