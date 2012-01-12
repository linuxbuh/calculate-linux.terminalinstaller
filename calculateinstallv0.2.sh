#!/bin/sh


#########russian
### 1 килобайт/мегабайт/гигабайт/ равен 1024
### При расчетах всегда умножаем на 1024 килобайт, а делим на 1000 килобайт
### все данные о диске берутся из системы в блоках (размер блока 1024 килобайта)
##  и пересчитываются в байты (размер дисков в байтах)
### данные об оперативной памяти берутся из системы в килобайтах
##########english
### 1 kilobyte / megabyte / gigabyte / equal to 1024
### When the calculations are always multiplied by 1024 kilobytes, and divide by 1000 kilobytes
### All data on the disk are taken from the system in blocks (block size of 1024 kilobytes)
### And converted into bytes (the size of disk in bytes)
### Data on the memory are taken from the system in kilobytes


    while :
    do

    if [ "$DISPLAY" != "" ];
    then
        DIALOG="dialog"
else
        DIALOG="xdialog"
    fi

##путь путь до текстовых файлов и переводов
pathtranslatefile=/home/ztime/calcinst

##определяем язык системы и подставляем текстовый файл
if [ LANG=ru_RU.UTF-8 = "LANG=ru_RU.UTF-8" ];
then
translatefile=$pathtranslatefile/ru.txt
else
translatefile=$pathtranslatefile/en.txt
fi
source $translatefile

##меню предупреждения
##warning menu
$DIALOG $OPTS --msgbox "$text1" 60 80

###Выясняем диски в системе
###We find out drives in the system
#ls /dev | grep sd > /tmp/devinput.$$
fdisk -l > /tmp/devinput

###высчитываем какие есть диски (надо будет нати лучшее решение например массивы)
###calculates what is the wheels (must be the best solution search for examplearrays)
#сортируем строки в файл по имени
#sort lines in a file named
if [ LANG=ru_RU.UTF-8 = "LANG=ru_RU.UTF-8" ];
then
grep Диск /tmp/devinput > /tmp/devinputtmp
else
grep Disk /tmp/devinput > /tmp/devinputtmp
fi
#берем из строки все после пробела
#take the string everything after the space
cat /tmp/devinputtmp | cut -d" " -f2 > /tmp/devinputtmp1
#берем из строки все после : (двоеточия)
#take the string everything after the : (colon)
cat /tmp/devinputtmp1 | cut -d: -f1 > /tmp/devinputtemp
##раскладываем описания дисков на файлы
##spread Sheets drives for files
devinputopis="/tmp/devinputtmp"
L=1
M=$(wc -l "$devinputopis" | egrep -o '^[0-9]+')
N=$((M / L))
if [[ $((N*L)) -lt $M ]]; then
    tail -n$((M - N*L)) "$devinputopis" > "$devinputopis$((N+1))";
fi
for ((i=0; i<N; i++)); do
    head -n$((i*L + L)) "$devinputopis" | tail -n$L > "$devinputopis$i";
done

devinputopis0="`cat /tmp/devinputtmp0`"
devinputopis1="`cat /tmp/devinputtmp1`"
devinputopis2="`cat /tmp/devinputtmp2`"
devinputopis3="`cat /tmp/devinputtmp3`"

##раскладываем на /dev/sda /dev/sdb и тп. по файлам
##lay the /dev/sda /dev/sdb for files
devinputdev="/tmp/devinputtemp"
L=1
M=$(wc -l "$devinputdev" | egrep -o '^[0-9]+')
N=$((M / L))
if [[ $((N*L)) -lt $M ]]; then
    tail -n$((M - N*L)) "$devinputdev" > "$devinputdev$((N+1))";
fi
for ((i=0; i<N; i++)); do
    head -n$((i*L + L)) "$devinputdev" | tail -n$L > "$devinputdev$i";
done

devinput0="`cat /tmp/devinputtemp0`"
devinput1="`cat /tmp/devinputtemp1`"
devinput2="`cat /tmp/devinputtemp2`"
devinput3="`cat /tmp/devinputtemp3`"


##первичное меню
##primary menu
$DIALOG $OPTS --title "$text2" --menu "$text3" 40 60 4 "1" "$text4" "2" "$text5" "3" "$text6" "4" "$text7" 2>/tmp/instalmenu.$$

if [ $? = 1 ]; then
#удаляем файл пункта меню
#delete the file menu
   rm -f /tmp/instalmenu.$$
   clear
   exit 0
fi

#читаем файл пункта меню если 1 то
#read the file menu if 1 then
R="`cat /tmp/instalmenu.$$`"

##################################Пункт 1 главного меню
##################################Paragraph 1 of the main menu
if [ $R = "1" ]; then

#меню
#menu
	#сообщение о дисках в системе
	#message about disks in the system
        $DIALOG $OPTS --title "$text8" --textbox /tmp/devinput 100 100
	$DIALOG $OPTS --yesno "$text9" 40 60
        if [ $? = "0" ]
        then
        $DIALOG $OPTS --title "$text10" --menu "$text11$devinputopis0\n\n$devinputopis1\n\n$devinputopis2\n\n$devinputopis3\n\n" 30 60 4 /dev/sda "/dev/sda" /dev/sdb "/dev/sdb" /dev/sdd "/dev/sdd" /dev/sdc "/dev/sdc" 2>/tmp/devformat.$$


