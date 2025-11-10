# NoNodePhysics2D

[English](README_EN.md)

通过全局单例，实现绕过节点树的物理功能，以优化性能。


## 重构ING

- ~~由于不可名状的BUG和可能的意外行为，QuikArea功能不再支持检测其他区域和实体，改为仅被检测~~
	- ~~考虑不再使用全局管理器~~
- 检测相关功能移交QuikCast相关类负责
	- ShapeCast
	- RayCast
- 可能的未来：CPP实现

## Godot版本

开发中。预计4.4+应该都支持。
