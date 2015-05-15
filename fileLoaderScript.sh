#!/bin/bash
# Source System
# Rename Old Files
# Archive Old Files
# Delete Old Files
# Process New Files
#

#
# Check for input parameters
#
#[ "$#" -ne 2 ] && { echo "Usage: Enter the source system and environment"; exit 1;}


#sourceSystem=$1
#env=$2


# 
# Read and execute the properties file in the current shell environment
#
#source inputs_$1_$2.properties


#set -o nounset
#

##
#
# Create DIFF_FILE with header information Function
#
##
create_diff_file(){

diff --new-line-format="" --unchanged-line-format="" <(sort "$INPUT_DIR"/"$SRC_FILE") <(sort "$INPUT_DIR"/"$SRC_FILE"".""$BASELINE_EXT")   > "$INPUT_DIR"/"$DIFF_FILE"
FIRST_LINE="$(head -n 1 "$INPUT_DIR"/"$SRC_FILE" )"
echo "First Line is "$FIRST_LINE
  if [ ! -s "$INPUT_DIR"/"$DIFF_FILE" ]
    then
    echo $INPUT_DIR/$DIFF_FILE " is empty"
    echo $FIRST_LINE >> $INPUT_DIR/$DIFF_FILE
  else
    echo $INPUT_DIR/$DIFF_FILE " is not empty"
    sed -i  -e  '1i'"$FIRST_LINE" "$INPUT_DIR"/"$DIFF_FILE"
  fi

}

#
# Process CAR_License files
#
process_CAR_License(){
echo "Copy source file " $SRC_FILE
cp "$SRC_DIR/$SRC_FILE" "$INPUT_DIR"/.
echo "Extract source file " $EXTRACTED_FILE
awk  -F '|' '{ print $1"|"$2"|"$3"|" $4 }' "$INPUT_DIR"/"$SRC_FILE"  > "$INPUT_DIR"/"$EXTRACTED_FILE"
chmod "$PERMISSION_CODE"  "$INPUT_DIR"/"$SRC_FILE"  "$INPUT_DIR"/"$EXTRACTED_FILE"
}

#
# Copy and Rename Files Function
#
copy_files(){

echo "First Run of the process.  Copy source file and create the diff file similar as source file"
echo "Copy and rename to "  $DIFF_FILE
cp "$SRC_DIR"/"$SRC_FILE" "$INPUT_DIR"/"$DIFF_FILE"
echo "Copy and rename to "  $INPUT_DIR/$SRC_FILE"."$BASELINE_EXT 
cp "$SRC_DIR"/"$SRC_FILE" "$INPUT_DIR"/"$SRC_FILE"".""$BASELINE_EXT" 
echo "Copy source file " $SRC_FILE
cp "$SRC_DIR"/"$SRC_FILE" "$INPUT_DIR"/.

chmod "$PERMISSION_CODE"  "$INPUT_DIR"/"$SRC_FILE"  "$INPUT_DIR"/"$DIFF_FILE" "$INPUT_DIR"/"$SRC_FILE"".""$BASELINE_EXT" 

}



##
#
# Check if the input folder has the source file. 
#
##

echo "Start check source file"
pushd . > /dev/null
cd "$INPUT_DIR/"

if [ ! -f "$SRC_FILE" ] 
then
echo "file " $SRC_FILE  "does not exist.  First time running this process."
FIRST_RUN="Y"
else
echo "This is not the first run of the process"
FIRST_RUN="N"
fi

out=$?

popd > /dev/null
echo "End check baseline file"


#
# Rename baseline file and diff file in input directory with timestamp. 
#
echo "Start rename files with timestamp"
if [[ "$SRC_SYSTEM" == "AGE" ]] || [[ "$SRC_SYSTEM" == "CAR_Finance" ]] || [[ "$SRC_SYSTEM" == "CAR_Bonus" ]] || [[ "$SRC_SYSTEM" == "CAR_Product" ]]
then
	for file in `ls -t "$INPUT_DIR" | grep -v '^d'`;
	do
	if [[ ${file: -$BASELINE_EXT_SIZE} == "$BASELINE_EXT"  ]] || [[ "$file" == "$DIFF_FILE"  ]] 
	then
	echo "File which needs to be renamed with timestamp " $file
	mv "$INPUT_DIR"/"$file" "$INPUT_DIR"/"$file"".""$TIMESTAMP"
	fi
	done
elif [[ $SRC_SYSTEM == "CAR_License" ]]
then
	for file in `ls -t $INPUT_DIR | grep -v '^d'`;
	do
	if [[ "$file" == "$SRC_FILE" ]] || [[ "$file" == "$EXTRACTED_FILE" ]] 
	then
	echo "File which needs to be renamed with timestamp " $file
	mv "$INPUT_DIR"/"$file" "$INPUT_DIR"/"$file"".""$TIMESTAMP"
	fi
	done