##указываем диск для форматирования например /dev/sda
##specify the disk to be formatted like /dev/sda
devformat="`cat /tmp/devformat.$$`"

##высчитываем размер выбранного диска в байтах
##calculates the size of the selected drive in bytes
#смотрим общий размер блоков диска в килобайтах
#look at the total size of disk blocks in kilobytes
sfdisk -s $devformat > /tmp/sizeblocksdisk.$$
#записываем в файл общий размер блоков диска в килобайтах
#write to file the total size of disk blocks in kilobytes
sizeblocksdisk="`cat /tmp/sizeblocksdisk.$$`"
#размер блока по умолчанию килобайт
#default block size kilobytes
sizeblock="1024"
#вычисляем общий размер диска в байтах
#compute the total disk size in bytes
let "sizedisksum=$sizeblocksdisk*$sizeblock"
#записываем в файл общий размер диска в байтах
#write to file the total size of the disk in bytes
echo -e $sizedisksum > /tmp/sizedisksum.$$
#общий размер диска в байтах
#total size of the disk in bytes
sizedisk="`cat /tmp/sizedisksum.$$`"

##вычисляем размер памяти в килобайтах
##calculate the memory size in kilobytes
grep MemTotal: /proc/meminfo > /tmp/tempmeminfo.$$
#берем из строки все после пробела
#take the string everything after the space
cat /tmp/tempmeminfo.$$ | cut -d" " -f9 > /tmp/meminfotmp.$$
meminfo="`cat /tmp/meminfotmp.$$`"

##расчитываем размер swap раздела в байтах
##calculate the size of swap partition in bytes
let "swapsizetmp=$meminfo*2*1024"
echo -e $swapsizetmp > /tmp/swapsizetmp.$$
swapsize="`cat /tmp/swapsizetmp.$$`"

##указываем размер /root раздела в байтах
##specify size of /root partition in bytes
rootsize="32256000000"
echo -e $rootsize > /tmp/rootsize.$$

##расчитываем размер неоходимого места на диске в байтах (больше или равно)
##details please calculate the size of disk space in bytes (greater than or equal to)
let "nadomestanadiske=$swapsize+$rootsize"
echo -e $nadomestanadiske > /tmp/nadomestanadiske.$$

##проверяем диск больше или равен нужному размеру swap+/root
##check the disk is greater than or equal to the desired size of the swap + /root
        if [ "$sizedisk" -ge "$nadomestanadiske" ]
        then
        devformat1="`cat /tmp/devformat.$$`1"
        devformat2="`cat /tmp/devformat.$$`2"
        devformat3="`cat /tmp/devformat.$$`3"
        $DIALOG $OPTS --yesno "$text12$devformat$text12a$devformat1$text12b$swapsizetmp$text12c$devformat2$text12d$devformat2text12e" 40 60
	if [ $? = "0" ]
        then

##указываем раздел диска для установки например /dev/sda2
##specify the partition to install the example /dev/sda2
#жестко устанавливаем что ставить в /dev/sd*2
#hard set that put in /dev/sd*2
devinstall="2"
#записываем в файл
#write to file
echo -e $devinstall>/tmp/devinstall.$$

##указываем файловую систему по умолчанию для разделов /dev/sd*2 (/root) & /dev/sd*3 (/home)
##specify the default file system for partitions /dev/sd*2 (/root) & /dev/sd*3 (/home)
#/root
echo -e "ext3">/tmp/fssd2.$$
#/home
echo -e "ext3">/tmp/fssd3.$$

##считываем файловую систему по умолчанию для разделов /dev/sd*2 (/root) & /dev/sd*3 (/home)
##read the file system by default for partitions /dev/sd*2 (/root) & /dev/sd*3 (/home)
fssd2="`cat /tmp/fssd2.$$`"
fssd3="`cat /tmp/fssd3.$$`"

##считываем диск по умолчанию для разделов /dev/sd*2 (/root) & /dev/sd*3 (/home)
##read the disc's default partition /dev/sd*2 (/root) & /dev/sd*3 (/home)
devinsttmp="`cat /tmp/devformat.$$``cat /tmp/devinstall.$$`"
echo -e $devinsttmp>/tmp/devinst.$$
devinst="`cat /tmp/devinst.$$`"

##расчитываем размер /home раздела в килобайтах
##/home partition
sd3size=" "
echo -e $sd3size > /tmp/sd3size.$$

##Отключаем все swap разделы
##disable all swap partitions
swapoff -a

##Уничтожаем разделы на жестком диске
##Destroy the partitions on your hard disk
echo -e "d\n10\nd\n9\nd\n8\nd\n7\nd\n6\nd\n5\nd\n4\nd\n3\nd\n2\nd\n1\nw">/tmp/fdiskdel.$$
fdisk $devformat < /tmp/fdiskdel.$$

