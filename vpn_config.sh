#!/bin/sh
printf "CGW 퍼블릭(혹은 탄력적) IP를 입력하세요: "
read word1
printf "VGW의 Tunnel1의 외부 IP를 입력하세요: "
read word2
printf "VGW의 Tunnel2의 외부 IP를 입력하세요: "
read word3

cat <<EOF> /etc/ipsec.d/aws.conf
conn Tunnel1
  authby=secret
  auto=start
  left=%defaultroute
  leftid="$word1"
  right="$word2"
  type=tunnel
  ikelifetime=8h
  keylife=1h
  phase2alg=aes128-sha1;modp1024
  ike=aes128-sha1;modp1024
  keyingtries=%forever
  keyexchange=ike
  leftsubnet=10.60.0.0/16  # IDC 
  rightsubnet=10.50.0.0/16  # AWS 
  dpddelay=10
  dpdtimeout=30
  dpdaction=restart_by_peer

conn Tunnel2
  authby=secret
  auto=start
  left=%defaultroute
  leftid="$word1"
  right="$word3"
  type=tunnel
  ikelifetime=8h
  keylife=1h
  phase2alg=aes128-sha1;modp1024
  ike=aes128-sha1;modp1024
  keyingtries=%forever
  keyexchange=ike
  leftsubnet=10.2.0.0/16  # IDC 
  rightsubnet=10.1.0.0/16  # AWS 
  dpddelay=10
  dpdtimeout=30
  dpdaction=restart_by_peer
EOF

cat <<EOF> /etc/ipsec.d/aws.secrets
$word1 $word2 : PSK "interface"
$word1 $word3 : PSK "interface"
EOF

printf "VPN 서비스를 시작합니다.\n"
systemctl start ipsec
systemctl enable ipsec

printf "VPN 설정이 완료되었습니다.\n"
printf "cat /etc/ipsec.d/aws.conf 명령어로 확인해 보세요.\n"
printf "cat /etc/ipsec.d/aws.secrets 명령어로 확인해 보세요.\n"
