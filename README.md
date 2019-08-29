# 一键 V2ray websocket + TLS

一键就完事了，扫描二维码 或者 复制 vmess链接 无需关心复杂的V2ray 配置，websocket + tls 更安全，伪装更好。

* 自动生成 UUID （调用系统UUID库）
* 默认使用 caddy 自动获取证书
* 自动生成 安卓 v2rayNG vmess链接
* 自动生成 iOS shadowrocket vmess链接
* 自动生成 iOS 二维码

## 使用方法

 * 提前安装好docker https://yeasy.gitbooks.io/docker_practice/install/ubuntu.html 这个链接有安装教程（ubuntu 的，其他发行版本也是有的）
 * 解析好域名 确认 你的域名正确解析到了你安装的这台服务器
 * 会占用 443 和 80 端口请提前确认没有跑其他的业务 （ lsof -i:80 和 lsof -i:443 能查看）
 * 请将下面命令中的 YOURDOMAIN.COM（域名）替换成自己的域名（此IP解析的域名）！！！

```
sudo DOMAIN=YOURDOMAIN.COM \
docker run -d --rm --name v2ray_ws \
-p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy \
qstevo/v2ray_ws_caddy:latest $DOMAIN V2RAY_WS\
&& sleep 5s && sudo docker logs v2ray
```
* 如果你想指定固定 uuid 的话， $UUID 这个 uuid 改为你自己的，https://www.uuidgenerator.net/ 这个网站可以生成随机 uuid。
```
sudo DOMAIN=YOURDOMAIN.COM UUID=$(uuid -v4) \
docker run -d --rm --name v2ray_ws \
-p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy \
qstevo/v2ray_ws_caddy:latest $DOMAIN V2RAY_WS $UUID\
&& sleep 5s && sudo docker logs v2ray
```

* 命令执行完会显示链接信息，如果想查看链接信息，执行下面命令即可
```
sudo docker logs v2ray_ws
```
* 想停止这个 docker 和服务
```
sudo docker stop v2ray_ws
```

有问题欢迎提issue， 感谢大家。参考了 caddy docker 和 v2ray 的 dockerfile 感谢！

