#!/bin/bash

HEIGHT=30
WIDTH=60
OPTION_HEIGHT=6


initail_pwd=$(pwd)

while :
do

choice=$(dialog --menu "SYS INFO" $HEIGHT $WIDTH $OPTION_HEIGHT \
	1 "CPU INFO" 2 "MEMORY INFO" 3 "NETWORK INFO" 4 "FILE BROWSER" \
	2>&1 > /dev/tty)

if [ $? == 1 ]; then
	break
fi

case $choice in 
	1)
		model=$(sysctl hw.model | awk '{$1 = ""; print $0}')
		machine=$(sysctl hw.machine | awk '{$1 = ""; print $0}')
		core=$(sysctl hw.ncpu | awk '{$1 = ""; print $0}')
		dialog --msgbox "CPU Info \nCPU Model: $model \nCPU Machine: $machine \nCPU Core: $core \n" $HEIGHT $WIDTH
		;;
	2)
		total=$(dmesg | grep "real memory" | awk '{mem = $4; if(mem < 1024) print mem " B"; else { mem = mem / 1024; if (mem < 1024) print mem " KB"; else { mem = mem / 1024; if(mem < 1024) print mem " MB"; else { mem = mem / 1024; if(mem < 1024) print mem " GB"; else { mem = mem / 1024; print mem " TB";} } } } }') 
		free=$(dmesg | grep "avail memory" | awk '{mem = $4; if(mem < 1024) print mem " B"; else { mem = mem / 1024; if (mem < 1024) print mem " KB"; else { mem = mem / 1024; if(mem < 1024) print mem " MB"; else { mem = mem / 1024; if(mem < 1024) print mem " GB"; else { mem = mem / 1024; print mem " TB";} } } } }') 
		used=$(dmesg | grep -e "real memory" -e "avail memory" | awk 'BEGIN{mem = 0;} NR==1{mem += $4;} NR == 2{mem -= $4;} END{if(mem < 1024) print mem " B"; else { mem = mem / 1024; if (mem < 1024) print mem " KB"; else { mem = mem / 1024; if(mem < 1024) print mem " MB"; else { mem = mem / 1024; if(mem < 1024) print mem " GB"; else { mem = mem / 1024; print mem " TB";} } } } }') 
		persent=$(dmesg | grep -e "real memory" -e "avail memory" | awk 'BEGIN{p = 0; q = 0;} NR==1{p += $4; q += $4;} NR == 2{p -= $4;} END{ p = int(p * 100 / q); print p}')
		read -n 1 -s | dialog --title "" --guage "Memory Info and Usage \n\nTotal: $total \nUsed: $used \nFree: $free \n" $HEIGHT $WIDTH $persent
		;;
	3)
		while :
		do
			opt=$(ifconfig -l | awk '{for( i = 1; i <= NF; i++){print $i " ."}}')
			c=$(dialog --menu "Network Interfaces" $HEIGHT $WIDTH $OPTION_HEIGHT $opt 2>&1 > /dev/tty)
			if [ $? == 1 ]; then
				break
			fi
			for choice in $c
			do
				ip=$(ifconfig $c | grep "inet "  | awk '{print $2}')
				mac=$(ifconfig $c | grep "inet " | awk '{print $4}')
				mask=$(ifconfig $c | grep "ether " | awk '{print $2}')
				dialog --msgbox "Interface Name: $c \n\nIpv4___: $ip\nNetmask: $mask\nMac____: $mac\n" $HEIGHT $WIDTH
			done
		done
		;;
	4)
		cd $initial_pwd
		pass="true"
		while [ $pass == "true" ]
		do 
			p=$(pwd)
			file=$(ls -a)
			opt=""
			for f in $file
			do 
				t=$(file --mime-type -b $f)
				opt="${opt} ${f} ${t}"
			done
			c=$(dialog --menu "File Browser: $p" $HEIGHT $WIDTH 20 $opt 2>&1 > /dev/tty)

			if [ $? == 1 ]; then
				break
			fi

			for choice in $c
			do	 
				file_type_d=$(file --mime-type -b $choice | grep "directory" | awk '{if ($1 != "") print "true";}')
				file_type_t=$(file -b $choice | grep "text" | awk '{if ($1 != "") print "true";}')
				if [ $file_type_d == "true" ]; then
					cd $choice
					break
				fi

				info=$(file -b $choice)
				size=$(du -h $choice | awk '{print $1}')
				if [ $file_type_t == "true" ]; then
					while :
					do
						dialog --extra-button --extra-label "Edit" --msgbox "<ile Name>: $choice \n<File Info>: $info \n<File size>: $size \n" $HEIGHT $WIDTH
						if [ $? == 3 ]; 
						then
							$EDITOR $choice
						else
							break	
						fi
					done
					break
				fi
				dialog --msgbox "<File Name>: $choice \n<File Info>: $info \n<File Size>: $size \n" $HEIGHT $WIDTH
				break
			done
		done
		;;

esac

done

clear

