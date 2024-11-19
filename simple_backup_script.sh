#!/bin/bash

clear

echo "##############################################################"
echo "#   ____    _                   _____   _____    _    _____  #"
echo "#  |  _ \  | |          /\     |_   _| |  __ \  ( )  / ____| #"
echo "#  | |_) | | |         /  \      | |   | |__) | |/  | (___   #"
echo "#  |  _ <  | |        / /\ \     | |   |  _  /       \___ \  #"
echo "#  | |_) | | |____   / ____ \   _| |_  | | \ \       ____) | #"
echo "#  |____/_ |______| /_/  __\_\_|_____| |_|  \_\ ____|_____/  #"
echo "#   / ____| |_   _| |  \/  | |  __ \  | |      |  ____|      #"
echo "#  | (___     | |   | \  / | | |__) | | |      | |__         #"
echo "#   \___ \    | |   | |\/| | |  ___/  | |      |  __|        #"
echo "#   ____) |  _| |_  | |  | | | |      | |____  | |____       #"
echo "#  |_____/  |_____| |_| _|_|_|_|_  __ |______| |______|      #"
echo "#  |  _ \      /\      / ____| | |/ / | |  | | |  __ \       #"
echo "#  | |_) |    /  \    | |      | ' /  | |  | | | |__) |      #"
echo "#  |  _ <    / /\ \   | |      |  <   | |  | | |  ___/       #"
echo "#  | |_) |  / ____ \  | |____  | . \  | |__| | | |           #"
echo "#  |____/  /_/    \_\  \_____| |_|\_\  \____/  |_|           #"
echo "#                                                            #"
echo "##############################################################"
echo ""

# Functions

clean_path() {
    if [[ "${ANSWER:0:1}" == "~" ]]; then   # Replace "~" with "home/$USER" and remove "/" at the end if either exists.
        ANSWER="/home/$USER${ANSWER:1}"     # This resolves the issue where if user uses "~" to specify their home directory,
    fi                                      # it will replace it with the full path so that the path can be checked if it exists or not.

    if [[ "${ANSWER: -1}" == "/" ]]; then   # Removing the "/" will prevent the script from adding "//" when specifiying
        ANSWER="${ANSWER%/}"                # where the "/backups" will be located.
    fi
}

is_valid_number() {     # Verify that the answer is greater than 0, and a valid int.
    while true; do
        if [[ "$ANSWER" =~ ^[0-9]+$ ]] && [ "$ANSWER" -gt 0 ]; then             
            echo -e "$ANSWER backup(s) will be stored at one time. \n"
            sleep 1 # Give the user time to read the output before moving on.
            break
        else
            read -ep "'$ANSWER' is not a valid answer. Please try again: " ANSWER
            echo""
        fi
    done
}   

is_y_n() {      #Verify that the answer is either 'y' or 'n'.
    while true; do
        if [ "$ANSWER" == "y" ] || [ "$ANSWER" == "n" ]; then
            break
        else
            read -ep "Invalid reponse. Please type 'y' or 'n': " ANSWER
            echo ""
        fi
    done
}

# Choose backup directory
read -ep "Where would you like to save your backups? (ex: /path/to/backups): " ANSWER
echo ""

    # Call function to clean path and set backup 
    clean_path
    BACKUP_DIR=$ANSWER

    # Loop until the entered path exists
    while [ ! -e "$BACKUP_DIR" ]; do
        echo -e "The path '$BACKUP_DIR' does not exist. Please try again. \n"
        sleep 1 # Give the user time to read the output before moving on.
        read -ep "Where would you like to save your backups? (ex: /path/to/backups): " ANSWER
        echo ""
        
        # Call function to clean path and set backup 
        clean_path
        BACKUP_DIR=$ANSWER
    done

    BACKUP_DIR="${BACKUP_DIR}/backups"  # Place folder within the directory called "backups"
    mkdir -p $BACKUP_DIR                # Make directory if it does not already exist

echo -e "Backups will be stored in: $BACKUP_DIR \n"    # Echo the location of backups
sleep 1 # Give the user time to read the output before moving on

