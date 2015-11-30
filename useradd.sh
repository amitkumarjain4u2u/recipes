#!/bin/bash
##
## Verify whether the parameters supplied or not
## If supplied, check whether users.txt file
## Exist, readable or not
if [ $# -eq 0 ];
	then 
		echo "Usage: '$0<SPACE><USERS_FILE>";
		exit 1;
	elif [ -r $1 ];
		then
			USERS_FILE=$1;
			#read -s -p "Enter password : " PASSWORD;
			echo "*******************";
			echo "=======================================";
	else
		echo "Either the specified file doesn't exist
					or the file is not readable!
				Check the file path/permission!";
		exit 1;
fi;
## Initialize the counters
SKIPPED=0;
CREATED=0;
FAILED=0;
##SALT=kg;	## This is salt for perl, can be anything
## Initialize the files
ADDEDUSERS="/tmp/added_users.txt"
SKIPPED_AC_FL="/tmp/skippedusers.txt";
FAILED_AC_FL="/tmp/failedusers.txt";
## Check if the file SKIPPED_AC_FL exist
## If exist, then make it empty
if [ -s $SKIPPED_AC_FL ];
	then
		echo -n > $SKIPPED_AC_FL;
fi;
## Check if the file FAILED_AC_FL exist
## If exist, then make it empty
if [ -s $FAILED_AC_FL ];
	then
		echo -n > $FAILED_AC_FL;
fi;
#############
## Initialize the for loop
for NAME in `cat $USERS_FILE`;
	do
		if id -u "$NAME" >/dev/null 2>&1;
			then 
				echo "Unix Account '$NAME' already exist
					Skipping.......";
				echo $NAME >> $SKIPPED_AC_FL;
				((SKIPPED++));
			continue;
			else
				echo "Creating Unix account '$NAME'";
				PASSCODE=$( dd if=/dev/urandom bs=1 count=8 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev )
				useradd -m -p $PASSCODE $NAME -s /bin/bash;
				if [ $? -eq 0 ];
					then 
						echo "Unix Account '$NAME' has been created";
						((CREATED++));	## var=$((var+1)), ((var=var+1)), ((var+=1))
						echo "----------------------------" >> $ADDEDUSERS
						echo "UserID: $NAME" >> $ADDEDUSERS
						echo "Password: $PASSCODE" >> $ADDEDUSERS
					else
						echo "Account '$NAME' creation has failed!
								Please check the logs!";
						echo "$NAME" >> $FAILED_AC_FL;
						((FAILED++));	## ((var++)), let "var=var+1", let "var+=1", let "var++"
				fi;
		fi;
	done;
## Display the report
echo "=======================================";
echo "Accounts successfully created: $CREATED";
echo "Accounts skipped             : $SKIPPED";
echo "Accounts Failed due to errors: $FAILED";
echo "----------------------------------";
if [ -s $SKIPPED_AC_FL ];
	then 
		echo "Below are the skipped accounts:";
		nl $SKIPPED_AC_FL;
fi;
if [ -s $FAILED_AC_FL ];
	then
		echo "Below are the failed accounts:";
		nl $FAILED_AC_FL;
fi;
echo "=======================================";
