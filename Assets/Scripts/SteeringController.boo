import UnityEngine
import Mathf

class SteeringController (MonoBehaviour):
  use_mouse = false
  is_free = false
  public scoreObj as GUIText

  w as single = Screen.width * 0.3f
  cx as single = Screen.width / 2
  cy as single = w
  last_dir as single
  angle_ = 0.0f
  
  angle as single:
    get:
      return angle_

  def Start():
    //ifdef not UNITY_IPHONE or UNITY_EDITOR:
    //  use_mouse = true
    use_mouse = false

  def Update():
    flick_controller()

  steering_touch as MyTouch = null
  engine_touch as MyTouch = null
  def flick_controller():
    MyTouch.input_touch_device()
    if use_mouse:
      steering_touch = MyTouch.touches[0]
    else:
      for touch in MyTouch.touches:
        if touch.phase == "Began" or touch.phase == "Moved":
          if touch.position.y / Screen.height < 0.5f:
            steering_touch = touch
            if engine_touch == touch:
              engine_touch = null
          else:
            engine_touch = touch
            if steering_touch == touch:
              steering_touch = null
    steering_controller(steering_touch)
    scoreObj.guiText.text = MyTouch.count.ToString()

  def steering_controller(touch as MyTouch):
    if touch == null:
      is_free = true
    elif touch.phase == "Ended" and not is_free:
      is_free = true
      scoreObj.guiText.text = Screen.width.ToString()
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

  def rad_round(r as single, target as single):
    while r - target >  PI:
      r -= PI * 2
    while r - target < -PI:
      r += PI * 2
    return r

class MyTouch:
  static touches_ = (MyTouch(), MyTouch())
  static count_ = 0
  public phase as string
  public position = Vector3.zero

  static touches:
    get:
      return touches_

  static count:
    get:
      return count_

  // for mouse
  static last_mouse_position = Vector3.zero
  static is_touched = false

  static def input_touch_device():
    use_mouse = Input.touchCount == 0
    if use_mouse:
      count_ = 1
      touches_[0].phase = null
      touches_[0].position = Input.mousePosition
      if (Input.GetMouseButtonDown(0)):
        touches_[0].phase = "Began"
        is_touched = true
      if (Input.GetMouseButtonUp(0)):
        touches_[0].phase = "Ended"
        is_touched = false
      if (last_mouse_position != Input.mousePosition):
        if (is_touched):
          touches_[0].phase = "Moved"
        last_mouse_position = Input.mousePosition
    /*
    TouchPhase.Began タッチの開始
    TouchPhase.Ended タッチの終了
    TouchPhase.Moved 移動中
    TouchPhase.Stationary タッチが継続中の場合(非移動中)
    TouchPhase.Canceled タッチがキャンセルになった場合
    */
    else:
      count_ = Input.touchCount
      for i in range(len(touches_)):
        if i < count_:
          touch = Input.GetTouch(i)
          touches_[i].position = touch.position
          if (touch.phase == TouchPhase.Began):
            touches_[i].phase = "Began"
          elif (touch.phase == TouchPhase.Ended):
            touches_[i].phase = "Ended"
          elif (touch.phase == TouchPhase.Moved):
            touches_[i].phase = "Moved"
          elif (touch.phase == TouchPhase.Canceled):
            touches_[i].phase = "Canceled"
          else:
            touches_[i].phase = null
            print("other")
        else:
          touches_[i].phase = null
          touches_[i].position = Vector3.zero
