# NoNodePhysics2D

[中文](README.md)

Implement physics functionality that bypasses the node tree through a global singleton to optimize performance.


## Refactoring in Progress

- ~~Due to unspeakable bugs and potential unexpected behaviors, the QuickArea feature no longer supports detecting other areas and entities, and is changed to only be detected~~
  - ~~Considering discontinuing the use of the global manager~~
- Detection-related functionalities are transferred to QuickCast-related classes
  - ShapeCast
  - RayCast
- Potential future: C++ implementation

## Godot Version

Under development. It is expected to support version 4.4 and above.
