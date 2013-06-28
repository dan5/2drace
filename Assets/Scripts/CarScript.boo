import UnityEngine

class CarScript (MonoBehaviour):

  def Start():
    pass
  
  def Update():
    Camera.main.transform.position.x = transform.position.x
    Camera.main.transform.position.z = transform.position.z

  def FixedUpdate():
    H = 1.0F
    if transform.position.y < H:
      rigidbody.AddForce(0, 20.0f * (H - transform.position.y), 0)

    vec = rigidbody.velocity * -4.0F
    vec.y = 0
    rigidbody.AddForce(vec)

    v = Input.GetAxis("Vertical") * 40.0F
    r = transform.localEulerAngles.y * Mathf.Deg2Rad
    vx = v * Mathf.Sin(r)
    vz = v * Mathf.Cos(r)
    rigidbody.AddForce(vx, 0, vz)

    rv = rigidbody.angularVelocity.y * -1.0F
    rigidbody.AddTorque(0, rv, 0)

    rv = Input.GetAxis("Horizontal")
    rigidbody.AddTorque(0, rv * 1.0F, 0)