##Разбиваем жесткий диск
##Divide a hard disk
#пересчитываем размер в килобайты
#recalculate the size in kilobytes
let "swapsizeformattmp="$swapsize"/1000" > /tmp/swapsizeformattmp.$$
#добавляем знаки + и К (килобайта) для файла /tmp/fdiskinput.$$
#add the signs + and K (kilobytes) for file /tmp/fdiskinput.$$
swapsizeformat="+"$swapsizeformattmp"K"
#пересчитываем размер в килобайты
#recalculate the size in kilobytes
let "rootsizeformattmp="$rootsize"/1000" > /tmp/rootsizeformattmp.$$
#добавляем знаки + и К (килобайта) для файла /tmp/fdiskinput.$$
#add the signs + and K (kilobytes) for file /tmp/fdiskinput.$$
rootsizeformat="+"$rootsizeformattmp"K"
#выгружаем строку
#unload the line
echo -e "n\np\n1\n\n$swapsizeformat\nn\np\n2\n\n$rootsizeformat\nn\np\n3\n\n$sd3size\nt\n1\n82\na\n$devinstall\nw">/tmp/fdiskinput.$$
#считываем строку и переразбиваем
#reads a line
fdisk $devformat < /tmp/fdiskinput.$$

##Форматируем swap раздел
##Format the swap partition
devswap="`cat /tmp/devformat.$$`1"
mkswap $devswap

##Подключаем swap раздел
##Connecting swap partition
swapon $devswap

##Форматируем 1 раздел /root
##Format the partition 1 /root
devsd2="`cat /tmp/devformat.$$`2"
mkfs.$fssd2 $devsd2

#Форматируем 2 раздел /home
##Format the partition 1 /home
devsd3="`cat /tmp/devformat.$$`3"
mkfs.$fssd3 $devsd3

#        if [ LANG=ru_RU.UTF-8 = "LANG=ru_RU.UTF-8" ];
#        then
	$DIALOG $OPTS --title "$hostnametext1" --inputbox "$hostnametext2" 30 60 "calculate" 2>/tmp/hostn.$$
	$DIALOG $OPTS --title "$domainnametext1" --inputbox "$domainnametext2" 30 60 "home" 2>/tmp/domain.$$
	$DIALOG $OPTS --title "$resolutiontext1" --menu "$resolutiontext2" 30 60 7 1680x1050 "1680x1050" 1280x1024 "1280x1024" 1440x900 "1440x900" 1152x864 "1152x864" 1024x768 "1024x768" 800x600 "800x600" 640x480 "640x480" 2>/tmp/resolution.$$
#	$DIALOG $OPTS --title "$mbrtext1" --menu "$mbrtext2" 30 60 2 yes "ДА" no "НЕТ" 2>/tmp/mbr.$$
        $DIALOG $OPTS --yesno "$text13" 15 60

       if [ $? = "0" ]
        then
##считываем имя компьютера
##read the name of the computer
hostn="`cat /tmp/hostn.$$`"

##считываем имя домена
##read in a domain name
domain="`cat /tmp/domain.$$`"

##считываем разрешение экрана
##read the screen resolution
resolution="`cat /tmp/resolution.$$`"

##считываем устанавливать загрузчик в mbr или нет
##read the install the boot loader in the mbr or not
mbr="`cat /tmp/mbr.$$`"

##Выполняем установку
##Perform the installation system
### параметр -f отключает вопросы установщика во время установки
### параметр -w указывает swap диск
### -f option disables the questions the installer during installation
/usr/bin/cl-install -f -d $devinst -w $devswap --hostname $hostn,$domain --X $resolution


   $DIALOG $OPTS --msgbox "$text14" 10 60
    $DIALOG $OPTS --yesno "$reboottext" 15 60
     if [ $? = "0" ]
        then
        reboot
        fi
 fi
 fi
##проверяем диск меньше размера swap+/root то выводим сообщение после else
##check the disk smaller than the swap + / root then displaying a message after else
      else
        #пересчитываем размер в гигабайты
	#recalculate the size in gigabyte
	let "infonadevformat="$nadomestanadiske"/1000/1000/1000"
        let "infonadevformat1="$sizedisk"/1000/1000/1000"
        $DIALOG $OPTS --msgbox "$text15$devformat$text15a$infonadevformat1$text15b$infonadevformat$text15c" 20 60
     fi
    fi
   F="`cat /tmp/instalmenu.$$`"

##################################Пункт 2 главного меню
##################################Paragraph 2 of the main menu
elif [ $R = "2" ]; then

