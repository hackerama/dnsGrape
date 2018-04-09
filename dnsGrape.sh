#!/bin/bash
# Author: 
b="$1"

red='\033[0;31m'
lpp='\033[1;35m'
lgy='\033[0;37m'
nc='\033[0m'
orange='\033[0;33m'

function ctrlc {
    if [[ "$c" -eq "1" ]];
    then
        jumpto step2;
    else    
        jumpto next;
    fi
}

trap ctrlc SIGINT
function jumpto {
    
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}


if [[ "$1" == "--help" ]] || [[ "$1" == "" ]]; 
then 
    echo "USAGE: ./dnsGrape host.com.br";
else
    echo -e "${lpp}\n"
    echo -e "   ██▄      ▄      ▄▄▄▄▄     ▄▀  █▄▄▄▄ ██   █ ▄▄  ▄███▄   ";
    echo -e "   █  █      █    █     ▀▄ ▄▀    █  ▄▀ █ █  █   █ █▀   ▀  ";
    echo -e "   █   █ ██   █ ▄  ▀▀▀▀▄   █ ▀▄  █▀▀▌  █▄▄█ █▀▀▀  ██▄▄    ";
    echo -e "   █  █  █ █  █  ▀▄▄▄▄▀    █   █ █  █  █  █ █     █▄   ▄▀ ";
    echo -e "   ███▀  █  █ █             ███    █      █  █    ▀███▀   ";
    echo -e "         █   ██                   ▀      █    ▀           ";
    echo -e "                                        ▀                 ";
    echo -e "${lgy}        dnsGrape v1.0 : coded by Carlos Néri Correia      ";
    echo -e "${nc}"
    echo -e "\n[+] Getting name servers:\n "

host -t ns $1 | cut -d " " -f4

echo -e "${lgy} \n[+] Getting mail servers:${nc}\n";
 
host -t mx $1 | cut -d " " -f7

echo -e "${lgy}\n[+] Trying Zone Trasfer:${nc}\n";

for dns in $(host -t ns $1 |cut -d " " -f4 ); 
do 
    echo -e "[-] trying $dns...\n" 
    a=`host -l $1 $dns|grep "has address"|uniq -u`;
    if [ "$a" == "" ]; 
    then
        echo -e "${red}    Zone transfer failed. ${nc}"
    else
        echo -e "$a\n"
    fi
    echo -e "\n";
done

echo -e "${lgy}[+] Starting sub-domain brute-force(Ctrl+C to jump):${nc}\n ";
for url in $(cat dnslist.txt); do
    host $url.$1 |
    grep "has address"; done


next:
c="1"
echo -e "${lgy}\n[+] Starting directory search (Ctrl+Z to finish): ${nc}\n";

# para executar o mesmo comando cat poderia se 
# utilizar também o $()

for word in `cat direc.txt`;
do
    # -s silent -o joga a saida pra dev null 
    # -w executa uma acao apos a request
    resp=$(curl -s -o /dev/null -w "%{http_code}" $b/$word/)
    if [ "$resp" == "200" ]
    then
        echo "Directory Found: $b/$word/" 
    fi
done

step2:
echo -e "${lgy}\n[+] Starting file search: ${nc}\n";

for word in `cat direc.txt`;
do
    for ext in `cat exten.txt`; do
        resp=$(curl -s -o /dev/null -w "%{http_code}" $b/${word}.${ext})
        if [ "$resp" == "200" ];                    
        then
            echo "File Found: $b/$word.$ext" 
        fi
    done
done
fi

