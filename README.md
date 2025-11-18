# NoNodePhysics2D

[English](README_EN.md)

通过 RefCounted ，实现绕过节点树的物理功能，以优化性能。

## 开发ING

### 计划
- 检测相关功能移交Cast相关类负责
	- ShapeCast
	- RayCast
- 可能的未来：
	- CPP实现（希望可以“抄”源代码）
- 重新评估Area的类命名和检测功能

### 目前进展
- 参考Godot源码，重构了Instance2D，使之支持局部变换和全局变换（提供base_transform）
- 提供一个Instance2D的测试用例，同时展示了Instance2D“追踪”父持有者的变换的方法

## Godot版本

开发中。使用4.5.1，但预计4.4+都支持。
