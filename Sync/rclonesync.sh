echo "starting Music Sync"
rclone sync  "/home/roo/runtipi/media/data/music" "Music:/Music" --log-file=rclonesync.log  
echo "finished Music starting Videos"
rclone sync  "/home/roo/runtipi/media/data/Music Videos" "Music:/MusicVideos" --log-file=rclonesync.log 
echo "finished"
