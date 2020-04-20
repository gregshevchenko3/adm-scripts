HYPER_V_RESOLUTION=1366x768

INTERNAL_IP=192.192.1.100
OPENSSH_PORT=1022
CRYPTO_ALG="rsa"

if test "${HYPER_V_RESOLUTION}" ;
then
	sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash video=hyperv_fb:${HYPER_V_RESOLUTION}\"/" /etc/default/grub
	update-grub
fi

apt install openssh-server
patch /etc/ssh/sshd_config < sshd_config.patch

if test "${OPENSSH_PORT}";
then
	sed -E -i  "s/#Port[[:space:]]+22/Port ${OPENSSH_PORT}/" /etc/ssh/sshd_config
else
	sed -E -i "s/#Port[[:space:]]+22/Port 22/" /etc/ssh/sshd_config
fi

if test "${INTERNAL_IP}";
then
	sed -E -i "s/#ListenAddress[[:space:]]+0.0.0.0/ListenAddress ${INTERNAL_IP}/" /etc/ssh/sshd_config
fi

if test "$CRYPTO_ALG";
then
	rm /etc/ssh/ssh_host*  
	ssh-keygen -t ${CRYPTO_ALG} -f /etc/ssh/ssh_$(uname --nodename)_${CRYPTO_ALG}_key
	sed -E -i "s/#HostKey[[:space:]]+\/etc\/ssh\/ssh_host_${CRYPTO_ALG}_key/HostKey \/etc\/ssh\/ssh_$(uname --nodename)_${CRYPTO_ALG}_key/" /etc/ssh/sshd_config
fi
systemctl restart sshd.service

