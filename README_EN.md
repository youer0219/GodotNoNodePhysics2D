# NoNodePhysics2D

[中文](README.md)

Implement physics functionality bypassing the node tree via RefCounted to optimize performance.


## WORK IN PROGRESS

### Plans
- Hand over detection-related functions to Cast-related classes
  - ShapeCast
  - RayCast
- Possible future:
  - C++ implementation (hoping to "reference" the source code)
- Re-evaluate the class naming and detection functions of Area


### Current Progress
- Referenced Godot's source code, refactored Instance2D to support local and global transforms (providing base_transform)
- Provided a test case for Instance2D, which also demonstrates how Instance2D "tracks" the transform of its parent holder


## Godot Version

Under development. Using 4.5.1, but it is expected to support 4.4+.