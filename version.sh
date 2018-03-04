#! /bin/dash


#############################################################################################
# The following script has been realized in an Universitary context
# It allow user to get files under versioning, create new comit, load previous commit
# and get informations about the commits trough log messages
# The scipt has been done for Dash interpretor
# For further information on the script, see the README file

# @Authors : FEDERSPIEL Remi & DELAVOUX Thibault
# @UE : Systeme et programmation Systeme
# L2 informatique - Université de Franche-Comté
#############################################################################################


#########################################################
#					Utility function
#########################################################

# The following function return the number of the last commit
# It do not takes any arguments but get the basename and path of the original file
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

# The funtion add a new file under versioning. It will create hidden directory (if not already created)
# and create 2 copy of the file in this directory.
# The function expect one argument :
# 	- The file path and name
add() {
	if ! [ -d "$PATH_FILE/.version" ]
	then
		mkdir "$PATH_FILE/.version"
	fi

	if [ -f "$PATH_FILE/.version/$BASE_NAME.1" ]
	then
		echo "Error! ’$1’ already added." >&2
		exit 0
	fi

	cp "$1" "$PATH_FILE/.version/$BASE_NAME.1"
	cp "$1" "$PATH_FILE/.version/$BASE_NAME.latest"
	echo "Added a new file under versioning : $BASE_NAME"

	touch "$PATH_FILE/.version/$BASE_NAME.log"
	echo "$(date) Add to versioning" > $PATH_FILE/.version/$BASE_NAME.log
}


# The function add a new commit for a file already under versioning
# A patch will be created between the last version (.latest) and the original file state
# The function take 3 arguments : 
# 	- file name gave to the script that is the only
# 	- [OPT] option name (only -m available to add a message to the log file to explain the commit)
# 	- [OPT] message (String)
commit() { 

	if [ ! -f "$PATH_FILE/.version/$BASE_NAME.1" ];then
		echo "Error, no adds for the selected file" >&2
		echo "Usage: ./vesion.sh add file.extension [OPT]" >&2 
		echo "Where OPT must be -m \"Message to insert\" " >&2
 	fi


	if [ -n "$2" ] && [ "$2" != "-m" ];then
		echo "Error, wrong argument" >&2
		echo "Usage: ./vesion.sh add file.extension [OPT]" >&2
		echo "Where OPT must be -m \"Message to insert\" " >&2
		exit 3
	fi

 	#check if last version is different than original file
 	if ! [ -n "$(diff -u $1 $PATH_FILE/.version/$BASE_NAME.latest)" ];then
		echo "The file is already similar to latest commit of '$1'"
		exit 0
	fi

 	if [ ! -f "$PATH_FILE/.version/$BASE_NAME.log" ];then
		echo "Error, can't find the log file" >&2
		echo "The file may not be under versioning yet" >&2
		echo "Usage : ./version.sh add file.extension" >&2
		exit 1
	fi



	#get the last version number    
 	last_version $1
 	LAST_VERSION=$(echo $?)

 	#Default message in the log file if no comments passed in arguments
 	if [ ! -n "$2" ] || [ ! -n "$3" ];then
		echo "$(date) Add new version" >> $PATH_FILE/.version/$BASE_NAME.log
	fi

	#Print the comments and date on the log file without line feed
	if [ "$2" = "-m" ];then
		echo "$(date) $(echo $3 | tr -d '\n')" >> $PATH_FILE/.version/$BASE_NAME.log
	fi

	#Commit if needed
 	diff -u $1 $PATH_FILE/.version/$BASE_NAME.latest > $PATH_FILE/.version/$BASE_NAME.$(($LAST_VERSION +1))
 	cp $1 $PATH_FILE/.version/$BASE_NAME.latest 
 	
 	echo "Committed a new version : $(($LAST_VERSION +1))"
}


