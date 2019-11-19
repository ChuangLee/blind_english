package spider

import (
	"net/http"
	"os"
	"strings"
	s "strings"

	"../../utils"
	"github.com/henrylee2cn/pholcus/app/downloader/request"
	"github.com/henrylee2cn/pholcus/common/goquery" // 基础包

	//必需
	//DOM解析
	"github.com/henrylee2cn/pholcus/app/spider"
	"github.com/henrylee2cn/pholcus/logs"
)

//必需
//信息输出

func init() {
	_VOANewsAllThings.Register()
}

var _crawledFilesPath = "pholcus_pkg/file_out/"

const (
	_VOALearningURL     = "https://learningenglish.voanews.com/z/952/"
	_VOALearningBaseURL = "https://learningenglish.voanews.com"
	_agent              = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36"
)

var header = http.Header{"User-Agent": {_agent}}

var _VOANewsAllThings = &spider.Spider{
	Name:         "VOA_LearningEnglish",
	Description:  "VOA News: Learning English",
	EnableCookie: false,
	RuleTree: &spider.RuleTree{
		Root: func(ctx *spider.Context) {
			ctx.AddQueue(&request.Request{
				Url:          _VOALearningURL,
				Rule:         "NewsList",
				Header:       header,
				Reloadable:   true,
				DownloaderID: 0})
		},

		Trunk: _trunkVoa,
	},
}

var _trunkVoa = map[string]*spider.Rule{
	"NewsList": {
		ParseFunc: func(ctx *spider.Context) {
			query := ctx.GetDom()
			query.Find(".media-block.with-date").Each(func(i int, s *goquery.Selection) {
				if url, ok := s.Find(".content a").Attr("href"); ok {
					storyURL := _VOALearningBaseURL + url
					ctx.AddQueue(&request.Request{Url: storyURL, Rule: "NewsDetail", Header: header})
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
			mp3Url, ok := query.Find(".simple-menu .subitems .subitem a").Last().Attr("href")
			if ok {
				isContent := true
				lastText := ""
				var strBuilder strings.Builder
				query.Find("#article-content .wsw>p").Each(func(i int, s *goquery.Selection) {
					text := strings.Trim(s.Text(), " \n")
					innerHTML, err := s.Html()
					if err != nil {
						logs.Log.Error(err.Error())
						return
					}
					innerHTML = strings.Trim(innerHTML, " \n")

					if (len(text) >= 7 && strings.EqualFold("The End", text[0:7])) || strings.Contains(text, "__________________") {
						isContent = false
					} else if strings.HasPrefix(lastText, "And I’m") || strings.HasPrefix(lastText, "I’m") {
						if strings.HasPrefix(innerHTML, "<em>") || text == "" {
							//斜体一般是结尾作者语 通常有行空的<p></p>
							isContent = false
						}
					}
					if isContent {
						strBuilder.WriteString("\n" + text)
						lastText = text
					}
				})
				transcript := strBuilder.String()
				transcript = s.Trim(transcript, " \n")

				title := s.Trim(query.Find("#content .col-title .pg-title").Text(), " \n")
				duration := query.Find(".body-container .c-mmp__cpanel-progress-controls-duration.js-duration").Text()
				duration = s.Trim(duration, "· \n")

				if strings.HasPrefix(title, "<") {
					title = strings.Trim(title[1:], " ")
				}
				slashIndex := s.LastIndex(mp3Url, "/")
				questionMarkIndex := s.LastIndex(mp3Url, "?")
				mp3Name := mp3Url[slashIndex+1 : questionMarkIndex]

				fileDir := _crawledFilesPath + ctx.GetName() + "/"
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