#ls /dev | grep sd > /tmp/devinput.$$
#	if [ LANG=ru_RU.UTF-8 = "LANG=ru_RU.UTF-8" ];
#        then
        $DIALOG $OPTS --title "$text8" --textbox /tmp/devinput 30 70
	$DIALOG $OPTS --title "$text10" --menu "$text11$devinputopis0\n\n$devinputopis1\n\n$devinputopis2\n\n$devinputopis3\n\n" 30 60 4 /dev/sda "/dev/sda" /dev/sdb "/dev/sdb" /dev/sdd "/dev/sdd" /dev/sdc "/dev/sdc" 2>/tmp/devformat.$$
        $DIALOG $OPTS --title "$text16" --inputbox "$text17" 30 60 "+10G" 2>/tmp/swapsize.$$
        $DIALOG $OPTS --title "$text18" --inputbox "$text19" 30 60 "+30G" 2>/tmp/sd2size.$$
        $DIALOG $OPTS --title "$text20" --inputbox "$text21" 30 60 "$1" 2>/tmp/sd3size.$$
        $DIALOG $OPTS --title "$text22" --menu "$text23" 30 60 5 ext4 "ext4" ext3 "ext3" xfs "xfs" reiserfs "reiserfs" jfs "jfs" 2>/tmp/fssd2.$$
	$DIALOG $OPTS --title "$text24" --menu "$text25" 30 60 5 ext4 "ext4" ext3 "ext3" xfs "xfs" reiserfs "reiserfs" jfs "jfs" 2>/tmp/fssd3.$$
	$DIALOG $OPTS --title "$text26" --inputbox "$text27" 30 60 "2" 2>/tmp/devinstall.$$

devformat="`cat /tmp/devformat.$$`"
devformat1="`cat /tmp/devformat.$$`1"
devformat2="`cat /tmp/devformat.$$`2"
devformat3="`cat /tmp/devformat.$$`3"
swapsize="`cat /tmp/swapsize.$$`"
sd2size="`cat /tmp/sd2size.$$`"
sd3size="`cat /tmp/sd3size.$$`"
fssd2="`cat /tmp/fssd2.$$`"
fssd3="`cat /tmp/fssd3.$$`"

devinstall="`cat /tmp/devinstall.$$`"
devinsttmp="`cat /tmp/devformat.$$``cat /tmp/devinstall.$$`"
echo -e $devinsttmp>/tmp/devinst.$$
devinst="`cat /tmp/devinst.$$`"

	if [ LANG=ru_RU.UTF-8 = "LANG=ru_RU.UTF-8" ];
        then
        $DIALOG $OPTS --yesno "Приступаем - все разделы диска $devformat будут уничтожены!!\n\n
        Будут созданы три раздела\n\n$devformat1 - swap раздел $swapsize Гигабайт\n\n$devformat2 - /root раздел размером $sd2size Гигабайт\n\n$devformat3 - весь оставшийся объем диска\nдля папки /home или установки другой версии системы\n\nВы уверены что хотите форматировать этот диск? " 40 60
	else
	$DIALOG $OPTS --yesno "Getting Started - all partitions $devformat will be destroyed!!\n\n
        Will create three partitions\n\n$devformat1 - swap section $swapsize GB\n\n$devformat2 - /root partition $sd2size GB\n\n$devformat3 - the rest of the disk capacity\nfor the folder /home or installing a different version of the system\n\nAre you sure you want to format this drive? " 40 60
	fi
        if [ $? = "0" ]
        then

#devformat="`cat /tmp/devformat.$$`"

##Отключаем все swap разделы
##Disable all swap partitions
swapoff -a

##Уничтожаем разделы на жестком диске
##Destroy the hard drive partitions
echo -e "d\n10\nd\n9\nd\n8\nd\n7\nd\n6\nd\n5\nd\n4\nd\n3\nd\n2\nd\n1\nw">/tmp/fdiskdel.$$
fdisk $devformat < /tmp/fdiskdel.$$

##Разбиваем жесткий диск
## Divide the hard disk
echo -e "n\np\n1\n\n$swapsize\nn\np\n2\n\n$sd2size\nn\np\n3\n\n$sd3size\nt\n1\n82\na\n$devinstall\nw">/tmp/fdiskinput.$$
fdisk $devformat < /tmp/fdiskinput.$$

##Форматируем swap раздел
##Format the swap partition
devswap="`cat /tmp/devformat.$$`1"
mkswap $devswap

##Подключаем swap раздел
##Connecting the swap partition
swapon $devswap

##Форматируем 1 раздел
##Format a partition
devsd2="`cat /tmp/devformat.$$`2"
mkfs.$fssd2 $devsd2

