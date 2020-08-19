#!/bin/bash
active=$(echo yes)

while [ "$active" = "yes" ]
do
	upsstatus=$(upsc ups ups.status | grep -v '^Init SSL')
	#Der Status der USV wird alle 30 Sekunden abgefragt
	if [ "$upsstatus" = "FSD OB" ]; then
		#Hier fährt das Script alle Server nach 2 Minuten herunter
		#Jetzt wird der Status in eine Log-Datei geschrieben
		date=$(date)
		echo $date "ALARM Power Offline" >> /mnt/btrfs/upsstat.txt &
		echo "ALARM Power Offline Written message to File at Date:" $date
		/sbin/shutdown -t 1
		notify -i "USV Offline" -t "Die USV hat keinen Strom mehr"
		#Mein Handy wird mit Notify benachrichtigt
		
		while [ "$upsstatus" = "FSD OB" ]
		do
			sleep 3
			upsstatus=$(upsc ups ups.status | grep -v '^Init SSL')
			#Der Status der USV wird alle 4 Sekunden abgefragt
			if [ "$upsstatus" = "FSD OB" ]; then
				date=$(date)
				echo $date "ALARM Power still Offline" >> /mnt/btrfs/upsstat.txt &
				echo "ALARM Power Offline Written message to File at Date:" $date
				#Das Script schreibt alle 3 Sekunden in die Log-Datei FSD OB die USV noch Offline ist
			else
				/sbin/shutdown -c
				date=$(date)
				echo "Stopped Shutdown on all Servers"
				echo $date "UPS back Online" >> /mnt/btrfs/upsstat.txt
				echo "UPS back Online Written message to File at Date:" $date
				notify -i "USV Back Online" -t "Die USV hat wieder Strom"
			fi
		done
	
	else
		date=$(date)
		##echo $date "UPS Online" >> /mnt/btrfs/upsstat.txt
		echo "UPS Online at Date:" $date
	fi
	sleep 5
done
