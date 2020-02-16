version="01"

help_short="wslact [flags] [command] ..."

function gen_startup {
	local help_short="wslact gen_startup [-S <Service> | <Command> ]"
	isService=0
	name=""
	nname=""
	while [ "$1" != "" ]; do
		case "$1" in
			-S|--service) isService=1; shift;;
			-h|--help) help "wslact" "$help_short"; exit;;
			*) name="$*";break;;
		esac
	done

	if [[ "$name" != "" ]]; then
		tpath=$(double_dash_p "$(wslvar -s TMP)") # Windows Temp, Win Double Sty.
		script_location="$(wslpath "$(wslvar -s USERPROFILE)")/wslu" # Windows wslu, Linux WSL Sty.
		script_location_win="$(double_dash_p "$(wslvar -s USERPROFILE)")\\wslu" #  Windows wslu, Win Double Sty.

		# Check presence of sudo.ps1 and 
		wslu_file_check "$script_location" "sudo.ps1"
		wslu_file_check "$script_location" "runHidden.vbs"

		# check if it is a service or a 
		if [[ $isService -eq 1 ]]; then
			nname="wsl.exe -d $WSL_DISTRO_NAME -u root service $name start"
		else
			echo # TODO: handle normåal command
		fi

		echo "Import-Module 'C:\\WINDOWS\\system32\\WindowsPowerShell\\v1.0\\Modules\\Microsoft.PowerShell.Utility\\Microsoft.PowerShell.Utility.psd1'; \$action = New-ScheduledTaskAction -Execute 'C:\\Windows\\System32\\wscript.exe'  -Argument '$script_location_win\\runHidden.vbs $nname'; \$trigger =  New-ScheduledTaskTrigger -AtLogOn -User \$env:userdomain\\\$env:username; \$task = New-ScheduledTask -Action \$action -Trigger \$trigger -Description Generated_By_WSL_Utilities; Register-ScheduledTask -InputObject \$task -TaskPath '\\' -TaskName 'WSL_Service_Startup_$name' -Force;" > "$(wslpath "$(wslvar -s TMP)")"/tmp.ps1
		winps_exec "$script_location_win"\\sudo.ps1 "$tpath"\\tmp.ps1

		echo "${info} Startup added."
	else
		echo "${error} No input, aborting"
		exit 21
	fi

	unset name
	unset nname
}

function time-sync {
	sudo date -s "$(powershell.exe -noprofile -noninteractive -Command "Get-Date -UFormat \"%d %b %Y %T\"" | tr -d "\r")"
}


while [ "$1" != "" ]; do
	case "$1" in
		gen-startup) shift; gen_startup "$@"; exit;;
		-h|--help) help "$0" "$help_short"; exit;;
		-v|--version) echo "wslu v$wslu_version; wslact v$version"; exit;;
		*) name="$*";break;;
	esac
done