# NoNodePhysics

[English](README_EN.md)

通过全局单例，实现绕过节点树的物理功能，以优化性能。

## Godot版本

4.5+  会用到抽象类

## GlobalAreaManager
全局Area管理器。其创建的 QuickArea ，既可以和同样由该管理器生成的Area碰撞，同时也可以和外部的Area2D节点碰撞。

核心功能是碰撞检测。为了性能，部分Area2D节点具有的功能未实现。
- 包括：阻尼、重力模式、优先级等。但提供set方法。

### QuickArea
目前 QuickArea 实现：
- 核心功能关注碰撞检测和信号发送，不关注重力阻尼等属性设置
- 信号系统关注整体Area的进出，没有形状级信号
- 目前area只支持`一个形状`

### Manager

- 其创建的 QuickArea 不附加节点，所以只会触发Area2D节点的形状级信号。

## TODO
- 全局查询管理器
	- 目标：代替RayCast2D和ShapeCast2D
- 全局物理实体管理器
	- 较为复杂，暂缓实现

## 已知问题
- 碰撞数量较多时，Godot编辑器调试器会失败