##Форматируем 2 раздел
##Format a partition
devsd3="`cat /tmp/devformat.$$`3"
mkfs.$fssd3 $devsd3

	if [ LANG=ru_RU.UTF-8 = "LANG=ru_RU.UTF-8" ];
        then
        $DIALOG $OPTS --title "Ввод имени компьютера в сети" --inputbox "Введите имя компьютера. \n Например calculate по умолчанию" 30 60 "calculate" 2>/tmp/hostn.$$
        $DIALOG $OPTS --title "Ввод имени домена" --inputbox "Введите имя домена. \n Например home (по умолчанию)" 30 60 "home" 2>/tmp/domain.$$
	$DIALOG $OPTS --title "Выбор разрешения экрана" --inputbox "Введите желаемое разрешение экрана. \n Например 1024x768 (по умолчанию)" 30 60 "1024x768" 2>/tmp/resolution.$$
	$DIALOG $OPTS --title "Выбор установки загрузчика" --menu "Записать загрузчик в mbr \n yes или no \n (переход с помошью стрелок \n выбор с помошью клавиши 'ENTER')" 30 60 2 yes "ДА" no "НЕТ" 2>/tmp/mbr.$$
        $DIALOG $OPTS --yesno "Сейчас будет произведена установка системы на жесткий диск.

        Установить?" 15 60
	else
	$DIALOG $OPTS --title "Enter the name of the computer network" --inputbox "Enter the computer name. \n For example calculate the default" 30 60 "calculate" 2>/tmp/hostn.$$
	$DIALOG $OPTS --title "Enter a domain name" --inputbox "Enter a domain name. \n For example home (default)" 30 60 "home" 2>/tmp/domain.$$
	$DIALOG $OPTS --title "The choice of screen resolution" --inputbox "Enter the desired screen resolution. \n For example 1024x768 (default)" 30 60 "1024x768" 2>/tmp/resolution.$$
	$DIALOG $OPTS --title "Selecting the boot loader" --menu "Record loader to mbr \n yes or no \n (transition with the aid of the arrows \n selection with the aid of key 'ENTER')" 30 60 2 yes "YES" no "NO" 2>/tmp/mbr.$$
	$DIALOG $OPTS --yesno "Now the system will be installed on the hard disk.

        Install?" 15 60
	fi
        if [ $? = "0" ]
        then


hostn="`cat /tmp/hostn.$$`"
domain="`cat /tmp/domain.$$`"
resolution="`cat /tmp/resolution.$$`"
mbr="`cat /tmp/mbr.$$`"


##Выполняем установку
##Perform the installation
#old /usr/bin/calculate --disk=$devinst --set-hostname=$hostn --set-domain=$domain --set-video_resolution=$resolution --set-mbr=$mbr
### параметр -f отключает вопросы установщика во время установки
### -f option disables the questions the installer during installation
/usr/bin/cl-install -f -d $devinst -w $devswap --hostname $hostn,$domain --X $resolution --mbr $mbr

	if [ LANG=ru_RU.UTF-8 = "LANG=ru_RU.UTF-8" ];
	then
	$DIALOG $OPTS --msgbox "Система установлена - теперь необходима перезагрузка." 10 60
	$DIALOG $OPTS --yesno "Перегрузить компьютер?" 15 60
	else
	$DIALOG $OPTS --msgbox "The system is installed - now a reboot." 10 60
	$DIALOG $OPTS --yesno "Reboot the computer?" 15 60
	fi
       if [ $? = "0" ]
        then
        reboot
       fi
    fi
   fi
   F="`cat /tmp/instalmenu.$$`"


##################################Пункт 3 главного меню
##################################Paragraph 3 of the main menu
elif [ $R = "3" ]; then

#ls /dev | grep sd > /tmp/devinput.$$

	if [ LANG=ru_RU.UTF-8 = "LANG=ru_RU.UTF-8" ];
	then
        $DIALOG $OPTS --title "Жесткие диски установленные в вашей системе." --textbox /tmp/devinput 30 70
	$DIALOG $OPTS --title "Выбор диска для установки" --menu "Введите диск для установки.\n У вас установленны диски\n\n$devinputopis0\n\n$devinputopis1\n\n$devinputopis2\n\n$devinputopis3\n\n" 30 60 4 /dev/sda "/dev/sda" /dev/sdb "/dev/sdb" /dev/sdd "/dev/sdd" /dev/sdc "/dev/sdc" 2>/tmp/devformat.$$
	$DIALOG $OPTS --title "Выбор раздела для установки" --inputbox "Введите раздел диска для установки. \n Например 2 по умолчанию, для  /dev/sda2 или /dev/sdb2 и тп.\nили 3, для  /dev/sda3 или /dev/sdb3 и тп." 30 60 "2" 2>/tmp/devinstall.$$
	$DIALOG $OPTS --title "Ввод имени компьютера в сети" --inputbox "Введите имя компьютера. \n Например calculate по умолчанию" 30 60 "calculate" 2>/tmp/hostn.$$
	$DIALOG $OPTS --title "Ввод имени домена" --inputbox "Введите имя домена. \n Например home (по умолчанию)" 30 60 "home" 2>/tmp/domain.$$
