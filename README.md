# Domestika video downloader
Script to save videos from Domestika.

# Requisites
Ruby version 3.2.3 (and others, not checked)

# Use
Execute using:

$ ruby script.rb [options]

# Options
```
    --file file_name             Specifies the file to process by its name.
    --dir directory_path         Specifies the directory's path that contains the files to process.
    -h, --help                   Prints a summary of the options.
```

# Expected CSV format
```
1,"Materiales necesarios para esmaltar",https://cdn-videos.domestika.org/videos/000/016/738/78f075aace9b780f466a0aa71b9c902f/master.m3u8?1676387965
2,"Esmaltamos con aguadas",https://cdn-videos.domestika.org/videos/000/016/739/a9b5575353f102c5f60d982c7b4d9ca6/master.m3u8?1676387972
3,"Decoración mediante dosificadores",https://cdn-videos.domestika.org/videos/000/016/740/beaabc5af7720ae22d714f37fcbc427d/master.m3u8?1676387972
```
