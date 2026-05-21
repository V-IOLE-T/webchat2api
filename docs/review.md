# Review

当前没有阻塞发布的未解决审查项。

## 已归档

- [resolved] Poll when the image tool was invoked
  `services/protocol/conversation.py`
  该问题已在当前实现中处理：图片生成/编辑的延迟结果会继续轮询会话，避免在 `tool_invoked: true` 后直接返回中间文本。