#````````$DIALOG $OPTS --radiolist "Выбирите желаемое разрешение экрана" 20 40 3 1024x768 "1024x768" on 800x600 "800x600" off 640x480 "640x480" off 2>/tmp/resolution.$$
	$DIALOG $OPTS --title "Выбор разрешения экрана" --inputbox "Введите желаемое разрешение экрана. \n Например 1024x768 (по умолчанию)" 30 60 "1024x768" 2>/tmp/resolution.$$
	$DIALOG $OPTS --title "Выбор установки загрузчика" --menu "Записать загрузчик в mbr \n yes или no \n (переход с помошью стрелок \n выбор с помошью клавиши 'ENTER')" 30 60 2 yes "ДА" no "НЕТ" 2>/tmp/mbr.$$
        $DIALOG $OPTS --yesno "Сейчас будет произведена установка системы на жесткий диск.

    Установить?" 15 60
	else
	$DIALOG $OPTS --title "Hard drives installed in your system." --textbox /tmp/devinput 30 70
	$DIALOG $OPTS --title "Select the disk to install" --menu "Enter the drive for installation.\n Have you installed drive\n\n$devinputopis0\n\n$devinputopis1\n\n$devinputopis2\n\n$devinputopis3\n\n" 30 60 4 /dev/sda "/dev/sda" /dev/sdb "/dev/sdb" /dev/sdd "/dev/sdd" /dev/sdc "/dev/sdc" 2>/tmp/devformat.$$
	$DIALOG $OPTS --title "Selecting a partition to install" --inputbox "Enter the partition to install. \n For example 2 by default, for  /dev/sda2 or /dev/sdb2\nor 3, for  /dev/sda3 or /dev/sdb3." 30 60 "2" 2>/tmp/devinstall.$$
	$DIALOG $OPTS --title "Enter the name of the computer network" --inputbox "Enter the computer name. \n For example calculate the default" 30 60 "calculate" 2>/tmp/hostn.$$
	$DIALOG $OPTS --title "Enter a domain name" --inputbox "Enter a domain name. \n For example home (default)" 30 60 "home" 2>/tmp/domain.$$
#````````$DIALOG $OPTS --radiolist "Выбирите желаемое разрешение экрана" 20 40 3 1024x768 "1024x768" on 800x600 "800x600" off 640x480 "640x480" off 2>/tmp/resolution.$$
	$DIALOG $OPTS --title "The choice of screen resolution" --inputbox "Enter the desired screen resolution. \n For example 1024x768 (default)" 30 60 "1024x768" 2>/tmp/resolution.$$
	$DIALOG $OPTS --title "Selecting the boot loader" --menu "Record loader to mbr \n yes or no \n (transition with the aid of the arrows \n selection with the aid of key 'ENTER')" 30 60 2 yes "YES" no "NO" 2>/tmp/mbr.$$
        $DIALOG $OPTS --yesno "Now the system will be installed on the hard disk.

    Install?" 15 60
	fi
        if [ $? = "0" ]
        then
devformat="`cat /tmp/devformat.$$`"
devinstall="`cat /tmp/devinstall.$$`"
devinsttmp="`cat /tmp/devformat.$$``cat /tmp/devinstall.$$`"
echo -e $devinsttmp>/tmp/devinst.$$
devinst="`cat /tmp/devinst.$$`"

hostn="`cat /tmp/hostn.$$`"
domain="`cat /tmp/domain.$$`"
resolution="`cat /tmp/resolution.$$`"
mbr="`cat /tmp/mbr.$$`"

#Подключаем swap раздел
swapon -a

#Выполняем установку
#old /usr/bin/calculate --disk=$devinst --set-hostname=$hostn --set-domain=$domain --set-video_resolution=$resolution --set-mbr=$mbr
### параметр -f отключает вопросы установщика во время установки
### -f option disables the questions the installer during installation
/usr/bin/cl-install -f -d $devinst -w $devswap --hostname $hostn,$domain --X $resolution --mbr $mbr
	
	if [ LANG=ru_RU.UTF-8 = "LANG=ru_RU.UTF-8" ];
	then
       $DIALOG $OPTS --msgbox "Система установлена - теперь необходима перезагрузка." 10 60
       $DIALOG $OPTS --yesno "Перегрузить компьютер?" 15 60
	else
	$DIALOG $OPTS --msgbox "The system is installed - now a reboot." 10 60
       $DIALOG $OPTS --yesno "Reboot the computer?" 15 60
	fi
       if [ $? = "0" ]
        then
        reboot
       fi

   fi
   F="`cat /tmp/instalmenu.$$`"

##################################Пункт 4 главного меню
##################################Paragraph 4 of the main menu
elif [ $R = "4" ]; then

