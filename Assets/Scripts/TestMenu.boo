import UnityEngine

class TestMenu (MonoBehaviour):

  mainmenuSkin as GUISkin

  def OnGUI():
    GUI.skin = mainmenuSkin
    // 1
    for i in range(1):
      scene = string.Format("Game", i + 1)
      if GUI.Button (Rect (4 + i * 70, 4, 64, 32), scene):
        Application.LoadLevel(scene)
