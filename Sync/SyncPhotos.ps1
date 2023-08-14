Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
# sync photos from pc to plex media server

$CMD = "C:\Program Files\FreeFileSync\FreeFileSync.exe"

$arg1 = "D:\Documents\PersonalDocuments\Batch Jobs\BatchRun.ffs_batch"

& $CMD $arg1
