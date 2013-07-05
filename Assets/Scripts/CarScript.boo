import UnityEngine

class CarScript (MonoBehaviour):
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

  GRIP = 1.0f
  SPEED = 30.0f

  def Start():
    pass
  
  def Update():
    script = steering.GetComponent[of SteeringController]()
    if spin_timer > 0:
      v = 0
    t = script.power * SPEED * (1.0f - Mathf.Abs(script.angle) / PI)
    v += (t - v) * 0.5f * Time.deltaTime
    v = Mathf.Max(v, 0)
    p = Mathf.Abs(v * v * script.angle)
    if spin_timer > 0:
      spin_timer -= Time.deltaTime
      target_grip = 0.2f
      _angle = 6.0f * Time.deltaTime
      if spin_angle < 0:
        _angle *= -1
      angle += _angle
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

    transform.rotation = Quaternion.Euler(0, angle * Rad2Deg, 0);

    sp as int = Mathf.Sqrt(vx * vx + vz * vz) * 10
    speedText.guiText.text = sp.ToString()
    _v as int = v * 10
    engineSpeedText.guiText.text = _v.ToString()

    Camera.main.transform.position.x = transform.position.x
    Camera.main.transform.position.z = transform.position.z - 2.5
