import UnityEngine

class CarScript (MonoBehaviour):
  public WheelFronLeft as GameObject
  public WheelFronRight as GameObject
  public steering as GameObject
  public speedText as GUIText
  public engineSpeedText as GUIText
  angle = 0.0f
  v = 0.0f
  vx = 0.0f
  vz = 0.0f
  before_spin_timer = 0.0f
  spin_timer = 0.0f
  spin_angle = 0.0f
  grip = 8.0f

  GRIP = 2.0f
  SPEED = 30.0f
  is_crushed = false
  default_camera_position as Vector3

  def Start():
    default_camera_position = Camera.main.transform.position

  def OnCollisionEnter():
    print("hit")
    is_crushed = true

  def OnTriggerEnter(col as Collider):
    print("tri hit")
    //rigidbody.isKinematic = false
    //col.isTrigger = false
    is_crushed = true
    spin_timer = 0.1f + Mathf.Sqrt(vx * vx + vz * vz) * 0.02f
    print(spin_timer)
    dx = transform.position.x - col.transform.position.x
    dz = transform.position.z - col.transform.position.z
    //vx *= -0.25f
    //vz *= -0.25f
    vx = dx
    vz = dz
  
  def update_wheel_angle(angle as single):
    a = steering.transform.localEulerAngles.y
    if a > 180:
      a -= 360
    angle = transform.localEulerAngles.y + a * 0.75f
    WheelFronLeft.transform.rotation = Quaternion.Euler(270, 180 + angle, 0)
    WheelFronRight.transform.rotation = Quaternion.Euler(270, angle, 0)

  def Update():
    //unless rigidbody.isKinematic:
    //if is_crushed:
    //  return
    script = steering.GetComponent[of SteeringController]()
    update_wheel_angle(script.angle * 0.4f)
    if spin_timer > 0:
      v = 0
    else:
      is_crushed = false
    t = script.power * SPEED * (1.0f - Mathf.Abs(script.angle) / PI)
    v += (t - v) * 0.5f * Time.deltaTime
    v = Mathf.Max(v, 0)
    p = Mathf.Abs(v * v * script.angle)
    if spin_timer > 0:
      target_grip = 0.2f
      _angle = 6.0f * Time.deltaTime * (spin_timer + 0.1f) * 2.0f
      if spin_angle < 0:
        _angle *= -1
      angle += _angle
      spin_timer -= Time.deltaTime
    else:
      target_grip = 8.0f
      rate = GRIP
      if p > 200.0f * rate:
        target_grip -= p / (40.0f * rate)
        if p > 400.0f * rate:
          before_spin_timer += Time.deltaTime
          if before_spin_timer > 0.25f:
            spin_angle = script.angle
            spin_timer = 0.8f
        else:
          before_spin_timer = 0
        // v の減速
        //v -= 80.0f * Time.deltaTime
        //todo: 進んでいる方向と実際の向きが大きくずれた時に減速
      else:
        before_spin_timer = 0
      // 曲がるには速度が必要
      a = script.angle * 4.0f
      if Mathf.Abs(a) > v / 4:
        if a > 0:
          a = v / 4
        else:
          a = -v / 4
      angle += a * Time.deltaTime
    if grip > target_grip:
      grip = target_grip
    else:
      grip += 2.0f * Time.deltaTime
    grip = Mathf.Max(grip, 0.2f)
    grip = Mathf.Min(grip, 8.0f)
    vx += (v * Mathf.Sin(angle) - vx) * grip * Time.deltaTime
    vz += (v * Mathf.Cos(angle) - vz) * grip * Time.deltaTime
    transform.position.x += vx * Time.deltaTime
    transform.position.z += vz * Time.deltaTime

    transform.rotation = Quaternion.Euler(0, angle * Rad2Deg, 0)

    sp as int = Mathf.Sqrt(vx * vx + vz * vz) * 10
    speedText.guiText.text = sp.ToString()
    _v as int = v * 10
    engineSpeedText.guiText.text = _v.ToString()

    Camera.main.transform.position.x = transform.position.x
    Camera.main.transform.position.z = transform.position.z + default_camera_position.z
