:global Edelweiss "v1.2 26.03.18";
# Поле "от кого" для E-mail.
:global mlFrm [/tool e-mail get from];
# Имя системы.
:global syNme [/system identity get name];
# Текущие дата и время.
:global cuDte do={return ([/system clock get date]." ".[/system clock get time]);}


# Применение:
# $beMel Frequency=({"1568.0"; "1318.5"; "1046.5"}) Length=({"100"}) Delay=({"100"})
# $beMel Frequency=({"1568.0"; "1318.5"; "1046.5"}) Length=({"100"; "200"; "300"}) Delay=({"100"; "200"; "300"})

:global beMel do={
	set $Nm [len $Frequency];
	do {
		if (([len $Length])>1) do={set $Ln [($Length->$Nm)];} else={set $Ln [($Length->0)];}
		if (([len $Delay])>1) do={set $Dn [($Delay->$Nm)];} else={set $Dn [($Delay->0)];}
		execute "beep frequency=$[($Frequency->$Nm)] length=$($Ln)ms ";
		delay "$($Dn+10) ms";
		set $Nm ($Nm-1);
		set $Ln ($Ln-1);
	} while ($Nm>-1);
	delay 500ms;
}


# Применение:
# $deArp

:global deArp do={
	[/ip arp print without-paging];
	set $Ia [/ip arp print count-only];
	for I from=0 to=($Ia-1) do={[/ip arp remove $I];}
}


# Применение:
# $deCon

:global deCon do={
	[/ip firewall connection print without-paging];
	set $Ia [/ip firewall connection print count-only];
	for I from=0 to=($Ia-1) do={[/ip firewall connection remove $I];}
}


# Применение:
# ([$foDte Date=[$cuDte]]->0) - Возвращает секунды.
# ([$foDte Date=[$cuDte]]->1) - Возвращает форматированную дату и время.
# ([$foDte Date=[/file get number=НомерФайла value-name=creation-time]]->0) - дата создания файла в секундах.

:global foDte do={
	set $dfy 0;
	set $yar [pick $Date 7 11];
	set $mth [pick $Date 0 3];
	set $day [pick $Date 4 6];
	set $hur [pick $Date 12 14];
	set $min [pick $Date 15 17];
	set $sec [pick $Date 18 20];
	set $mts ("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec");
	set $mtd {0;31;28;31;30;31;30;31;31;30;31;30;31};
	set $mtn ([find $mts $mth -1]+1);
	set $yrd (($yar*365)+($yar / 4));
	set $cmd ($mtd->$mtn);
	set $conA $mtn;

	do {
		set $conA ($conA-1);
		set $dfy ($dfy+($mtd->$conA));
		if ($conA=0) do={set $dfy ($dfy+$day);}
	} while ($conA>0);
	if ($mtn<=9) do={set mtn ("0".$mtn);}
	return {((($yrd+$dfy)*86400)+($hur*3600)+($min*60)+$sec);($day."-".$mtn."-".$yar."-".$hur."-".$min)};
}


# Применение:
# $ifSta Type="vrrp" Number=2
# if ([$ifSta Type="vrrp"]=true) do={beep frequency=1760 length=100ms;}
# if ([$ifSta Type="vrrp" Number=2]=true) do={beep frequency=1760 length=100ms;}

:global ifSta do={
	set $Ia [/interface find type=$Type];
	set $Number [tonum $Number];
	set $Nm [len $Ia];
	do {
		if ([typeof $Number]="num") do={set $Nm $Number;} else={set $Nm ($Nm-1);}
		if ([/interface get number=($Ia->$Nm) running]=true) do={
			set $out true;
		} else={
			set $Nm 0;
			set $out false;
		}
	} while ($Nm>0 && [typeof $Number]!="num");
	return $out;
}


# Применение:
# $ifDis Name="Имя скрипта" Type="vrrp" Disabled="no" - Включаем все VRRP интерфейсы;
# $ifDis Name="Имя скрипта" Type="pptp-out" Number=0 Disabled="no" - Включаем PPTP интерфейс номер 1;
# $ifDis Name="Имя скрипта" Type="l2tp-out" Number=1 Disabled="yes" - Выключаем L2TP интерфейс номер 2;

