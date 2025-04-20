(use jfltk)

(def dim 200)
(def factor 1.3)

(defn cb [w data]
  (Fl_Window_hide (Fl_Widget_window w)))

#################
# custom FL_Box by creating default box and adding
# a new handler and/or draw method

# some globals to store state between events
(var fromx 0)
(var fromy 0)
(var winx 0)
(var winy 0)

(defn store-mouse-down [win]
  (set fromx (Fl_event_x_root))
  (set fromy (Fl_event_y_root))
  (set winx (Fl_Window_x_root win))
  (set winy (Fl_Window_y_root win))
  1)

(defn move-window [win]
  (def deltax (- (Fl_event_x_root) fromx))
  (def deltay (- (Fl_event_y_root) fromy))
  (Fl_Widget_resize win (+ winx deltax) (+ winy deltay)
                    (Fl_Window_width win) (Fl_Window_height win))
  1)

(defn dragbox-handler [box event &opt obj]
  (def win (Fl_Widget_window box))
  (case event
    Fl_Event_Push (store-mouse-down win)
    Fl_Event_Drag (move-window win)
    true (Fl_Box_handle box event obj)))

(defn make-dragbox [x y w h]
  # make a default Fl_Box
  (def box (Fl_Box_new x y w h ""))
  # create a custom callback
  (def cb (make_custom_callback dragbox-handler box))
  # assign as the handle callback for our box
  (Fl_Box_handle box cb)
  box)
#################

(defn shrink [w data]
  (def win (Fl_Widget_window w))
  (def old (Fl_Window_width win))
  (def new-dim (div old factor))
  (def x (Fl_Window_x_root win))
  (def y (Fl_Window_y_root win))
  (Fl_Widget_resize win x y new-dim new-dim)
  (when (< (Fl_Window_width win) data)
    (Fl_Button_deactivate w)))

(defn enlarge [w shrink-button]
  (def win (Fl_Widget_window w))
  (def old (Fl_Window_width win))
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
  (Fl_Double_Window_set_shape win img)

  # make a custom Fl_Box over the entire window to handle drag events
  (def box (make-dragbox 0 0
                         (Fl_Double_Window_width win)
                         (Fl_Double_Window_height win)))

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
