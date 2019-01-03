PS D:\git\hello> '<a>foo</a>' | out-file foo.xml
PS D:\git\hello> [xml](gc .\foo.xml)

a
-
foo


PS D:\git\hello> git add .
PS D:\git\hello> git commit -am "i can haz xml parsing?"
[master 58dd486] i can haz xml parsing?
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 foo.xml
PS D:\git\hello> git push
Enumerating objects: 4, done.
Counting objects: 100% (4/4), done.
Delta compression using up to 8 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 303 bytes | 303.00 KiB/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To pv.github.com:petervandivier/hello-world.git
   f24b52c..58dd486  master -> master
PS D:\git\hello> $uri = "https://raw.githubusercontent.com/petervandivier/hello-world/master/foo.xml"
PS D:\git\hello> $test = (Invoke-WebRequest $uri -UseBasicParsing).content
PS D:\git\hello> $test
 �< a > f o o < / a >

PS D:\git\hello> [xml]$test
Cannot convert value "��< a > f o o < / a >
 " to type "System.Xml.XmlDocument". Error: "The specified node cannot be inserted as the valid child of this node,
because the specified node is the wrong type."
At line:1 char:1
+ [xml]$test
+ ~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [], RuntimeException
    + FullyQualifiedErrorId : InvalidCastToXmlDocument

PS D:\git\hello>