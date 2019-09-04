
### ServerSide
https://github.com/riobard/go-shadowsocks2

1st:

go get -u -v github.com/riobard/go-shadowsocks2

2nd:

cd /go/bin 
./go-shadowsocks2 -s ss://AES-256-CFB:abcd1234@:8488 -verbose

### Tun2socks-mobile-demo

*需要配置gomobile的环境，才能进行编译*

go-tun2socks-mobile 生成的framework 使用demo
tun2socks.go 根据报错做了简单的修改，注意对应参数个数以及依赖的go-tun2socks的方法是否发生了变化

Thx:
@ BearFree的VpnManager 
@ eycorsican/go-tun2socks / go-tun2socks-mobile 
@ riobard/go-shadowsocks2
@ SimpleTunnel 

TBD:
  1.没有仔细查api,需要做route traffic可能是需要设置代理添加规则（ss）
  ~~2.修改tun2socks.go 暴露出V🤮ray可以使用的方法，有空再来弄下~~

  V🤮ray 内存问题



*.go

```swift
package tun2socks

import (
	"time"
	"context"
	"strings"
	vcore "v2ray.com/core"
	vproxyman "v2ray.com/core/app/proxyman"
	vbytespool "v2ray.com/core/common/bytespool"
	"github.com/eycorsican/go-tun2socks/common/log"
	"github.com/eycorsican/go-tun2socks/core"
	"github.com/eycorsican/go-tun2socks/proxy/shadowsocks"
	"github.com/eycorsican/go-tun2socks/proxy/v2ray"
)

type PacketFlow interface {
	WritePacket(packet []byte)
}

var lwipStack core.LWIPStack

func InputPacket(data []byte) {
	lwipStack.Write(data)
}

func StartShadowsocks(packetFlow PacketFlow, proxyHost string, proxyPort int, proxyCipher, proxyPassword string) {
	if packetFlow != nil {
		lwipStack = core.NewLWIPStack()
		core.RegisterTCPConnHandler(shadowsocks.NewTCPHandler(core.ParseTCPAddr(proxyHost, uint16(proxyPort)).String(), proxyCipher, proxyPassword,nil))
		core.RegisterUDPConnHandler(shadowsocks.NewUDPHandler(core.ParseUDPAddr(proxyHost, uint16(proxyPort)).String(), proxyCipher, proxyPassword, 30*time.Second,nil,nil))
		core.RegisterOutputFn(func(data []byte) (int, error) {
			packetFlow.WritePacket(data)
			return len(data), nil
		})
	}
}

func StartV2Ray(packetFlow PacketFlow, configBytes []byte) {
	if packetFlow != nil {
		lwipStack = core.NewLWIPStack()

		core.SetBufferPool(vbytespool.GetPool(core.BufSize))

		v, err := vcore.StartInstance("json", configBytes)
		if err != nil {
			log.Fatalf("start V instance failed: %v", err)
		}

		sniffingConfig := &vproxyman.SniffingConfig{
			Enabled:             true,
			DestinationOverride: strings.Split("tls,http", ","),
		}
		ctx := vproxyman.ContextWithSniffingConfig(context.Background(), sniffingConfig)
		core.RegisterTCPConnHandler(v2ray.NewTCPHandler(ctx, v))
		core.RegisterUDPConnHandler(v2ray.NewUDPHandler(ctx, v, 30*time.Second))

		core.RegisterOutputFn(func(data []byte) (int, error) {
			packetFlow.WritePacket(data)
			return len(data), nil
		})
	}
}

```

```json
{
    "outbounds": [
        {
            "protocol": "vmess",
            "settings": {
                "vnext": [
                    {
                        "address": "xxx",
                        "port": 37844,
                        "users": [
                            {
                                "id": "c1722917-9415-4466-8d65-8fb047de7ba4",
                                "alterId": 233,
                                "security": "auto"
                            }
                        ]
                    }
                ]
            },
            "mux": {
                "enabled": true
            }
        }
    ]
    
}

```