fi

out=$?

echo "End rename files with timestamp"

#
# Rename older version file to baseline file in input directory.
#


if [[ "$SRC_SYSTEM" == "AGE" ]] || [[ "$SRC_SYSTEM" == "CAR_Finance" ]] || [[ "$SRC_SYSTEM" == "CAR_Bonus" ]] || [[ "$SRC_SYSTEM" == "CAR_Product" ]]
then
echo "Start rename file with baseline extension"
	for file in `ls -t "$INPUT_DIR" | grep -v '^d'`;
	do
	if [[ "$file" == "$SRC_FILE" ]]
	then
	echo "Source file is " $file " rename with baseline extension"
	mv "$INPUT_DIR"/"$file" "$INPUT_DIR"/"$file"".""$BASELINE_EXT"
	fi
	done

out=$?

echo "End rename file with baseline extension"
fi 


#
# Copy old files from input directory to archive directory 
# Delete old files from input directory
#
echo "Start copy and delete processes"
if [[ "$SRC_SYSTEM" == "AGE" ]] || [[ "$SRC_SYSTEM" == "CAR_Finance" ]] || [[ "$SRC_SYSTEM" == "CAR_Bonus" ]] || [[ "$SRC_SYSTEM" == "CAR_Product" ]]
then
	for file in `ls -t "$INPUT_DIR" | grep -v '^d'`;
	do
	if [[ "$file" == "$DIFF_FILE""."*  ]]  || [[ "$file" == "$SRC_FILE"".""$BASELINE_EXT""."*  ]]
	then
	echo "Copy file " $file " over to archive directory "
	cp "$INPUT_DIR"/"$file"  "$ARCHIVE_DIR"/.
	echo "Delete file " $file
	rm "$INPUT_DIR"/"$file"
	fi
	done

out=$?

elif [[ "$SRC_SYSTEM" == "CAR_License" ]]
then
	for file in `ls -t "$INPUT_DIR" | grep -v '^d'`;
	do
	if [[ "$file" == "$EXTRACTED_FILE""."*  ]]  || [[ "$file" == "$SRC_FILE""."*  ]]
	then
	echo "Copy file " $file " over to archive directory "
	cp "$INPUT_DIR"/"$file"  "$ARCHIVE_DIR"/.
	echo "Delete file " $file
	rm "$INPUT_DIR"/"$file"
	fi
	done

out=$?

fi
echo "End copy and delete processes"
#
# find files in the archive folder and below and zip each file which is not .gz
#
find "$ARCHIVE_DIR"/ -type f ! -name '*.gz' -exec gzip "{}" \;

out=$?

#
# Copy files from source directory to input directory
# Generate DIFF file
#
echo "Start create process"

echo "Source System " $SRC_SYSTEM
echo "Copy file from source directory to input directory"
#pushd .
#cd $SRC_DIR
cp "$SRC_DIR"/"$SRC_FILE" "$INPUT_DIR"/"$SRC_FILE"
chmod "$PERMISSION_CODE" "$INPUT_DIR"/"$SRC_FILE"

out=$?

#popd

if [ "$FIRST_RUN" == "Y" ]
	then
	echo "First time processing file"
	if [[ "$SRC_SYSTEM" == "CAR_License" ]]
		then
		process_CAR_License
		out=$?
	else
		copy_files
		out=$?
	fi

else
	if [[  "$SRC_SYSTEM" == "AGE" ]]
		then
		echo "Perform transformation"
#		  xsltproc -o  "$INPUT_DIR"/"$DIFF_FILE" "$SCRIPT_DIR"/getChangeActivityInd.xsl "$INPUT_DIR"/"$SRC_FILE" 
		  perl  "$SCRIPT_DIR"/getChangeActivityInd.pl "$INPUT_DIR"/"$SRC_FILE"  "$INPUT_DIR"/"$DIFF_FILE"  
		out=$?

	elif [[ "$SRC_SYSTEM" == "CAR_Finance" ]] ||  [[  "$SRC_SYSTEM" == "CAR_Bonus" ]] || [[ "$SRC_SYSTEM" == "CAR_Product" ]] 
		then
		echo "Diff source system " $SRC_SYSTEM
		create_diff_file
		out=$?

	elif  [[ "$SRC_SYSTEM" == "CAR_License" ]]
		then
		process_CAR_License
		out=$?

	fi
	echo "End of nested if"
fi


echo "End create process"


#
# Return zero when it is complete
#

return $out
