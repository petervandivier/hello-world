PS D:\git\hello> '<a>foo</a>' | Set-Content bar.xml
PS D:\git\hello> [xml](gc .\bar.xml)

a
-
foo


PS D:\git\hello> git add .
PS D:\git\hello> git commit -m "@vexx32 sez 'No Out-File for you!' #cmdletNazi"
[master b421ee1] @vexx32 sez 'No Out-File for you!' #cmdletNazi
 1 file changed, 1 insertion(+)
 create mode 100644 bar.xml
PS D:\git\hello> git push
Enumerating objects: 4, done.
Counting objects: 100% (4/4), done.
Delta compression using up to 8 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 310 bytes | 310.00 KiB/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To pv.github.com:petervandivier/hello-world.git
   58dd486..b421ee1  master -> master
PS D:\git\hello> $uri = "https://raw.githubusercontent.com/petervandivier/hello-world/master/bar.xml"
PS D:\git\hello> $test = (Invoke-WebRequest $uri -UseBasicParsing).content
PS D:\git\hello> $test
<a>foo</a>

PS D:\git\hello> [xml]$test

a
-
foo


PS D:\git\hello>