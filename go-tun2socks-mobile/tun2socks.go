package tun2socks

import (
	"time"

	"github.com/eycorsican/go-tun2socks/core"
	// "github.com/eycorsican/go-tun2socks/proxy/socks"
	"github.com/eycorsican/go-tun2socks/proxy/shadowsocks"

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