# Choose directory to back up
read -ep "What folder would you like to backup? (ex: /home/yourname/Pictures): " ANSWER
echo ""

    # Call function to clean path
    clean_path
    BACKUP_TARGET=$ANSWER

    # Loop until the entered path exists
    while [ ! -e "$BACKUP_TARGET" ]; do
        echo -e "The path '$BACKUP_TARGET' does not exist. Please try again. \n"
        sleep 1 # Give the user time to read the output before moving on.
        read -ep "What folder would you like to backup? (ex: /home/yourname/Pictures): " ANSWER
        echo ""

        # Call function to clean path and set backup 
        clean_path
        BACKUP_TARGET=$ANSWER
    done

echo -e "$BACKUP_TARGET selected.\n"
sleep 1 # Give the user time to read the output before moving on.

# Path to exclusion list/ensure list exists
EXCLUDE_LIST="$BACKUP_DIR/.exclude_list.txt"
touch "$EXCLUDE_LIST"

# Add backup directory to avoid backing up a backup - failsafe
echo "$BACKUP_DIR" > "$EXCLUDE_LIST"

read -p "Would you like to exclude all hidden files and folders within the directory being backed up? (y/n): " ANSWER
echo ""

    # Verify answer is valid & set the variable
    is_y_n
    EXCLUDE_HIDDEN_ANSWER=$ANSWER

    # Give option to exclude all hidden files and folders
    if [ "$EXCLUDE_HIDDEN_ANSWER" == "y" ]; then
        echo "$BACKUP_TARGET/.*" >> $EXCLUDE_LIST
        echo -e "All hidden files and folders within directory will be ignored.\n"
    else
        echo -e "The backup will include all hidden files and folders.\n"
    fi

    sleep 1 # Give the user time to read the output before moving on.

read -p "Are there any other folders or files you would like to exclude within the folder? (y/n): " ANSWER
echo ""

# Verify answer is valid & set the variable
is_y_n
EXCLUDE_ANSWER=$ANSWER

# Check for file/folder exclusion within the directory to be archived
if [ "$EXCLUDE_ANSWER" == "y" ]; then
    # If yes, enter the loop to collect exclusions
    while true; do
        # Ask for a path to exclude
        read -ep "Enter a path to exclude from the backup (or type 'done' to finish): " ANSWER
        echo ""
        # Call function to clean path
        clean_path
        # Set the variable after function
        EXCLUDE_PATH=$ANSWER

        # Check if the user typed 'done' to exit the loop
        if [ "$EXCLUDE_PATH" == "done" ]; then
            echo "Exclusion list complete. The following paths will not be backed up:"
            echo "$(cat $EXCLUDE_LIST)"
            echo ""
            sleep 1 # Give the user time to read the output before moving on.
            break
        fi

        # Add to list & validate if the path exists
        if [ -e "$EXCLUDE_PATH" ]; then
            # Append the valid path to the exclusion list
            echo "$EXCLUDE_PATH" >> "$EXCLUDE_LIST"
            echo -e "Added '$EXCLUDE_PATH' to the exclusion list. \n"
            sleep 1 # Give the user time to read the output before moving on.
        else
            echo -e "The path '$EXCLUDE_PATH' does not exist. Please try again. \n"
            sleep 1 # Give the user time to read the output before moving on.
        fi
    done
else
    echo -e "No exclusions will be added. \n"
    sleep 1 # Give the user time to read the output before moving on.
fi

# Loop for weekly backups
read -p "How many weekly backups would you like to keep?: " ANSWER
echo ""
# Call function to check if answer is valid
is_valid_number
# Set the variable after function
WEEKLY_LIMIT=$ANSWER

# Loop for daily backups
read -p "How many daily incremental backups would you like to keep?: " ANSWER
echo ""
# Call function to check if answer is valid
is_valid_number
# Set the variable after function
DAILY_LIMIT=$ANSWER

# Generate the script
echo "########################### Generating Script #############################"

# Save script to user's home directory as a hidden file
OUTPUT_SCRIPT="$BACKUP_DIR/.backup_script.sh"

