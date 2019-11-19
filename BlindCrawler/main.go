package main

import (
	"fmt"
	"os"

	// _ "github.com/henrylee2cn/pholcus_lib/nprnews"
	// _ "github.com/henrylee2cn/pholcus_lib/voanews"
	_ "./pholcus_lib/nprnews"
	_ "./pholcus_lib/voanews"

	// 自己的爬虫规则库
	"github.com/henrylee2cn/pholcus/exec"
	// _ "lichuang.pro/blind/BlindCrawler/pholcus_lib/nprnews" // 自己的爬虫规则库
	// _ "github.com/henrylee2cn/pholcus_lib" // 此为公开维护的spider规则库
)

func main() {
	// 设置运行时默认操作界面，并开始运行
	// 运行软件前，可设置 -a_ui 参数为"web"、"gui"或"cmd"，指定本次运行的操作界面
	// 其中"gui"仅支持Windows系统
	// ./BlindCrawler -_ui=cmd -c_spider="0,1"   -a_mode=0
	fmt.Println(os.Args)
	exec.DefaultRun("web")
}
