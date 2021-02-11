REM takes the video files listed in list.txt and  concatenates them using ffmpeg
REM ffmpeg must be installed first
REM see https://ffmpeg.org/


(echo file '20210202_122103.MP4' & echo file '20210202_131323.MP4' & echo file '20210202_140540.MP4')>list.txt
"C:\Program Files\ffmpeg\bin\ffmpeg.exe" -safe 0 -f concat -i list.txt -c copy RELI2308W08.mp4
pause
