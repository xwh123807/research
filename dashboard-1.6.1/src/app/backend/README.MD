构建环境：
1、安装go，brew install go
2、创建源代码目录：~/go/src/github.com/kubernetes/dashboard
3、将项目代码链接到gopath源代码目录dashboard下
ln -s /xwh.work/git/research/dashboard-1.6.1 dashboard
4、下载依赖代码库
go get -v
5、ide打开～/go/src/github.com/kubernetes/dashboard