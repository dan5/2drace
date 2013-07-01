var playerObj : GameObject;
var aTexture : Texture;

function OnGUI () {
  var w = Screen.width * 0.3f;
  var x = Screen.width / 2 - w / 2;
  var y = Screen.height - w * 1.5f;
  var pivotPoint : Vector2 = Vector2(x + w / 2, y + w / 2);
  var angleY : float = playerObj.transform.localEulerAngles.y;
  GUIUtility.RotateAroundPivot(angleY, pivotPoint);
  GUI.DrawTexture(Rect(x, y, w, w), aTexture);
}