:global ifDis do={
	set $Ia [/interface find type=$Type];
	set $Sa {no=true;yes=false};
	set $Number [tonum $Number];
	set $Nm [len $Ia];
	do {
		if ([typeof $Number]="num") do={set $Nm $Number;} else={set $Nm ($Nm-1);}
		if ([/interface get number=($Ia->$Nm) disabled]=($Sa->$Disabled)) do={
			[/interface set number=($Ia->$Nm) disabled=$Disabled];
			do {delay 100ms;} while ([/interface get number=($Ia->$Nm) disabled]=($Sa->$Disabled));
			log info "$Name:: $Type interface $[/interface get number=($Ia->$Nm) name] disabled: $[/interface get number=($Ia->$Nm) disabled]";
			beep frequency=1760 length=10ms;
		}
	} while ($Nm>0 && [typeof $Number]!="num");
}


# Применение:
# $ifRun Name="Имя скрипта" Type="vrrp" Disabled="no" - Включаем все VRRP интерфейсы;
# $ifRun Name="Имя скрипта" Type="pptp-out" Number=0 Disabled="no" - Включаем PPTP интерфейс номер 1;
# $ifRun Name="Имя скрипта" Type="l2tp-out" Number=1 Disabled="yes" - Выключаем L2TP интерфейс номер 2;

:global ifRun do={
	set $Ia [/interface find type=$Type];
	set $Sa {no=false;yes=true};
	set $Number [tonum $Number];
	set $Nm [len $Ia];
	do {
		if ([typeof $Number]="num") do={set $Nm $Number;} else={set $Nm ($Nm-1);}
		if ($Disabled="yes" || [/interface vrrp get number=($Ia->$Nm) backup]!=true) do={
			if ([/interface get number=($Ia->$Nm) running]=($Sa->$Disabled)) do={
				[/interface set number=($Ia->$Nm) disabled=$Disabled];
				do {delay 100ms;} while ([/interface get number=($Ia->$Nm) running]=($Sa->$Disabled));
				log info "$Name:: $Type interface $[/interface get number=($Ia->$Nm) name] running: $[/interface get number=($Ia->$Nm) running]";
				beep frequency=1760 length=10ms;
			}
		}
	} while ($Nm>0 && [typeof $Number]!="num");
}


# Применение:
# [$flDel File="Имя или часть имени файла" Name="Имя скрипта" History="7d"];

:global flDel do={
	:global foDte;
	:global cuDte;

	set $Cd ([$foDte Date=[$cuDte]]->0);
	set $Fa [/file find name~$File];
	set $Nm [len $Fa];

	set $Lt [pick $History ([len $History]-1) [len $History]];
	set $Dg [pick $History 0 ([len $History]-1)];
	set $Ta {s=1;m=60;h=3600;d=86400};
	set $Ht ($Dg*($Ta->$Lt)-10);

	do {
		set $Nm ($Nm-1);
		if ( ($Cd-([$foDte Date=[/file get number=($Fa->$Nm) value-name=creation-time]]->0))>$Ht ) do={
			log info "$Name:: Deleting old files: $([$foDte Date=[/file get number=($Fa->$Nm) value-name=creation-time]]->1)";
			/file remove number=($Fa->$Nm);
			beep frequency=1568 length=10ms;
			delay 100ms;
		} else={
			beep frequency=1975 length=10ms;
			delay 100ms;
		}
	} while ($Nm>0);
}


# Применение:
# $mkDir Address="IP на котором работает FTP" User="Имя пользователя" Password="Пароль" Input="Имя создаваемой директории, строкой или массивом" Name="Имя скрипта"
# Можно не указывать адрес, в этом случае будет использован первый из доступных IP на маршрутизаторе.
# $mkDir User="Имя пользователя" Password="Пароль" Input="Имя создаваемой директории, строкой или массивом" Name="Имя скрипта"
# $mkDir Address="172.16.0.1" User="user" Password="Passwd" Input=({"sync";"backup";"scripts";"log";"config"}) Name="scriptName"

