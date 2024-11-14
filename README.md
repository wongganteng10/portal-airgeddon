# portal airgeddon 
## download dengan perintah 
```
wget https://github.com/wongganteng10/portal-airgeddon/releases/download/portal-airgeddon/perubahan-airgedon-portal-stabil-v2.zip
```

## setelah di download extrak file nya dengan perintah 
```
unzip perubahan-airgedon-portal-stabil-v2.zip
cd perubahan-airgedon-portal-stabil-v2
```

## jangan lupa kalau mau menjalankan nya rubah sesuai target 
1.  Rubah di dalam file **`index.htm`** bagian ini dengan `SSID` target
     ```
     echo -e '    <b><span>SSID-TARGET</span></b>'
     ```

2. Rubah juga di dalam file **`check.htm`** bagian MAC target yang di serang, di sini saya menggunakan MAC target ini sebagai contoh CE:32:E5:16:CD:33
     ```
     aircrack-ng -a 2 -b CE:32:E5:16:CD:33 -w "/tmp/ag1/www/ag.et_currentpass.txt" "/root/handshake-CE:32:E5:16:CD:33.cap" | grep "KEY FOUND!" > /dev/null
     ```

3. setelah di edit semuanya sesuai target yang di serang 
4. langkah selanjutnya memindahkan ke dalam file www airgedon yang di jalankan, di sini saya kebetulan ada di direktori ini 
     ```
     cd perubahan-airgedon-portal-stabil-v2
     cp * /tmp/ag1/www
     ```

## selesai


