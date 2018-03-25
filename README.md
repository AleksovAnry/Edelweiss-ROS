# Edelweiss-ROS - библиотека функций для MikroTik Router OS
Edelweiss-ROS - functions library for MikroTik Router OS

Данна библиотека создана для упрощения использования скриптов в Router OS, их популяризации и расширения функциональности оборудования этого вендора в повседневной жизни. Все желающие присоединиться к разработке библиотеки могут присылать свои наработки и идеи мне на почту aleksov[a]set-pro.net
#
Для старта бибиотеки вместе с системой, добавляем в планировщик (Scheduler) запуск библиотеки.
#
	/system scheduler
	add name=Startup on-event="/system script run Edelweiss" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-time=startup
#
Для того чтобы воспользоваться функциями библиотеки не только из консоли но и в других скриптах, необходимо добавить в эти скрипты глобальные переменные библиотеки. Как только переменные добавлены, функции становятся доступными для скрипта локально. 
#
Добавляем в том случае, если библиотека не стартует вместе с системой.
#
	/system script run "Edelweiss";
#
Не стоит включать в каждый скрипт все функции сразу, добавляем только те, которые будут реально использоваться.
#
	:global mlFrm;
	:global syNme;
	:global cuDte;
	:global beMel;
	:global deArp;
	:global deCon;
	:global foDte;
	...
# 
Для управление контроллером скриптов используются следующие команды:
# 
	$edelctl do=start
	$edelctl do=stop
	$edelctl do=restart
	$edelctl do=status