# The function remove a file from versioning and delete all the files, patch and log associated
# The function expect one argument :
# 	- The file path and name
rm_f() {
	if ! [ -f "$PATH_FILE/.version/$BASE_NAME.1" ]
	then
		echo "Error! ’$1’ is not a file under control the version manager." >&2
		exit 2
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


# The function reloads the last version commited for a file under versioning
# The function expects one argument :
# 	- The file path and name
revert() {
	if ! [ -f "$PATH_FILE/.version/$BASE_NAME.1" ]
	then
		echo "Error! ’$1’ is not a file under control the version manager." >&2
		exit 2
	fi

	cp $PATH_FILE/.version/$BASE_NAME.latest $1
	echo "Reverted to the latest version"
}

# The function prints on the standard output the difference between the last version commited and a vile (already under versioning)
# The function expects one argument :
# 	- The file path and name
diff_f() {
	if ! [ -f "$PATH_FILE/.version/$BASE_NAME.1" ]
	then
		echo "Error! ’$1’ is not a file under control the version manager." >&2
		exit 2
	fi

 	if ! [ -n "$(diff -u $1 $PATH_FILE/.version/$BASE_NAME.latest)" ]
 	then
		echo "The files are similar." >&2
		exit 0
	else 
		diff -u $PATH_FILE/.version/$BASE_NAME.latest $1  
	fi
}

# The function loads a previous version of a file under versioning
# The function expects two arguments :
# 	- The file path and name
# 	- The version's number to load
checkout() {

	FILE_NAME=$(echo $BASE_NAME | cut -d. -f1)

	#check if the number of version is valid   
	if [ $2 -lt 1 ];then
		echo "Error, invalid argument for version number, should be positive" >&2
		echo "Usage: ./vesion.sh checkout file.extension N" >&2
		exit 3
	fi

	#check if number of version is under last version number
	if ! [ -f "$PATH_FILE/.version/$BASE_NAME.$2" ];then
		echo "The version does not exist, please choose a correct number of version for '$1'"
		exit 4
	fi

	#check version is different than original file
	if ! [ -n "$(diff -u $1 $PATH_FILE/.version/$BASE_NAME.$2)" ];then
		echo "The file is already similar to version $2"
		exit 0
	fi


	cp $PATH_FILE/.version/$BASE_NAME.latest $PATH_FILE/.version/$BASE_NAME.temp


	#checkout execution
	cp $PATH_FILE/.version/$BASE_NAME.1 $1
	if [ $2 -eq 1 ];then
		echo "Checked out version : $2"
		exit 0
	fi

	for I in $(seq 2 $2);do
		patch -R -u $1 $PATH_FILE/.version/$BASE_NAME.$I 1> /dev/null
	done

	echo "Checked out version : $2"
}

# The function prints on the standard output the log-file for a file under versioning
# The function does not expect aruments
log() {
	if [ ! -f "$PATH_FILE/.version/$BASE_NAME.log" ];then
		echo "Error, can't find the log file" >&2
		echo "The file may not be under versioning yet" >&2
		echo "Usage : ./version.sh add file.extension" >&2
		exit 1
	fi

	cat -n $PATH_FILE/.version/$BASE_NAME.log
}



#########################################################
#					MAIN
#########################################################


#Check if file exist and is a regular file
if [ ! -f $2 ];then
	echo "Error, the file do not exist or isn't a regular file" >&2 
	echo "Usage: ./vesion.sh command file.extension [OPT]" >&2
	exit 1
fi

#check validity of arguments number
if [ $# -lt 2 -o $# -gt 4 ];then
		echo "Error, invalid number of arguments" >&2
		echo "Usage: ./vesion.sh action file.extension [OPT]" >&2
		echo "Where action can be add, rm, commit, revert, diff, log or checkout" >&2
		exit 3
fi

if [ $1 != 'ci' -o $1 != 'commit' ] && [ $# -gt 2 ];then
		echo "Error, invalid number of arguments" >&2
		echo "Usage: ./vesion.sh action file.extension [OPT]" >&2
		echo "Where action can be add, rm, commit, revert, diff, log or checkout" >&2
		exit 3
fi

PATH_FILE=$(dirname $2)
BASE_NAME=$(basename $2)

case $1 in
	"add") add $2;;

	"rm") rm_f $2;;

	"commit" |"ci") commit "$2" "$3" "$4";;

	"revert") revert $2;;

	"diff") diff_f $2;;

	"log") log;;

	"checkout") if [ $# -lt 3 ] || ! [ "$(echo $3 | grep "^[[:digit:]] *$")" ];then
					echo "Error, invalid number of arguments or argument type" >&2
					echo "Usage: ./vesion.sh action file.extension N" >&2
					echo "Where N is the version number to load (integer)" >&2
					exit 1
				fi
				checkout $2 $3;;

	*) echo "Error, the command does not exist." >&2
	   echo "Usage: ./vesion.sh action file.extension [OPT]" >&2
	   echo "Where action can be add, rm, commit, revert, diff, log or checkout" >&2
       exit 10;;
esac