cat <<EOL > "$OUTPUT_SCRIPT"
#!/bin/bash

# Set up paths and date formats
BACKUP_DIR="$BACKUP_DIR"
FULL_BACKUP_DIR="\$BACKUP_DIR/weekly"
DAILY_BACKUP_DIR="\$BACKUP_DIR/daily"
EXCLUDE_LIST="$EXCLUDE_LIST"
DATE=\$(date +'%m-%d-%Y')
TIME=\$(date +%s)
BACKUP_TARGET="$BACKUP_TARGET"
WEEKLY_REMOVE=$((WEEKLY_LIMIT + 1))
DAILY_REMOVE=$((DAILY_LIMIT + 1))

# Set timestamp file paths
DAILY_TIMESTAMP_FILE="\$DAILY_BACKUP_DIR/.daily_backup_timestamp"
WEEKLY_TIMESTAMP_FILE="\$FULL_BACKUP_DIR/.weekly_backup_timestamp"
SNAPSHOT_FILE="\$FULL_BACKUP_DIR/.snapshot.snar"

# Create necessary directories if they don't exist
mkdir -p "\$FULL_BACKUP_DIR"
mkdir -p "\$DAILY_BACKUP_DIR"

# Check if the weekly backup timestamp exists
if [ -e "\$WEEKLY_TIMESTAMP_FILE" ]; then
    LAST_WEEKLY_RUN_TIME=\$(cat "\$WEEKLY_TIMESTAMP_FILE")
    WEEKLY_TIME_DIFF=\$((TIME - LAST_WEEKLY_RUN_TIME))

    # If it's been less than 7 days since the last weekly backup, skip the full backup
    if [ "\$WEEKLY_TIME_DIFF" -lt \$((7 * 86400)) ]; then
        echo -e "Weekly backup has already been done within the last 7 days. Skipping weekly backup.\\n"
        sleep 1 # Give the user time to read the output before moving on.
    else
        # Do the weekly full backup
        echo -e "Running weekly full backup.\\nDO NOT close the terminal until complete.\\nThis may take a while depending on size of backup.\\n"

        # Remove previous snapshot
        rm "\$SNAPSHOT_FILE"

        # Copy and compress backup to designated folder
        tar -cvpzf "\$FULL_BACKUP_DIR/full_backup_\$DATE.tar.gz" \\
            --exclude-from="\$EXCLUDE_LIST" \\
            --listed-incremental="\$SNAPSHOT_FILE" \\
            --totals \\
            \$BACKUP_TARGET &> "\$FULL_BACKUP_DIR/full_backup_\$DATE.log"

        # Remove older full backups if there are more than the weekly limit
        find "\$FULL_BACKUP_DIR" -name "full_backup_*.tar.gz" -type f | sort -r | tail -n +\$WEEKLY_REMOVE | xargs rm -f
        find "\$FULL_BACKUP_DIR" -name "full_backup_*.log" -type f | sort -r | tail -n +\$WEEKLY_REMOVE | xargs rm -f

        # Update weekly backup timestamp
        echo "\$TIME" > "\$WEEKLY_TIMESTAMP_FILE"
        LAST_WEEKLY_RUN_TIME=\$(cat "\$WEEKLY_TIMESTAMP_FILE")
        WEEKLY_TIME_DIFF=\$((\$TIME - \$LAST_WEEKLY_RUN_TIME))

        # Notify user of completion
        echo -e "Backup Complete! \\n"
        sleep 1 # Give the user time to read the output before moving on.

    fi
else
    # If the weekly backup timestamp file doesn't exist, do the first full backup
    echo -e "Running first initial backup.\\nDO NOT close the terminal until complete. This may take a while depending on size of backup.\\n"

    # Copy and compress backup to designated folder
    tar -cvpzf "\$FULL_BACKUP_DIR/full_backup_\$DATE.tar.gz" \\
        --exclude-from="\$EXCLUDE_LIST" \\
        --listed-incremental="\$SNAPSHOT_FILE" \\
        --totals \\
        \$BACKUP_TARGET &> "\$FULL_BACKUP_DIR/full_backup_\$DATE.log"

    # Update weekly backup timestamp and define WEEKLY_TIME_DIFF for daily backup.
    echo "\$TIME" > "\$WEEKLY_TIMESTAMP_FILE"
    LAST_WEEKLY_RUN_TIME=\$(cat "\$WEEKLY_TIMESTAMP_FILE")
    WEEKLY_TIME_DIFF=\$((\$TIME - \$LAST_WEEKLY_RUN_TIME))

    # Notify user of completion
    echo -e "Backup Complete!\\n"
    sleep 1 # Give the user time to read the output before moving on.
