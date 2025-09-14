# NoNodePhysics

[English](README_EN.md)

通过全局单例，实现绕过节点树的物理功能，以优化性能

## GlobalAreaManager

全局Area管理器。其创建的Area，既可以和同样由该管理器生成的Area正常碰撞，同时也可以和外部的Area2D节点碰撞。

关于“和外部的Area2D节点碰撞”：
- 一方面，area可以正常检测到外部Area2D节点，触发外部Area2D节点信号
- 另一方面，Area2D节点也可以检测到area，但只会`准确`发送`形状级`的信号

目前Area实现：
- 基本的检测功能已实现
- 未完全实现Area2D一样的信号系统
- 未直接支持Area2D的重力设置等功能，但可以通过area-rid+底层服务实现（也就是暂时没封装）
- 目前area只支持`一个形状`
- 目前area只关心`检测`，阻尼等属性的设置似乎在测试中会降低性能，暂时不考虑

未来：
- 会与Area2D节点行为更加一致
- 提供方法将Area2D节点和AreaInstance/AreaData相互转换

### Manager

- 设定为Area2D类型，主要是为了和外部Area2D碰撞时，不需要修改信号函数参数类型

## TODO
- 全局查询管理器
	- 目标：代替RayCast2D和ShapeCast2D
- 全局物理实体管理器
	- 较为复杂，暂缓实现
