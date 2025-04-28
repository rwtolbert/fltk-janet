(use jfltk)

(def dim 200)
(def factor 1.3)

(defn cb [w data]
  (fl-window-hide (fl-widget-window w)))

#################
# custom FL_Box by creating default box and adding
# a new handler and/or draw method

# some globals to store state between events
(var fromx 0)
(var fromy 0)
(var winx 0)
(var winy 0)

(defn store-mouse-down [win]
  (set fromx (fl-event-x-root))
  (set fromy (fl-event-y-root))
  (set winx (fl-window-x-root win))
  (set winy (fl-window-y-root win))
  1)

(defn move-window [win]
  (def deltax (- (fl-event-x-root) fromx))
  (def deltay (- (fl-event-y-root) fromy))
  (fl-widget-resize win (+ winx deltax) (+ winy deltay)
                    (fl-window-width win) (fl-window-height win))
  1)

(defn dragbox-handler [box event &opt obj]
  (def win (fl-widget-window box))
  (case event
    Fl-Event-Push (store-mouse-down win)
    Fl-Event-Drag (move-window win)
    true (fl-box-handle box event obj)))

(defn make-dragbox [x y w h]
  # make a default fl-box
  (def box (fl-box-new x y w h ""))
  # create a custom callback
  (def cb (make-custom-callback dragbox-handler box))
  # assign as the handle callback for our box
  (fl-box-handle box cb)
  box)
#################

(defn shrink [w data]
  (def win (fl-widget-window w))
  (def old (fl-window-width win))
  (def new-dim (div old factor))
  (def x (fl-window-x-root win))
  (def y (fl-window-y-root win))
  (fl-widget-resize win x y new-dim new-dim)
  (when (< (fl-window-width win) data)
    (fl-button-deactivate w)))

(defn enlarge [w shrink-button]
  (def win (fl-widget-window w))
  (def old (fl-window-width win))
  (def new-dim (math/floor (* old factor)))
  (def x (fl-window-x-root win))
  (def y (fl-window-y-root win))
  (fl-widget-resize win x y new-dim new-dim)
  (fl-button-activate shrink-button))

(defn prepare-shape [dim]
  (def surf (fl-image-surface-new dim dim 0))
  (fl-surface-device-push-current surf)
  (fl-set-color-int Fl-Color-Black)
  (fl-rectf -1 -1 (+ dim 2) (+ dim 2))
  (fl-set-color-int Fl-Color-White)
  (fl-pie 2 2 (- dim 4) (- dim 4) 0 360)
  (fl-set-color-int Fl-Color-Black)
  (fl-pie (* 0.7 dim) (/ dim 2) (/ dim 4) (/ dim 4) 0 360)
  (def img (fl-image-surface-image surf))
  (fl-image-surface-delete surf)
  (fl-surface-device-pop-current)
  img)

(defn main [&]
  (fl-init-all)
  (fl-register-images)
  (fl-lock)

  (def win (fl-double-window-new 100 100 dim dim "Testing"))
  (def img (prepare-shape dim))
  (fl-double-window-set-shape win img)

  # make a custom fl_box over the entire window to handle drag events
  (def box (make-dragbox 0 0
                         (fl-double-window-width win)
                         (fl-double-window-height win)))

  (def g (fl-group-new 10 20 80 20 ""))
  (fl-group-set-box g Fl-BoxType-NoBox)
  (def b (fl-button-new 10 20 80 20 "Close"))
  (def button-cb (make-callback cb b))
  (fl-button-set-callback b button-cb)
  (fl-group-end g)
  (fl-group-resizable g g)

  (def g2 (fl-group-new 60 70 80 40 "Drag me"))
  (fl-group-set-box g2 Fl-BoxType-NoBox)
  (fl-group-set-align g2 Fl-Align-Top)

  (def bs (fl-button-new 60 70 80 20 "Shrink"))
  (def shrink-cb (make-callback shrink dim))
  (fl-button-set-callback bs shrink-cb)

  (def be (fl-button-new 60 90 80 20 "Enlarge"))
  (def enlarge-cb (make-callback enlarge bs))
  (fl-button-set-callback be enlarge-cb)
  (fl-group-end g2)
  (fl-group-resizable g2 g2)

  (fl-double-window-end win)
  (fl-double-window-resizable win win)
  (fl-double-window-show win)

  (fl-run))
