# NoNodePhysics2D

[English](README_EN.md)

通过 RefCounted ，实现绕过节点树的物理功能，以优化性能。


## 重构ING

| 重构过程中不考虑向后兼容性，直到1.0版本发布

- ~~由于不可名状的BUG和可能的意外行为，QuikArea功能不再支持检测其他区域和实体，改为仅被检测~~
	- ~~考虑不再使用全局管理器~~
- 检测相关功能移交QuikCast相关类负责
	- ShapeCast
	- RayCast
- 可能的未来：
	- CPP实现


- 目前命名采取Quick前缀，未来可能改变为NNP或其他或无，待定
- 可以考虑在高层有一个对碰撞层的公用set方法/检查方法，以检查值是否正确

## Godot版本

开发中。预计4.4+应该都支持。
