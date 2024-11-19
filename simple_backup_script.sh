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

# Choose backup directory
read -ep "Where would you like to save your backups? (ex: /path/to/backups): " BACKUP_DIR
echo ""

    # Clean up path by removing "/" at end if submitted, and also generating full path if user uses ~ shortcut for home
    if [[ "${BACKUP_DIR:0:1}" == "~" ]]; then
        BACKUP_DIR="/home/$USER${BACKUP_DIR:1}"
    fi

    if [[ "${BACKUP_DIR: -1}" == "/" ]]; then
        BACKUP_DIR="${BACKUP_DIR%/}"
    fi

    # Loop until the entered path exists
    while [ ! -e "$BACKUP_DIR" ]; do
        echo -e "The path '$BACKUP_DIR' does not exist. Please try again. \n"
        read -ep "Where would you like to save your backups? (ex: /path/to/backups): " BACKUP_DIR
        echo ""
    done

BACKUP_DIR="${BACKUP_DIR}/backups"

mkdir -p $BACKUP_DIR

# Choose directory to back up
read -ep "What folder would you like to backup? (ex: /home/yourname/Pictures): " BACKUP_TARGET
echo ""

    # Clean up path by removing "/" at end if submitted, and also generating full path if user uses ~ shortcut for home
    if [[ "${BACKUP_TARGET:0:1}" == "~" ]]; then
        BACKUP_TARGET="/home/$USER${BACKUP_TARGET:1}"
    fi

    if [[ "${BACKUP_TARGET: -1}" == "/" ]]; then
        BACKUP_TARGET="${BACKUP_TARGET%/}"
    fi

    # Loop until the entered path exists
    while [ ! -e "$BACKUP_TARGET" ]; do
        echo -e "The path '$BACKUP_TARGET' does not exist. Please try again. \n"
        read -ep "What folder would you like to backup? (ex: /home/yourname/Pictures): " BACKUP_TARGET
        echo ""
    done

# Path to exclusion list
EXCLUDE_LIST="$BACKUP_DIR/.exclude_list.txt"

# Ensure list exsists
touch "$EXCLUDE_LIST"

# add backup directory to avoid backing up a backup - failsafe
echo "$BACKUP_DIR" > "$EXCLUDE_LIST"

# verify that answer is valid before proceeding
while true; do
    read -p "Would you like to exclude all hidden files and folders within the directory being backed up? (y/n): " EXCLUDE_HIDDEN_ANSWER
    echo ""
    if [ "$EXCLUDE_HIDDEN_ANSWER" == "y" ] || [ "$EXCLUDE_HIDDEN_ANSWER" == "n" ]; then
        break
    else
        echo -e "Invalid reponse. Please type 'y' or 'n'.\n"
    fi
done

# Give option to exclude all hidden files and folders
if [ "$EXCLUDE_HIDDEN_ANSWER" == "y" ]; then
    echo "$BACKUP_TARGET/.*" >> $EXCLUDE_LIST
    echo -e "All hidden files and folders within directory will be ignored.\n"
else
    echo -e "The backup will include all hidden files and folders.\n"
fi

# verify that answer is valid before proceeding
while true; do
    read -p "Are there any other folders or files you would like to exclude within the folder? (y/n): " EXCLUDE_ANSWER
    echo ""
    if [ "$EXCLUDE_ANSWER" == "y" ] || [ "$EXCLUDE_ANSWER" == "n" ]; then
        break
    else
        echo -e "Invalid reponse. Please type 'y' or 'n'.\n"
    fi
done

