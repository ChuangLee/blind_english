package media

import (
	"encoding/json"
	"errors"
	"io/ioutil"

	"../utils"
	"github.com/gin-gonic/gin"
	"github.com/jszwec/csvutil"

	// "net/url"
	"os"
	"strconv"
	"strings"
	// "time"
)

type MediaHandler struct {
	DataPath  string
	Newsmedia []MediaConfig
}

//transcript,title,mp3Name,当前链接,上级链接,下载时间
//transcript目前获取不到，疑似csvutil的bug，暂时不用
type NewsItem struct {
	Url          string
	Transcript   string `csv:"transcript"`
	Title        string `csv:"title"`
	Mp3Name      string `csv:"mp3Name"`
	Duration     string `csv:"duration"`
	CurrentHref  string `csv:"当前链接"`
	ParentHref   string `csv:"上级链接"`
	DownloadTime string `csv:"下载时间"`
}

type NewsResponse struct {
	News []NewsItem
}

type MediaConfig struct {
	Id          int
	Name        string
	CrawledName string
	RefreshTime string
}

func (m *MediaHandler) GetMediaList(c *gin.Context, newsConfigPath string) {
	c.Header("Content-Type", "application/json")
	c.File(newsConfigPath)
}

func (m *MediaHandler) _FindMediaConfig(mediaID int) MediaConfig {
	for _, media := range m.Newsmedia {
		if mediaID == media.Id {
			return media
		}
	}
	return MediaConfig{}
}

func (m *MediaHandler) GetLatestNews(c *gin.Context, mediaID int) {
	if !utils.Exists(m.DataPath) {
		c.Error(errors.New("datapath not exists :" + m.DataPath))
		return
	}
	mediaConfig := m._FindMediaConfig(mediaID)
	if mediaConfig == (MediaConfig{}) {
		c.Error(errors.New("mediaID is wrong :" + strconv.Itoa(mediaID)))
		return
	}
	mediaDir := m.DataPath + "/" + mediaConfig.CrawledName
	dateDirs, err := ioutil.ReadDir(mediaDir)
	if err != nil {
		c.Error(err)
		return
	}
	if len(dateDirs) <= 0 {
		c.Error(errors.New("there is no news in " + mediaConfig.Name))
		return
	}

	var newsItem []NewsItem
	for i := len(dateDirs) - 1; i >= 0; i-- {
		dateDir := dateDirs[i].Name()
		latestDir := mediaDir + "/" + dateDir
		files, err := ioutil.ReadDir(latestDir)
		if err != nil || len(files) <= 0 {
			c.Error(err)
			continue
		}
		for _, file := range files {
			if strings.HasSuffix(file.Name(), ".csv") {
				news, err := _NewsFromCsv(latestDir+"/"+file.Name(), mediaConfig.CrawledName+"/"+dateDir+"/")
				if err == nil {
					newsItem = append(newsItem, news...)
				}
			}
		}
		if len(newsItem) >= 10 {
			break
		}
	}
	if len(newsItem) <= 0 {
		c.Error(errors.New("error:Can't The Find Latest News"))
		return
	}
	newsJosn, err := json.Marshal(NewsResponse{News: newsItem})
	if err != nil {
		c.Error(err)
		return
	}
	c.Header("Content-Type", "application/json")
	c.String(0, string(newsJosn))
}

func _NewsFromCsv(filename string, path string) ([]NewsItem, error) {
	var newsItem []NewsItem
	csvFile, err := os.Open(filename)
	if err != nil {
		return newsItem, errors.New("error:read latest news:" + filename)
	}
	defer csvFile.Close()
	csvBytes, _ := ioutil.ReadAll(csvFile)
	if err = csvutil.Unmarshal(csvBytes, &newsItem); err != nil {
		return newsItem, errors.New("error:csvutil.Unmarshal:" + err.Error())
	}
	if len(newsItem) == 0 {
		return newsItem, errors.New("error:news is null!")
	}
	for index := 0; index < len(newsItem); index++ {
		newsItem[index].Url = path
	}
	return newsItem, nil
}

func _NewsResponseFromCsv(filename string, path string) (string, error) {
	csvFile, err := os.Open(filename)
	if err != nil {
		return "", errors.New("error:read latest news:" + filename)
	}
	defer csvFile.Close()
	csvBytes, _ := ioutil.ReadAll(csvFile)
	var newsItem []NewsItem
	if err = csvutil.Unmarshal(csvBytes, &newsItem); err != nil {
		return "", errors.New("error:csvutil.Unmarshal:" + err.Error())
	}
	if len(newsItem) == 0 {
		return "", errors.New("error:news is null!")
	}
	for index := 0; index < len(newsItem); index++ {
		newsItem[index].Url = path
	}
	newsJosn, err := json.Marshal(NewsResponse{News: newsItem})
	if err != nil {
		return "", errors.New("error:json.Marshal:" + err.Error())
	}
	return string(newsJosn), nil
}
