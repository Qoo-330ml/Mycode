# Caddy 微信代理安装脚本

这是一个用于安装 Caddy 并配置微信代理的小脚本。通过该脚本，您可以快速搭建一个用于代理微信接口的服务器。

## 安装步骤

1. 拉取脚本：

```shell
curl -LJO https://raw.githubusercontent.com/Qoo-330ml/Caddy_for_wechat/main/caddy_for_wechat.sh
```

2. 赋权：

```shell
chmod +x caddy_for_wechat.sh
```

2. 运行：

```shell
sh caddy_for_wechat.sh
```




注意：请确保在执行脚本之前具有管理员权限，在输入端口的时候请确保这个端口没有被其他软件占用（例如输入netstat -tunlp|grep 80可以检查80端口的使用情况）。

## 贡献

欢迎贡献代码和提出问题。您可以通过提交 Issue 或 Pull Request 来参与贡献。

## 许可证

本项目采用 [MIT 许可证](LICENSE)。
