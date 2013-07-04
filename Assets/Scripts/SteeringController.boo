import UnityEngine
import Mathf

class SteeringController (MonoBehaviour):
  phase as string
  touches = (MyTouch(), MyTouch())

  use_mouse = false
  is_free = false
  public score as GUIText

  w as single = Screen.width * 0.3f
  cx as single = Screen.width / 2
  cy as single = w
  last_dir as single
  angle_ = 0.0f
  
  angle as single:
    get:
      return angle_

  def Start():
    ifdef not UNITY_IPHONE or UNITY_EDITOR:
      use_mouse = true

  def Update():
    flick_controller()

  steering_touch as MyTouch = null
  engine_touch as MyTouch = null
  def flick_controller():
    input_touch_device()
    if use_mouse:
      steering_touch = touches[0]
    else:
      for touch in touches:
        if touch.is_active and (touch.phase == "Began" or touch.phase == "Moved"):
          if touch.position.y / Screen.height < 0.5f:
            steering_touch = touch
            if engine_touch == touch:
              engine_touch = null
          else:
            engine_touch = touch
            if steering_touch == touch:
              steering_touch = null
    steering_controller(steering_touch)
    score.guiText.text = MyTouch.count.ToString()

  def steering_controller(touch as MyTouch):
    if touch == null:
      is_free = true
    elif touch.phase == "Ended" and not is_free:
      is_free = true
      score.guiText.text = Screen.width.ToString()
    elif touch.phase == "Began" or touch.phase == "Moved":
      dx = touch.position.x - cx
      dy = touch.position.y - cy
      dist = Vector2.Distance(Vector2.zero, Vector2(dx, dy))
      if dist < w * 0.35f:
        is_free = true
      elif is_free:
        is_free = false
        dir = Atan2(dx, dy)
        last_dir = dir
      else:
        dir = Atan2(dx, dy)
        dir = rad_round(dir, last_dir)
        angle_ += (dir - last_dir)
        MAX = PI / 2
        angle_ = Max(angle_, -MAX)
        angle_ = Min(angle_, MAX)
      last_dir = dir
    if is_free:
      BORDER_R = 10.0f * Deg2Rad
      SPEED = PI * 2.0f
      if angle_ > BORDER_R:
        angle_ -= SPEED * Time.deltaTime
      elif angle_ < -BORDER_R:
        angle_ += SPEED * Time.deltaTime
      else:
        angle_ += (0 - angle_) * 0.2f
    transform.rotation = Quaternion.Euler(0, angle_ * Rad2Deg, 0);

  // for mouse
  last_mouse_position = Vector3.zero
  is_touched = false
  def input_touch_device():
    touches[0].phase = null
    if use_mouse:
      MyTouch.count = 1
      touches[0].position = Input.mousePosition
      if (Input.GetMouseButtonDown(0)):
        touches[0].phase = "Began"
        is_touched = true
      if (Input.GetMouseButtonUp(0)):
        touches[0].phase = "Ended"
        is_touched = false
      if (last_mouse_position != Input.mousePosition):
        if (is_touched):
          touches[0].phase = "Moved"
        last_mouse_position = Input.mousePosition
    /*
    TouchPhase.Began タッチの開始
    TouchPhase.Ended タッチの終了
    TouchPhase.Moved 移動中
    TouchPhase.Stationary タッチが継続中の場合(非移動中)
    TouchPhase.Canceled タッチがキャンセルになった場合
    */
    else:
      count = Input.touchCount
      MyTouch.count = count
      for i in range(len(touches)):
        if i < count:
          touch = Input.GetTouch(i)
          touches[i].is_active = true
          touches[i].position = touch.position
          if (touch.phase == TouchPhase.Began):
            touches[i].phase = "Began"
          elif (touch.phase == TouchPhase.Ended):
            touches[i].phase = "Ended"
          elif (touch.phase == TouchPhase.Moved):
            touches[i].phase = "Moved"
          elif (touch.phase == TouchPhase.Canceled):
            touches[i].phase = "Canceled"
          else:
            print("other")
        else:
          touches[i].is_active = false
          touches[i].position = Vector3.zero


  def rad_round(r as single, target as single):
    while r - target >  PI:
      r -= PI * 2
    while r - target < -PI:
      r += PI * 2
    return r

class MyTouch:
  public static count = 0
  public is_active as bool
  public phase as string
  public position = Vector3.zero
