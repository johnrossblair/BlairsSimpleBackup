#!/bin/bash


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
read -p "Where would you like to save your backups? (ex: /path/to/backups): " BACKUP_DIR
echo ""

    # Loop until the entered path exists
    while [ ! -e "$BACKUP_DIR" ]; do
        echo -e "The path '$BACKUP_DIR' does not exist. Please try again. \n"
        read -p "Where would you like to save your backups? (ex: /path/to/backups): " BACKUP_DIR
        echo ""
    done

# Choose directory to back up
read -p "What folder would you like to backup? (ex: /home/yourname/Pictures): " BACKUP_TARGET
echo ""

    # Loop until the entered path exists
    while [ ! -e "$BACKUP_TARGET" ]; do
        echo -e "The path '$BACKUP_TARGET' does not exist. Please try again. \n"
        read -p "What folder would you like to backup? (ex: /home/yourname/Pictures): " BACKUP_TARGET
        echo ""
    done

# Check for file/folder exclusion within the directory to be archived
read -p "Are there any folders or files you would like to exclude within the folder? (y/n): " EXCLUDE_ANSWER

# Path to exclusion list
EXCLUDE_LIST="$BACKUP_DIR/.exclude_list.txt"

# Ensure list exsists
touch "$EXCLUDE_LIST"

if [ "$EXCLUDE_ANSWER" == "y" ]; then
    # If yes, enter the loop to collect exclusions
    while true; do
        # Ask for a path to exclude
        read -p "Enter a path to exclude from the backup (or type 'done' to finish): " EXCLUDE_PATH

        # Check if the user typed 'done' to exit the loop
        if [ "$EXCLUDE_PATH" == "done" ]; then
            echo -e "Exclusion list complete. \n"
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
    read -p "How many weekly backups would you like to keep? (Must be 1 or more): " WEEKLY_LIMIT
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
    read -p "How many daily incremental backups would you like to keep? (Must be 1 or more): " DAILY_LIMIT
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
OUTPUT_SCRIPT="$HOME/.backup_script.sh"

cat <<EOL > "$OUTPUT_SCRIPT"
#!/bin/sh

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
        echo "Weekly backup has already been done within the last 7 days. Skipping weekly backup."
        echo ""
    else
        # Do the weekly full backup
        echo "Running weekly full backup."
        echo "DO NOT close the terminal until complete. This may take a while depending on size of backup."
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
    fi
else
    # If the weekly backup timestamp file doesn't exist, do the first full backup
    echo "First weekly backup. Running full backup."
    echo "DO NOT close the terminal until complete. This may take a while depending on size of backup."
    echo ""
    tar -cvpzf "\$FULL_BACKUP_DIR/full_backup_\$DATE.tar.gz" \\
        --exclude-from="\$EXCLUDE_LIST" \\
        --listed-incremental="\$SNAPSHOT_FILE" \\
        --totals \\
        \$BACKUP_TARGET &> "\$FULL_BACKUP_DIR/full_backup_\$DATE.log"

    # Update weekly backup timestamp
    echo "\$TIME" > "\$WEEKLY_TIMESTAMP_FILE"
fi

# Now proceed with the daily backup logic using a similar timestamp check
if [ -e "\$DAILY_TIMESTAMP_FILE" ]; then
    LAST_DAILY_RUN_TIME=\$(cat "\$DAILY_TIMESTAMP_FILE")
    DAILY_TIME_DIFF=\$((TIME - LAST_DAILY_RUN_TIME))

    # If it's been less than 24 hours since the last daily backup, skip
    if [ "\$DAILY_TIME_DIFF" -lt 86400 ]; then
        echo -e "Daily backup has already been done within the last 24 hours. Skipping daily backup."
        echo ""
        exit 0
    fi
fi

    # Perform daily incremental backup (if timestamp check passes)
    echo "Running daily incremental backup."
    echo "DO NOT close the terminal until complete. This may take a while depending on size of backup."
    echo ""
    tar -cvpzf "\$DAILY_BACKUP_DIR/incremental_backup_\$DATE.tar.gz" \\
        --listed-incremental="\$SNAPSHOT_FILE" \\
        --exclude-from="\$EXCLUDE_LIST" \\
        --totals \\
        \$BACKUP_TARGET &> "\$DAILY_BACKUP_DIR/incremental_backup_\$DATE.log"

    # Remove older daily backups if there are more than the daily limit
    find "\$DAILY_BACKUP_DIR" -name "incremental_backup_*.tar.gz" -type f | sort -r | tail -n +\$DAILY_REMOVE  | xargs rm -f
    find "\$DAILY_BACKUP_DIR" -name "incremental_backup_*.log" -type f | sort -r | tail -n +\$DAILY_REMOVE | xargs rm -f

# Update the daily backup timestamp
echo "\$TIME" > "\$DAILY_TIMESTAMP_FILE"
EOL

# Make generated script executable
chmod +x "$OUTPUT_SCRIPT"

echo "Script created at "$OUTPUT_SCRIPT" with the provided settings."
echo ""

# Run the generated script
$OUTPUT_SCRIPT

# Verify the directory exists
mkdir -p "$HOME/.config/autostart"

# Set location of desktop file to be created
AUTOSTART="$HOME/.config/autostart/backup_script.sh.desktop"

# create a desktop entry within the autostart folder to run when user logs in.
cat <<EOL > "$AUTOSTART"
[Desktop Entry]
Type=Application
Exec=$HOME/.backup_script.sh
Icon=application-x-shellscript
Name=backup.sh
Comment=Runs the backup script created with Blair's Simple Backup
StartupNotify=true
Terminal=false
EOL

echo -e "Autostart entry created at $AUTOSTART \n"

#Ending Script
echo -e "Backup completed! Please check the log files to ensure everything was properly archived. \n"
