#!/bin/bash
# FILE="/etc/Caddy"
domain="$1"
psname="$2"
uuid=""
endpoint="oa77z27t"
if  [ ! "$3" ] ;then
    uuid=$(uuidgen)
    echo "uuid 将会系统随机生成"
else
    uuid="$3"
fi
cat > /etc/Caddyfile <<'EOF'
domain
{
  log ./caddy.log
  proxy /path_string :10086 {
    websocket
    header_upstream -Origin
  }
}

EOF
sed -i "s/domain/${domain}/" /etc/Caddyfile
sed -i "s/path_string/${endpint}/" /etc/Caddyfile

# v2ray
cat > /etc/v2ray/config.json <<'EOF'
{
  "log": {
    "loglevel": "info",
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log"
  },
  "inbounds": [
    {
      "port": 10086,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "uuid",
            "alterId": 16
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
        "path": "/path_string"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}

EOF

sed -i "s/uuid/${uuid}/" /etc/v2ray/config.json
sed -i "s/path_string/${endpint}/" /etc/v2ray/config.json

cat > /srv/sebs.js <<'EOF'
 {
    "add":"domain",
    "aid":"0",
    "host":"",
    "id":"uuid",
    "net":"ws",
    "path":"/path_string",
    "port":"443",
    "ps":"sebsclub",
    "tls":"tls",
    "type":"none",
    "v":"2"
  }
EOF

if [ "$psname" != "" ] && [ "$psname" != "-c" ]; then
  sed -i "s/sebsclub/${psname}/" /srv/sebs.js
  sed -i "s/domain/${domain}/" /srv/sebs.js
  sed -i "s/uuid/${uuid}/" /srv/sebs.js
  sed -i "s/path_string/${endpint}/" /srv/sebs.js
else
  $*
fi
pwd
cp /etc/Caddyfile .
nohup /bin/parent caddy  --log stdout --agree=false &
echo "配置 JSON 详情"
echo " "
cat /etc/v2ray/config.json
echo " "
node v2ray.js
/usr/bin/v2ray -config /etc/v2ray/config.json
