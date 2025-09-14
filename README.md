# NoNodePhysics

[English](README_EN.md)

通过全局单例，实现绕过节点树的物理功能，以优化性能。

## GlobalAreaManager
全局Area管理器。其创建的 QuickArea ，既可以和同样由该管理器生成的Area正常碰撞，同时也可以和外部的Area2D节点碰撞。

核心功能是碰撞检测。为了性能，部分Area2D节点功能未实现。

关于“和外部的Area2D节点碰撞”：
- 一方面， QuickArea 可以正常检测到外部Area2D节点
- 另一方面，Area2D节点也可以检测到 QuickArea ，但只会`准确`发送`形状级`的信号

### QuickArea
目前QuickArea实现：
- 核心功能关注碰撞检测和信号发送，不关注重力阻尼等属性设置（后者在测试中会拖慢速度，且个人一般不使用相关属性）
	- 未来会提供封装方法供调整
- 信号系统关注整体Area的进出，没有形状级信号
- 目前area只支持`一个形状`

### Manager

- 设定为Area2D类型，主要是为了和外部Area2D碰撞时，不需要修改信号函数参数类型

## TODO
- 全局查询管理器
	- 目标：代替RayCast2D和ShapeCast2D
- 全局物理实体管理器
	- 较为复杂，暂缓实现

## 已知问题
- 碰撞数量较多时，Godot编辑器调试器会失败
