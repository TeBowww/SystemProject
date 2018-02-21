#! /bin/dash


#########################################################
#					Utility function
#########################################################

# get the number of the last version saved for a file
last_version(){
	LAST_VERSION=0
	for I in $(ls $PATH_FILE/.version/$BASE_NAME.[[:digit:]]);do
		LAST_VERSION=${I##*.}
	done
	return $LAST_VERSION
}

#########################################################
#					Program Functions
#########################################################

commit() { 


	#check if file already is under control (add function previously used)
	if [ ! -f "$PATH_FILE/.version/$BASE_NAME.1" ];then
		echo "Error, no adds for the selected file" >&2
		echo "Usage: ./vesion.sh add file.extension" >&2
 	fi

 	#check if last version is diffrent than original file
 	if ! [ -n "$(diff -u $1 $PATH_FILE/.version/$BASE_NAME.latest)" ];then
		echo "The file is already similar to lastest commit of '$1'"
		exit 0
	fi

 	#get the last version number
 	last_version $1
 	LAST_VERSION=$(echo $?)

 	#Commit if needed
 	diff -u $1 $PATH_FILE/.version/$BASE_NAME.latest > $PATH_FILE/.version/$BASE_NAME.$(($LAST_VERSION +1))
 	cat $1 > $PATH_FILE/.version/$BASE_NAME.latest

 	#afficher le numero de version
 	echo "Committed a new version : $(($LAST_VERSION +1))"
}


add () {
	if ! [ -d "$PATH_FILE/.version" ]
	then
		mkdir "$PATH_FILE/.version"
	fi

	if ! [ -f "$1" ]
	then
		echo "Error! ’$1’ is not a file." >&2
		exit 2
	fi

	if [ -f "$PATH_FILE/.version/$BASE_NAME.1" ]
	then
		echo "Error! ’$1’ already added." >&2
		exit 3
	fi

	cp "$1" "$PATH_FILE/.version/$BASE_NAME.1"
	cp "$1" "$PATH_FILE/.version/$BASE_NAME.latest"
}

rm_f () {
	if ! [ -f "$1" ]
	then
		echo "Error! ’$1’ is not a file." >&2
		exit 4
	fi

	if ! [ -f "$PATH_FILE/.version/$BASE_NAME.1" ]
	then
		echo "Error! ’$1’ is not a file under control the version manager." >&2
		exit 5
	fi

	echo "Are you sure you want to delete ’$1’ from versioning? (yes/no)"

	read RM_ANSWER

	if [ $RM_ANSWER = "yes" ]
	then
		rm $PATH_FILE/.version/$BASE_NAME.*
		echo "'$1' is not under versioning anymore."
	fi

	if [ $(ls $PATH_FILE/.version | wc -l) -eq 0 ]
	then
		rmdir $PATH_FILE/.version
	fi
}

revert () {
	if ! [ -f "$1" ]
	then
		echo "Error! ’$1’ is not a file." >&2
		exit 6
	fi

	if ! [ -f "$PATH_FILE/.version/$BASE_NAME.1" ]
	then
		echo "Error! ’$1’ is not a file under control the version manager." >&2
		exit 7
	fi

	cp $PATH_FILE/.version/$BASE_NAME.latest $1
	echo "Reverted to the latest version"
}

diff_f () {
	if ! [ -f "$1" ]
	then
		echo "Error! ’$1’ is not a file." >&2
		exit 8
	fi

	if ! [ -f "$PATH_FILE/.version/$BASE_NAME.1" ]
	then
		echo "Error! ’$1’ is not a file under control the version manager." >&2
		exit 9
	fi

	if [ $(cat $PATH_FILE/.version/$BASE_NAME.latest | wc -l) -eq 0 -a $(cat $1 | wc -l) -eq 0 ]
	then
		echo "The two files are empty."
	else 
		diff -u $PATH_FILE/.version/$BASE_NAME.latest $1
	fi
}

checkout() { 

	FILE_NAME=$(echo $BASE_NAME | cut -d. -f1)

	#Check if the number of version is valid
	if [ $2 -lt 1 ];then
		echo "Error, invalid argument for version number, should be positive" >&2
		echo "Usage: ./vesion.sh checkout file.extension N" >&2
		exit 2
	fi

	#check if number of version is under last version number
	if ! [ -f "$PATH_FILE/.version/$BASE_NAME.$2" ];then
		echo "The version do not exist, please choose a correct number of version for '$1'"
		exit 4
	fi

	#check version is diffrent than original file
	if ! [ -n "$(diff -u $1 $PATH_FILE/.version/$BASE_NAME.$2)" ];then
		echo "The file is already similar to version $2"
		exit 0
	fi

	#copy the first version in the file
	cp $PATH_FILE/.version/$BASE_NAME.1 $1

	if [ $2 -eq 1 ];then
		echo "Checked out version : $2"
		exit 0
	fi

	#loop to apply patch
	for I in $(seq 2 $2);do
		patch -R -u $1 $PATH_FILE/.version/$BASE_NAME.$I 1> /dev/null
	done

	#affichage du message de réussite de l'oppération
	echo "Checked out version : $2"
}



#########################################################
#					MAIN
#########################################################


#Check if file exist and is a regular file
if [ ! -f $2 ];then
	echo "Error, the file do not exist or isn't a regular file" >&2 
	echo "Usage: ./vesion.sh commit file.extension" >&2
	exit 2
fi

#check validity of arguments number
if [ $# -lt 2 ];then
		echo "Error, invalid number of arguments" >&2
		echo "Usage: ./vesion.sh action file.extension [OPT]" >&2
		echo "Where action can be add, rm, commit, revert, diff, log or checkout" >&2
		exit 1
fi

PATH_FILE=$(dirname $2)
BASE_NAME=$(basename $2)

case $1 in
	"add") add $2;;

	"rm") rm_f $2;;

	"commit" |"ci") commit $2;;

	"revert") revert $2;;

	"diff") diff_f $2;;

	#"log") echo "Ok, on continue";;

	"checkout") if [ $# -lt 3 ] || ! [ "$(echo $3 | grep "^[[:digit:]] *$")" ];then
					echo "Error, invalid number of arguments or argument type" >&2
					echo "Usage: ./vesion.sh action file.extension N" >&2
					echo "Where N is the version number to load (integer)" >&2
					exit 1
				fi
				checkout $2 $3;;

	*) echo "Error, the command do not exists." >&2
       exit 10;;
esac
