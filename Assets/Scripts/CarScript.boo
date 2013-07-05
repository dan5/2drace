import UnityEngine

class CarScript (MonoBehaviour):
  public steering as GameObject
  angle = 0.0f
  v = 0.0f

  def Start():
    pass
  
  def Update():
    script = steering.GetComponent[of SteeringController]()
    angle += script.angle * 4.0f * Time.deltaTime
    transform.rotation = Quaternion.Euler(0, angle * Rad2Deg, 0);

    t = script.power * 20.0f
    v += (t - v) * 0.5f * Time.deltaTime
    v = Mathf.Max(v, 0)
    vx = v * Mathf.Sin(angle)
    vz = v * Mathf.Cos(angle)
    transform.position.x += vx * Time.deltaTime
    transform.position.z += vz * Time.deltaTime

    Camera.main.transform.position.x = transform.position.x
    Camera.main.transform.position.z = transform.position.z

  def _FixedUpdate():
    H = 1.0F
    if transform.position.y < H:
      rigidbody.AddForce(0, 20.0f * (H - transform.position.y), 0)

    vec = rigidbody.velocity * -4.0F
    vec.y = 0
    rigidbody.AddForce(vec)

    v = Input.GetAxis("Vertical") * 40.0F
    v = 20
    r = transform.localEulerAngles.y * Mathf.Deg2Rad
    vx = v * Mathf.Sin(r)
    vz = v * Mathf.Cos(r)
    rigidbody.AddForce(vx, 0, vz)

    rv = rigidbody.angularVelocity.y * -1.0F
    rigidbody.AddTorque(0, rv, 0)

    //rv = Input.GetAxis("Horizontal")
    script = steering.GetComponent[of SteeringController]()
    rv = script.angle / PI
    rigidbody.AddTorque(0, rv * 2.0F, 0)
