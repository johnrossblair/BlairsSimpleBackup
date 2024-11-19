# Blair's Simple Backup

A small script to automate backups on your local machine.

This Bash script creates an automated backup system that sets up full backups weekly and incremental backups daily, based on the latest full backup. I created this tool because I wanted a tool that would backup folders within my home directory to my secondary ssd. I also wanted the backups to be compressed to save space. After trying several options, I decided to create this script that does everything I need.

The script takes advantage of the ~/.config/autostart/ folder to run automatically upon login. It checks the time to ensure backups only run once every 24 hours (for daily incremental backups) or every 7 days (for full backups).

# Install
                                             
You can either download the file "simple_backup_tool.sh" from the main repo,
or you can clone the repository directly from GitHub:

# Clone the repo:
git clone https://github.com/johnrossblair/BlairsSimpleBackup.git

# Navigate to the cloned directory:
cd BlairsSimpleBackup/

# Make the file executable
chmod +x simple_backup_tool.sh

# Run the script:
./simple_backup_tool.sh

From there, the script will run automatically at login (as long as parameters are met).

# Tips

If you would like to run the backup manually, you can find the script located within the backup folder named ".backup_script.sh".

If you would like to remove the autorun feature, you can remove the file "~/.config/autostart/backup_script.sh.desktop"

If you want to add/remove backup exclusions, you can either run the main script again (which will verify if the directories exist or not),
or edit the file ".exclude_list.txt". Be sure to list exlusions line by line, and be sure to verify the spelling is correct.

   Good Example: /home/*yourusername*/.cache
                 ~/.local/share/Trash
                 ...
                 
   Bad Example: /home/*yourusername*/.cacchee , /hom/*yourusername*/.local/share/Trash


I highly reccomend excluding the following folders to save space:
/home/*yourusername*/.cache                # Temporary Folder
/home/*yourusername*/.local/share/Trash    # Trash

If you play games on Steam, depending on what OS you are using, I would exclude the following:
/home/*yourusername*/.steam OR /home/*yourusername*/.local/share/Steam
