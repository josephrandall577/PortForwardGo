#!/bin/sh
clear
Font_Black="\033[30m"
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Blue="\033[34m"
Font_Purple="\033[35m"
Font_SkyBlue="\033[36m"
Font_White="\033[37m"
Font_Suffix="\033[0m"

echo -e "${Font_SkyBlue}PortForwardGoPanel update script${Font_Suffix}"

echo -e "${Font_Yellow} ** Checking system info...${Font_Suffix}"
case $(uname -m) in
x86_64)
    arch="amd64"
    ;;
armv7*)
    arch="armv7"
    ;;
aarch64)
    arch="arm64"
    ;;
s390x)
    arch="s390x"
    ;;
*)
    echo -e "${Font_Red}Unsupport architecture${Font_Suffix}"
    exit 1
    ;;
esac

if [[ ! -e "/usr/bin/systemctl" ]] && [[ ! -e "/bin/systemctl" ]]; then
    echo -e "${Font_Red}Not found systemd${Font_Suffix}"
    exit 1
fi

dir="/opt/PortForwardGoPanel"
while [ ! -d "${dir}" ]; do
    read -p "${dir} not exists, please input a new dir: " dir
done

service_name="PortForwardGoPanel"
while [ ! -f "/etc/systemd/system/${service_name}.service" ]; do
    read -p "Service ${service_name} not exists, please input a new service name: " service_name
done

echo -e "${Font_Yellow} ** Checking release info...${Font_Suffix}"
vers=$(curl -sL https://gitlab.com/api/v4/projects/CoiaPrant%2FPortForwardGo/releases | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | awk -F "," '{print $1}' | sed 's/\"//g;s/,//g;s/ //g' | awk -F "v" '{print $2}')
if [ -z "${vers}" ]; then
    echo -e "${Font_Red}Unable to get releases info${Font_Suffix}"
    exit 1
fi
echo -e " Detected lastet version: " ${vers}

echo -e "${Font_Yellow} ** Download release info...${Font_Suffix}"

curl -L -o /tmp/PortForwardGo.tar.gz "https://gitlab.com/CoiaPrant/PortForwardGo/-/releases/v"${vers}"/downloads/PortForwardGoPanel_"${vers}"_linux_"${arch}".tar.gz"
if [ ! -f "/tmp/PortForwardGo.tar.gz" ]; then
    echo -e "${Font_Red}Download failed${Font_Suffix}"
    exit 1
fi

tar -xvzf /tmp/PortForwardGo.tar.gz -C /tmp/
if [ ! -f "/tmp/PortForwardGoPanel" ]; then
    echo -e "${Font_Red}Decompression failed${Font_Suffix}"
    exit 1
fi

rm -f ${dir}/PortForwardGoPanel
rm -f ${dir}/resources

chmod 777 /tmp/PortForwardGoPanel
mv /tmp/PortForwardGoPanel ${dir}
mv /tmp/resources ${dir}

rm -rf /tmp/*

echo -e "${Font_Yellow} ** Starting program...${Font_Suffix}"
systemctl restart ${service_name}

echo -e "${Font_Green} [Success] Completed update${Font_Suffix}"