# Check for file/folder exclusion within the directory to be archived
if [ "$EXCLUDE_ANSWER" == "y" ]; then
    # If yes, enter the loop to collect exclusions
    while true; do
        # Ask for a path to exclude
        read -ep "Enter a path to exclude from the backup (or type 'done' to finish): " EXCLUDE_PATH
        echo ""

        # Clean up path by removing "/" at end if submitted, and also generating full path if user uses ~ shortcut for home
        if [[ "${EXCLUDE_PATH:0:1}" == "~" ]]; then
            EXCLUDE_PATH="/home/$USER${EXCLUDE_PATH:1}"
        fi

        if [[ "${EXCLUDE_PATH: -1}" == "/" ]]; then
            EXCLUDE_PATH="${EXCLUDE_PATH%/}"
        fi

        # Check if the user typed 'done' to exit the loop
        if [ "$EXCLUDE_PATH" == "done" ]; then
            echo "Exclusion list complete. The following paths will not be backed up:"
            echo "$(cat $EXCLUDE_LIST)"
            echo ""
            break
        fi

        # Validate if the path exists
        if [ -e "$EXCLUDE_PATH" ]; then
            # Append the valid path to the exclusion list
            echo "$EXCLUDE_PATH" >> "$EXCLUDE_LIST"
            echo -e "Added '$EXCLUDE_PATH' to the exclusion list. \n"
        else
            echo -e "The path '$EXCLUDE_PATH' does not exist. Please try again. \n"
        fi
    done
else
    echo -e "No exclusions will be added. \n"
fi

# Loop for weekly backups
while true; do
    #Ask how many weekly backups to store
    read -p "How many weekly backups would you like to keep?: " WEEKLY_LIMIT
    echo ""
    if [[ "$WEEKLY_LIMIT" =~ ^[0-9]+$ ]] && [ "$WEEKLY_LIMIT" -gt 0 ]; then
        echo -e "$WEEKLY_LIMIT weekly backups will be stored at one time. \n"
        break
    else
        echo -e "'$WEEKLY_LIMIT' is not a valid answer. Please try again. \n"
    fi
done

# Loop for daily backups
while true; do
    #Ask how many daily backups to store
    read -p "How many daily incremental backups would you like to keep?: " DAILY_LIMIT
    echo ""
    if [[ "$DAILY_LIMIT" =~ ^[0-9]+$ ]] && [ "$DAILY_LIMIT" -gt 0 ]; then
        echo -e "$DAILY_LIMIT daily backups will be stored at one time. \n"
        break
    else
        echo -e "'$DAILY_LIMIT' is not a valid answer. Please try again. \n"
    fi
done

#Generate the script
echo -e "########################### Generating Script ############################# \n"

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
fi

# Now proceed with the daily backup logic using a similar timestamp check
if [ -e "\$DAILY_TIMESTAMP_FILE" ]; then
    LAST_DAILY_RUN_TIME=\$(cat "\$DAILY_TIMESTAMP_FILE")
    DAILY_TIME_DIFF=\$((TIME - LAST_DAILY_RUN_TIME))

    # If it's been less than 24 hours since the last daily backup, skip
    if [ "\$DAILY_TIME_DIFF" -lt 86400 ] || [ "\$WEEKLY_TIME_DIFF" -lt 86400 ]; then
        echo -e "A backup has already been done within the last 24 hours. Skipping daily backup.\\n\\nExiting Script.\\n"
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
    fi
else
    # If the daily backup timestamp doesnt exist, create one using the weekly backup timestamp
    echo "\$TIME" > "\$DAILY_TIMESTAMP_FILE"
fi
EOL

# Make generated script executable
chmod +x "$OUTPUT_SCRIPT"

echo -e "Script created at "$OUTPUT_SCRIPT" with the provided settings.\n"

# Run the generated script
$OUTPUT_SCRIPT

# Verify the directory exists
mkdir -p "$HOME/.config/autostart"

# Set location of desktop file to be created
AUTOSTART="$HOME/.config/autostart/backup_script.sh.desktop"

echo -e "####################### Generating Autostart Entry ######################### \n"

# create a desktop entry within the autostart folder to run when user logs in.
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
echo -e "Autostart entry created at $AUTOSTART \n"

#Ending Script
echo -e "############################ Backup Complete! ##############################\n"
echo -e "Please check the log files to ensure everything was properly archived.\n"
