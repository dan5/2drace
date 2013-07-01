import UnityEngine
import Mathf

class SteeringController (MonoBehaviour):
  phase as string
  touch_position = Vector3.zero
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

  def flick_controller():
    input_touch_device()
    if (phase == "Ended" and not is_free):
      is_free = true
      score.guiText.text = Screen.width.ToString()
    elif (phase == "Began" or phase == "Moved"):
      dx = touch_position.x - cx
      dy = touch_position.y - cy
      dist = Vector2.Distance(Vector2.zero, Vector2(dx, dy))
      if dist < w * 0.35f:
        is_free = true
      elif is_free:
        is_free = false
        dir = Atan2(dx, dy)
      else:
        dir = Atan2(dx, dy)
        dir = rad_round(dir, last_dir)
        angle_ += (dir - last_dir) * 0.6f
        angle_ = Max(angle_, -PI)
        angle_ = Min(angle_, PI)
      last_dir = dir
    if is_free:
      BORDER_R = 10.0f * Deg2Rad
      SPEED = PI
      if angle_ > BORDER_R:
        angle_ -= SPEED * Time.deltaTime
      elif angle_ < -BORDER_R:
        angle_ += SPEED * Time.deltaTime
      else:
        angle_ += (0 - angle_) * 0.2f
    transform.rotation = Quaternion.Euler(0, angle_ * Rad2Deg, 0);
    score.guiText.text = angle_.ToString()

  // for mouse
  last_mouse_position = Vector3.zero
  is_touched = false
  def input_touch_device():
    phase = null
    if use_mouse:
      touch_position = Input.mousePosition
      if (Input.GetMouseButtonDown(0)):
        phase = "Began"
        is_touched = true
      if (Input.GetMouseButtonUp(0)):
        phase = "Ended"
        is_touched = false
      if (last_mouse_position != Input.mousePosition):
        if (is_touched):
          phase = "Moved"
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
      if (count > 0):
        touch = Input.GetTouch(0)
        touch_position = touch.position
        if (touch.phase == TouchPhase.Began):
          phase = "Began"
        elif (touch.phase == TouchPhase.Ended):
          phase = "Ended"
        elif (touch.phase == TouchPhase.Moved):
          phase = "Moved"
        elif (touch.phase == TouchPhase.Canceled):
          phase = "Canceled"
        else:
          print("other")
      else:
        touch_position = Vector3.zero


  def rad_round(r as single, target as single):
    while r - target >  PI:
      r -= PI * 2
    while r - target < -PI:
      r += PI * 2
    return r

