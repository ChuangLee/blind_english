package spider

import (
	"os"
	"strings"
	s "strings"

	"../../utils"
	"github.com/henrylee2cn/pholcus/app/downloader/request"
	"github.com/henrylee2cn/pholcus/app/spider"
	"github.com/henrylee2cn/pholcus/common/goquery"
) // 基础包

//必需
//DOM解析

//必需
//信息输出

func init() {
	_NprNewsAllThings.Register()
	_NprNewsMorningEdition.Register()
}

var _NprNewsAllThings = &spider.Spider{
	Name:         "NPR_AllThings",
	Description:  "NPR News:All Things Considered",
	EnableCookie: false,
	RuleTree: &spider.RuleTree{
		Root: func(ctx *spider.Context) {
			ctx.AddQueue(&request.Request{
				Url:        "https://www.npr.org/programs/all-things-considered/",
				Reloadable: true,
				Rule:       "NewsList"})
		},

		Trunk: trunk,
	},
}
var _NprNewsMorningEdition = &spider.Spider{
	Name:         "NPR_Morning",
	Description:  "NPR News:Morning Edition",
	EnableCookie: false,
	RuleTree: &spider.RuleTree{
		Root: func(ctx *spider.Context) {
			ctx.AddQueue(&request.Request{
				Url:        "https://www.npr.org/programs/morning-edition/",
				Reloadable: true,
				Rule:       "NewsList"})
		},
		Trunk: trunk,
	},
}

var crawledFilesPath = "pholcus_pkg/file_out/"
var trunk = map[string]*spider.Rule{

	"NewsList": {
		ParseFunc: func(ctx *spider.Context) {
			query := ctx.GetDom()
			query.Find(".rundown-segment__title a").Each(func(i int, s *goquery.Selection) {

				if url, ok := s.Attr("href"); ok {
					//search the storyID from date  exp:**/2018/12/16/34123545/***
					lastSlash := strings.LastIndex(url, "/")
					secondLastSlash := strings.LastIndex(url[:lastSlash], "/")
					storyID := url[secondLastSlash+1 : lastSlash]
					storyURL := "https://www.npr.org/templates/transcript/transcript.php?storyId=" + storyID
					ctx.AddQueue(&request.Request{Url: storyURL, Rule: "NewsDetail"})
				}
			})
		},
	},
	"NewsDetail": {
		ItemFields: []string{
			"Placeholder",
			"title",
			"mp3Name",
			"duration",
		},
		ParseFunc: func(ctx *spider.Context) {
			query := ctx.GetDom()
			//download mp3
			mp3Url, ok := query.Find(".audio-tool-download a").First().Attr("href")
			if ok {
				transcript := query.Find(".storytext").Text()
				copyrightIndex := strings.LastIndex(transcript, "Copyright ©")
				if copyrightIndex > 10 {
					transcript = transcript[:copyrightIndex]
				}
				transcript = s.Trim(transcript, " \n")

				title := query.Find(".storytitle h1").Text()
				duration := query.Find(".audio-module-listen-duration").Text()
				duration = s.Trim(duration, "· \n")
				duration = s.Split(duration, "\n")[0]

				if strings.HasPrefix(title, "<") {
					title = strings.Trim(title[1:], " ")
				}
				slashIndex := s.LastIndex(mp3Url, "/")
				questionMarkIndex := s.LastIndex(mp3Url, "?")
				mp3Name := mp3Url[slashIndex+1 : questionMarkIndex]

				fileDir := crawledFilesPath + ctx.GetName() + "/"
				os.MkdirAll(fileDir, os.ModePerm)
				//每句每行处理 文稿，为了对齐音频
				utils.SplitTranscriptAndSave(transcript, mp3Name, fileDir)

				ctx.Output(map[int]interface{}{
					0: " ",
					1: title,
					2: mp3Name,
					3: duration,
				})
				ctx.AddQueue(&request.Request{
					Url:          mp3Url,
					Rule:         "Mp3Downloader",
					ConnTimeout:  -1,
					DownloaderID: 0,
				})
			}

		},
	},
	"Mp3Downloader": {
		ParseFunc: func(ctx *spider.Context) {
			ctx.FileOutput()
		},
	},
}
