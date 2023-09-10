@echo off
rem https://stackoverflow.com/questions/13314433/batch-file-to-copy-directories-recursively
rem /e Copies directories and subdirectories, including empty ones.
rem /k Copies attributes. Normal Xcopy will reset read-only attributes.
rem /h Copies hidden and system files also.
rem /i If destination does not exist and copying more than one file, assume destination is a directory.
rem /y overwrite without prompt
xcopy /e /k /h /i /y src dst