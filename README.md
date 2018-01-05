# SkeletonProcVisualPinball10

A basic game using VP 10.4. VBS Scripts version 3.55 
Using this Fork https://github.com/horseyhorsey/PyProcGameHD-SkeletonGame/tree/dev
  
#### vp_game_map.yaml

```
SkeletonProc:
  path: /../games/SkeletonGameVisualPinball10
  kls: Game.Game
  yaml: /../games/SkeletonGameVisualPinball10/config/machine.yaml 
```

### VP Launching (optional)
See the provided Autohotkey script (VPLoader.ahk). This invokes ProcBefore.exe which brings the SDL2 window above VP, making sure it's always on top of the screen

To adjust the position and size of the display window, edit config.yaml.