#ls /dev | grep sd > /tmp/devinput.$$

	if [ LANG=ru_RU.UTF-8 = "LANG=ru_RU.UTF-8" ];
        then
        $DIALOG $OPTS --title "Жесткие диски установленные в вашей системе." --textbox /tmp/devinput 30 70
	$DIALOG $OPTS --title "Выбор диска для форматирования" --menu "Введите диск для разбиения. \n У вас установленны диски\n\n$devinputopis0\n\n$devinputopis1\n\n$devinputopis2\n\n$devinputopis3\n\n" 30 60 4 /dev/sda "/dev/sda" /dev/sdb "/dev/sdb" /dev/sdd "/dev/sdd" /dev/sdc "/dev/sdc" 2>/tmp/devformat.$$
        $DIALOG $OPTS --title "Ввод размера раздела подкачки." --inputbox "Введите размер swap раздела.\nНапример по умолчанию в гигабайтах +10G\nили мегабайтах +10000M\nили килобайтах +10000000K\n(обязательны к вводу буквы G или M или K и знак +)" 30 60 "+10G" 2>/tmp/swapsize.$$
        $DIALOG $OPTS --title "Ввод размера первого раздела." --inputbox "Введите размер первого раздела.\nНапример по умолчанию в гигабайтах +30G\nили мегабайтах +30000M\nили килобайтах +30000000K\n(обязательны к вводу буквы G или M или K и знак +)" 30 60 "+30G" 2>/tmp/sd2size.$$
        $DIALOG $OPTS --title "Ввод размера второго раздела." --inputbox "Введите размер второго раздела. \n Например по умолчанию пустая строка. \n Если строка пустая то второй раздел займет \n всю оставшуюся часть диска - рекомендуется\n(буква G,M,K и знак + обязательны)" 30 60 "$1" 2>/tmp/sd3size.$$
        $DIALOG $OPTS --title "Файловая система первого диска" --menu "Файловая система первого диска. \n Например по умолчаню ext3 (по умолчанию, рекомендуется)" 30 60 4 ext3 "ext3" xfs "xfs" reiserfs "reiserfs" jfs "jfs" 2>/tmp/fssd2.$$
	$DIALOG $OPTS --title "Файловая система второго диска" --menu "Файловая система второго диска. \n Например по умолчаню ext3 (по умолчанию, рекомендуется)" 30 60 4 ext3 "ext3" xfs "xfs" reiserfs "reiserfs" jfs "jfs" 2>/tmp/fssd3.$$
	$DIALOG $OPTS --title "Выбор раздела для установки" --inputbox "Введите раздел диска для установки. \n Например 2 по умолчанию, для /dev/sda2 или /dev/sdb2 и тп.\n или 3 для /dev/sda3 или /dev/sdb3 и тп." 30 60 "2" 2>/tmp/devinstall.$$
	else
	$DIALOG $OPTS --title "Hard drives installed in your system." --textbox /tmp/devinput 30 70
	$DIALOG $OPTS --title "Select the disk to be formatted" --menu "Enter the drive to partition. \n Have you installed drive\n\n$devinputopis0\n\n$devinputopis1\n\n$devinputopis2\n\n$devinputopis3\n\n" 30 60 4 /dev/sda "/dev/sda" /dev/sdb "/dev/sdb" /dev/sdd "/dev/sdd" /dev/sdc "/dev/sdc" 2>/tmp/devformat.$$	
	$DIALOG $OPTS --title "Enter amount of swap space." --inputbox "Enter the size of swap partition.\nFor example by default in GB +10G\nor megabytes +10000M\nor kilobytes +10000000K\n(required to enter letters G or M or K and sign +)" 30 60 "+10G" 2>/tmp/swapsize.$$
	$DIALOG $OPTS --title "Enter the size of the first section." --inputbox "Enter the size of the first section.\nFor example by default in GB +30G\nor megabytes +30000M\nor kilobytes +30000000K\n(required to enter letters G or M or K and sign +)" 30 60 "+30G" 2>/tmp/sd2size.$$
	$DIALOG $OPTS --title "Enter the size of the second section." --inputbox "Enter the size of the second section. \n For example the default empty string. \n If the string is empty then the second section \n will take the rest of the disc - recommended\n(letter G,M,K and sign + required)" 30 60 "$1" 2>/tmp/sd3size.$$
	$DIALOG $OPTS --title "The file system of the first disk" --menu "The file system of the first disk. \n For example the default ext3 (by default, it is recommended)" 30 60 4 ext3 "ext3" xfs "xfs" reiserfs "reiserfs" jfs "jfs" 2>/tmp/fssd2.$$
	$DIALOG $OPTS --title "The file system of the second disk" --menu "The file system of the second disk. \n For example the default ext3 (by default, it is recommended)" 30 60 4 ext3 "ext3" xfs "xfs" reiserfs "reiserfs" jfs "jfs" 2>/tmp/fssd3.$$
	$DIALOG $OPTS --title "Selecting a partition to install" --inputbox "Enter the partition to install. \n For example 2 by default, /dev/sda2 or /dev/sdb2 \n or 3 for /dev/sda3 or /dev/sdb3." 30 60 "2" 2>/tmp/devinstall.$$
	fi	



devformat="`cat /tmp/devformat.$$`"
devformat1="`cat /tmp/devformat.$$`1"
devformat2="`cat /tmp/devformat.$$`2"
devformat3="`cat /tmp/devformat.$$`3"
swapsize="`cat /tmp/swapsize.$$`"
sd2size="`cat /tmp/sd2size.$$`"
sd3size="`cat /tmp/sd3size.$$`"
fssd2="`cat /tmp/fssd2.$$`"
fssd3="`cat /tmp/fssd3.$$`"

