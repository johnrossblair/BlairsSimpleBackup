##############################################################
#   ____    _                   _____   _____    _    _____  #
#  |  _ \  | |          /\     |_   _| |  __ \  ( )  / ____| #
#  | |_) | | |         /  \      | |   | |__) | |/  | (___   #
#  |  _ <  | |        / /\ \     | |   |  _  /       \___ \  #
#  | |_) | | |____   / ____ \   _| |_  | | \ \       ____) | #
#  |____/_ |______| /_/  __\_\_|_____| |_|  \_\ ____|_____/  #
#   / ____| |_   _| |  \/  | |  __ \  | |      |  ____|      #
#  | (___     | |   | \  / | | |__) | | |      | |__         #
#   \___ \    | |   | |\/| | |  ___/  | |      |  __|        #
#   ____) |  _| |_  | |  | | | |      | |____  | |____       #
#  |_____/  |_____| |_| _|_|_|_|_  __ |______| |______|      #
#  |  _ \      /\      / ____| | |/ / | |  | | |  __ \       #
#  | |_) |    /  \    | |      | ' /  | |  | | | |__) |      #
#  |  _ <    / /\ \   | |      |  <   | |  | | |  ___/       #
#  | |_) |  / ____ \  | |____  | . \  | |__| | | |           #
#  |____/  /_/    \_\  \_____| |_|\_\  \____/  |_|           #
#                                                            #
##############################################################

Where would you like to save your backups? (ex: /path/to/backups): /mnt/storage/

What folder would you like to backup? (ex: /home/yourname/Pictures): ~

Are there any folders or files you would like to exclude within the folder? (y/n): y

Enter a path to exclude from the backup (or type 'done' to finish): ~/.cache/

Added '/home/john/.cache' to the exclusion list.

Enter a path to exclude from the backup (or type 'done' to finish): ~/Games/

Added '/home/john/Games' to the exclusion list.

Enter a path to exclude from the backup (or type 'done' to finish): ~/Calibre\ Library/

Added '/home/john/Calibre Library' to the exclusion list.

Enter a path to exclude from the backup (or type 'done' to finish): ~/.local/share/Steam/

Added '/home/john/.local/share/Steam' to the exclusion list.

Enter a path to exclude from the backup (or type 'done' to finish): ~/.local/share/Trash/

Added '/home/john/.local/share/Trash' to the exclusion list.

Enter a path to exclude from the backup (or type 'done' to finish): done

Exclusion list complete. The following paths will not be backed up:
/mnt/storage/backups
/home/john/.cache
/home/john/Games
/home/john/Calibre Library
/home/john/.local/share/Steam
/home/john/.local/share/Trash

How many weekly backups would you like to keep?: 4

4 weekly backups will be stored at one time.

How many daily incremental backups would you like to keep?: 7

7 daily backups will be stored at one time.

########################### Generating Script #############################

Script created at /mnt/storage/backups/.backup_script.sh with the provided settings.

Weekly backup has already been done within the last 7 days. Skipping weekly backup.

Running daily incremental backup.
DO NOT close the terminal until complete. This may take a while depending on size of backup.

Backup Complete! Exiting Script.

####################### Generating Autostart Entry #########################

Autostart entry created at /home/john/.config/autostart/backup_script.sh.desktop

############################ Backup Complete! ##############################

Please check the log files to ensure everything was properly archived.