fi

# Now proceed with the daily backup logic using a similar timestamp check
if [ -e "\$DAILY_TIMESTAMP_FILE" ]; then
    LAST_DAILY_RUN_TIME=\$(cat "\$DAILY_TIMESTAMP_FILE")
    DAILY_TIME_DIFF=\$((TIME - LAST_DAILY_RUN_TIME))

    # If it's been less than 24 hours since the last daily backup, skip
    if [ "\$DAILY_TIME_DIFF" -lt 86400 ] || [ "\$WEEKLY_TIME_DIFF" -lt 86400 ]; then
        echo -e "A backup has already been done within the last 24 hours. Skipping daily backup.\\n\\nExiting Script.\\n"
        sleep 1 # Give the user time to read the output before moving on.
    else
        # Perform daily incremental backup (if timestamp check passes)
        echo -e "Running daily incremental backup.\\nDO NOT close the terminal until complete. This may take a while depending on size of backup.\\n"

        # Copy and compress backup to designated folder
        tar -cvpzf "\$DAILY_BACKUP_DIR/incremental_backup_\$DATE.tar.gz" \\
            --listed-incremental="\$SNAPSHOT_FILE" \\
            --exclude-from="\$EXCLUDE_LIST" \\
            --totals \\
            \$BACKUP_TARGET &> "\$DAILY_BACKUP_DIR/incremental_backup_\$DATE.log"

        # Update timestamp
        echo "\$TIME" > "\$DAILY_TIMESTAMP_FILE"
        # Remove older daily backups if there are more than the daily limit
        find "\$DAILY_BACKUP_DIR" -name "incremental_backup_*.tar.gz" -type f | sort -r | tail -n +\$DAILY_REMOVE  | xargs rm -f
        find "\$DAILY_BACKUP_DIR" -name "incremental_backup_*.log" -type f | sort -r | tail -n +\$DAILY_REMOVE | xargs rm -f

        # Notify user of completion
        echo -e "Backup Complete! Exiting Script. \\n"
        sleep 1 # Give the user time to read the output before moving on.
    fi
else
    # If the daily backup timestamp doesnt exist, create one using the weekly backup timestamp
    echo "\$TIME" > "\$DAILY_TIMESTAMP_FILE"
fi
EOL

# Modify the script to make it executable, then run the generated script
chmod +x "$OUTPUT_SCRIPT"
sleep 1 # Give the user time to read the output before moving on.
echo -e "Script created at "$OUTPUT_SCRIPT" with the provided settings.\n"
sleep 1 # Give the user time to read the output before moving on.
$OUTPUT_SCRIPT

# Verify the directory exists
mkdir -p "$HOME/.config/autostart"

# Set location where the desktop file will be created
AUTOSTART="$HOME/.config/autostart/backup_script.sh.desktop"

echo "####################### Generating Autostart Entry #########################"

# Create a desktop entry within the autostart folder to run when user logs in.
cat <<EOL > "$AUTOSTART"
[Desktop Entry]
Type=Application
Exec=$OUTPUT_SCRIPT
Icon=application-x-shellscript
Name=backup.sh
Comment=Runs the backup script created with Blair's Simple Backup
StartupNotify=true
Terminal=false
EOL

# Show user autostart was created
sleep 1 # Give the user time to read the output before moving on.
echo -e "Autostart entry created at $AUTOSTART \n"
sleep 1 # Give the user time to read the output before moving on.

# Ending Script
echo "############################ Backup Complete! ##############################"
echo -e "Please check the log files to ensure everything was properly archived.\n"