devinstall="`cat /tmp/devinstall.$$`"
devinsttmp="`cat /tmp/devformat.$$``cat /tmp/devinstall.$$`"
echo -e $devinsttmp>/tmp/devinst.$$
devinst="`cat /tmp/devinst.$$`"


        $DIALOG $OPTS --yesno "Приступаем - все разделы диска $devformat будут уничтожены!!\n\n
        Будут созданы три раздела\n\n$devformat1 - swap раздел $swapsize Гигабайт\n\n$devformat2 - /root раздел размером $sd2size Гигабайт\n\n$devformat3 - весь оставшийся объем диска\nдля папки /home или установки другой версии системы\n\nВы обсолютно уверены что хотите форматировать этот диск? " 40 60
        if [ $? = "0" ]
        then

#devformat="`cat /tmp/devformat.$$`"

##Отключаем все swap разделы
swapoff -a

##Уничтожаем разделы на жестком диске
echo -e "d\n10\nd\n9\nd\n8\nd\n7\nd\n6\nd\n5\nd\n4\nd\n3\nd\n2\nd\n1\nw">/tmp/fdiskdel.$$
fdisk $devformat < /tmp/fdiskdel.$$

##Разбиваем жесткий диск
echo -e "n\np\n1\n\n$swapsize\nn\np\n2\n\n$sd2size\nn\np\n3\n\n$sd3size\nt\n1\n82\na\n$devinstall\nw">/tmp/fdiskinput.$$
fdisk $devformat < /tmp/fdiskinput.$$

##Форматируем swap раздел
devswap="`cat /tmp/devformat.$$`1"
mkswap $devswap

##Подключаем swap раздел
swapon $devswap

##Форматируем 1 раздел
devsd2="`cat /tmp/devformat.$$`2"
mkfs.$fssd2 $devsd2

##Форматируем 2 раздел
devsd3="`cat /tmp/devformat.$$`3"
mkfs.$fssd3 $devsd3

	if [ LANG=ru_RU.UTF-8 = "LANG=ru_RU.UTF-8" ];
        then
        $DIALOG $OPTS --title "Ввод имени компьютера в сети" --inputbox "Введите имя компьютера. \n Например calculate по умолчанию" 30 60 "calculate" 2>/tmp/hostn.$$
        $DIALOG $OPTS --title "Ввод имени домена" --inputbox "Введите имя домена. \n Например home (по умолчанию)" 30 60 "home" 2>/tmp/domain.$$
	$DIALOG $OPTS --title "Выбор разрешения экрана" --inputbox "Введите желаемое разрешение экрана. \n Например 1024x768 (по умолчанию)" 30 60 "1024x768" 2>/tmp/resolution.$$
	$DIALOG $OPTS --title "Выбор установки загрузчика" --menu "Записать загрузчик в mbr \n yes или no \n (переход с помошью стрелок \n выбор с помошью клавиши 'ENTER')" 30 60 2 yes "ДА" no "НЕТ" 2>/tmp/mbr.$$
        $DIALOG $OPTS --yesno "Сейчас будет произведена установка системы на жесткий диск в режиме --buil.

        Установить?" 15 60
	else
	$DIALOG $OPTS --title "Enter the name of the computer network" --inputbox "Enter the computer name. \n For example calculate the default" 30 60 "calculate" 2>/tmp/hostn.$$
	$DIALOG $OPTS --title "Enter a domain name" --inputbox "Enter a domain name. \n For example home (default)" 30 60 "home" 2>/tmp/domain.$$
	$DIALOG $OPTS --title "The choice of screen resolution" --inputbox "Enter the desired screen resolution. \n For example 1024x768 (default)" 30 60 "1024x768" 2>/tmp/resolution.$$
	$DIALOG $OPTS --title "Selecting the boot loader" --menu "Record loader to mbr \n yes or no \n (transition with the aid of the arrows \n selection with the aid of key 'ENTER')" 30 60 2 yes "YES" no "NO" 2>/tmp/mbr.$$
	$DIALOG $OPTS --yesno "Now the system will be installed on the hard disk --build.

        Install?" 15 60
        fi
        if [ $? = "0" ]
        then


hostn="`cat /tmp/hostn.$$`"
domain="`cat /tmp/domain.$$`"
resolution="`cat /tmp/resolution.$$`"
mbr="`cat /tmp/mbr.$$`"


##Выполняем установку
#old /usr/bin/calculate --disk=$devinst --set-hostname=$hostn --set-domain=$domain --set-video_resolution=$resolution --set-mbr=$mbr --build
### параметр -f отключает вопросы установщика во время установки
### -f option disables the questions the installer during installation
/usr/bin/cl-install -f -d $devinst -w $devswap --hostname $hostn,$domain --X $resolution --mbr $mbr --build

	if [ LANG=ru_RU.UTF-8 = "LANG=ru_RU.UTF-8" ];
	then
       $DIALOG $OPTS --msgbox "Система установлена - теперь необходима перезагрузка." 10 60
       $DIALOG $OPTS --yesno "Перегрузить компьютер?" 15 60
	else
	$DIALOG $OPTS --msgbox "The system is installed - now a reboot." 10 60
       $DIALOG $OPTS --yesno "Reboot the computer?" 15 60
	fi
       if [ $? = "0" ]
        then
        reboot
       fi
    fi
   fi
   F="`cat /tmp/instalmenu.$$`"
 fi
       exit


done