:global mkDir do={
	set $Nm [len $Input];
	set $IP [/ip address get 0 address];
	/system identity export file=id.rsc
	if ([typeof $Address]="nothing") do={set $Address [pick $IP 0 [find $IP "/"]];}

	do {
		if ([typeof $Input]="array") do={set $Nm ($Nm-1);set $Bn ($Input->$Nm);} else={set $Nm 0;set $Bn $Input;}
		log info "$Name:: Start creating $Bn directory";
		set $Pth ($Bn . "/in_progress");
		/tool fetch address=($Address) mode=ftp user=($User) password=($Password) src-path=id.rsc dst-path=($Pth)
		delay 3s;
		/file remove $Pth
		log info "$Name:: Done creating $Bn directory";
		beep frequency=1975 length=10ms;
		delay 1s;
	} while ($Nm>0 && [typeof $Input]="array");
}


# Применение:
# $flCre Path="Диретория для записи" Input="Имя экспортируемого файла, строкой или массивом" Name="Имя скрипта"
# $flCre Path="disk1/script/" Input="system script" Name=$scriptName
# $flCre Path=$pathForConfigs Input=$configsArray Name=$scriptName
# $flCre Path=$pathForConfigs Input=({"ip route";"ip firewall";"ip pool";"ip dhcp-server";"interface"}) Name="scriptName"

:global flCre do={
	set $Nm [len $Input];
	do {
		if ([typeof $Input]="array") do={set $Nm ($Nm-1);set $Bn ($Input->$Nm);} else={set $Nm 0;set $Bn $Input;}
		log info "$Name:: Start creating $Bn file";
		execute "/$Bn export file=\"$Path$Bn\"";
		log info "$Name:: Done creating $Bn file";
		beep frequency=1975 length=10ms;
		delay 100ms;
	} while ($Nm>0 && [typeof $Input]="array");
}


# Применение:
# $exSnd Path="Директория для записи" Input="Имя экспортируемого конфига, строкой или массивом" Prefix="Префикс имени файла" Address="IP удалённого сервера" User="Имя пользователя" Password="Пароль" Name="Имя скрипта"
# $exSnd Path="sync" Input={"ip pool";"ip dhcp-server";"interface vrrp"} Prefix="syncfile" Address="192.168.1.101" User="ftpuser" Password="ftppassword" Name="myscript"

:global exSnd do={
	set $Nm [len $Input];
	set $Nn "$Nm";
	if ([typeof $Prefix]="nothing") do={set $Prefix "syncfile";}
	do {

		if ([typeof $Input]="array") do={set $Nm ($Nm-1);set $Bn ($Input->$Nm);set $Bl ($Input->($Nm+1));} else={set $Nm 0;set $Bn $Input;}

		if ($Nm>-2) do={
			set $Fn "$Path/$Prefix-$Bl.rsc";
		} else={
			:global cuDte;
			:global foDte;
			set $Fn "$Path/$([$foDte Date=[$cuDte]]->1).synced";
			log info "$Name:: $Fn";
			set $Bl $Fn;
			[/file print without-paging value-list file=$Fn where name~$Prefix];
			:global flDel;
			[$flDel File="synced" Name=$Name History=10];
			set $Fn "$Fn.txt";
		}

		if ($Nm>-1) do={
			log info "$Name:: Start creating \"$Bn\" file";
			execute "/$Bn export file=\"$Path/$Prefix-$Bn.rsc\"";
			log info "$Name:: Done creating \"$Bn\" file";
		}

		if ($Nm<($Nn-1)) do={
			log info "$Name:: Sending \"$Bl\" to remote device";
			/tool fetch address=$Address src-path=$Fn user=$User mode=ftp password=[:tostr $Password] dst-path=$Fn upload=yes;
			log info "$Name:: Sending \"$Bl\" to remote device complete";
		}

		beep frequency=1975 length=10ms;
		delay 100ms;
	} while ($Nm>-2 && [typeof $Input]="array");
}


# Применение:
# $alSet Find="Имя или фрагмент имени интерфейса(ов)" List="Название адрес листа" Name="Имя скрипта"
# $alSet List="MyDynamicList" Name=$scriptName - Добавит все динамически созданные IP адреса в адрес лист "MyDynamicList"
# $alSet Find="uplink" List="MyUplinkList" Name=$scriptName - Добавит адреса всех интерфейсов, имя которых содержит "uplink" в адрес лист "MyUplinkList"

:global alSet do={
	if ([typeof $Find]="nothing") do={
		set $Ia [/ip address find dynamic];
	} else={
		set $Ia [/ip address find where actual-interface~$Find];
	}

	set $Nm [len $Ia];

	if ($Nm>0) do={
		do {
			set $Nm ($Nm-1);
			set $AI [/ip address get number=($Ia->$Nm) value-name=actual-interface];
			set $IP [/ip address get number=($Ia->$Nm) value-name=address];
			set $IP [pick $IP 0 [find $IP "/"]];

			if ([len [/ip firewall address-list find where address=$IP && list=$List]]=0) do={
				/ip firewall address-list add address=$IP comment=$AI list=$List
				log info "$Name:: Add interface \"$AI\" $IP to address list \"$List\"";
			}

		} while ($Nm>0);
		delay 500ms;
	}

	set $Ia [/ip firewall address-list find list=$List];
	set $Nm [len $Ia];

	if ($Nm>0) do={
		do {
			set $Nm ($Nm-1);
			set $AI [/ip firewall address-list get number=($Ia->$Nm) value-name=comment];
			set $IP [/ip firewall address-list get number=($Ia->$Nm) value-name=address];

			if ([len [/ip address find where address~"$IP/"]]=0) do={
				/ip firewall address-list remove numbers=($Ia->$Nm)
				log info "$Name:: Remove interface \"$AI\" $IP from address list \"$List\"";
			}

		} while ($Nm>0);
		delay 500ms;
	}

}


# Контроллер работы скриптов и функций. Выполняется каждые 5 секунд при наличии скриптов "Edelweiss" и "Control" а так же глобальных
# переменных "controlledScripts" и "controlledFunctions". Следит за работой скриптов и при аварии перезапускает их. Так же будет полезен как
# некий аналог штатного планировщика для работы функций построенных на базе Edelweiss.
# Применение:
# $edelctl do=start
# $edelctl do=stop
# $edelctl do=restart
# $edelctl do=status

:global edelctl do={

	:local ecsrt do={
		if ([len [/system script job find where script=Edelweiss]]< 2) do={
			execute "/system script run Control";
			execute "/system script run Edelweiss";
		}
	}

	:local ecstp do={
		:global Edelweiss;
		set $Ia [/system script job find where script=Edelweiss];
		set $Nm [len $Ia];
		do {
			execute "/system script job remove numbers=$Ia"
			set $Nm ($Nm-1);
		} while ($Nm>0);
		log info "Edelweiss:: Stop \"Edelweiss Control\" $Edelweiss";
	}

	if ($do="start") do={$ecsrt;}
	if ($do="stop") do={$ecstp;}
	if ($do="restart") do={$ecstp;delay 500ms;$ecsrt;}
	if ($do="status") do={/system script job print where script=Edelweiss}
}


if ([len [/system script job find where script=Edelweiss]]< 2) do={
	if ([len [/system script find name=Control]]=1) do={

		:global Edelweiss;
		:global controlledScripts;
		:global controlledFunctions;
		if ([typeof $controlledScripts]="array" && [typeof $controlledFunctions]="array") do={

			log info "Edelweiss:: Start \"Edelweiss Control\" $Edelweiss";

			do {

				set $conA ([len $controlledScripts]-1);
				do {
					set $ScriptCurrentControl [($controlledScripts->$conA)];
					if ([len [/system script job find where script=$ScriptCurrentControl]]< 1 && [len [/system script find name=$ScriptCurrentControl]]=1) do={
						execute "/system script run $ScriptCurrentControl";
						log info "Edelweiss:: Run \"$ScriptCurrentControl\"";
					}
					delay 100ms;
					set $conA ($conA-1);
				} while ($conA>-1);

				set $conB ([len $controlledFunctions]-1);
				do {
					set $FunctionCurrentControl [($controlledFunctions->$conB)];
					execute "$FunctionCurrentControl Name=Edelweiss";
					delay 250ms;
					set $conB ($conB-1);
				} while ($conB>-1);

				delay 5s;
			} while (true);

		} else={
				execute "/system script run Control"
				delay 500ms;
				if ([typeof $controlledScripts]="array" && [typeof $controlledFunctions]="array") do={				
					log warning "Edelweiss:: Control variable not found. Restart script";
					execute "/system script run Edelweiss";
				} else={
					log warning "Edelweiss:: Control variable empty. Stop script";
					execute "$edelctl do=stop";
				}
			}

	} else={
		log warning "Edelweiss:: Script \"Control\" not found";
	}

}


