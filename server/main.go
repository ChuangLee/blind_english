package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"

	"./media"
	"./utils"
	"github.com/gin-gonic/gin"

	jwtmiddleware "github.com/auth0/go-jwt-middleware"
	// "github.com/gin-gonic/contrib/static"
	// jwt "github.com/dgrijalva/jwt-go"
)

var jwtMiddleWare *jwtmiddleware.JWTMiddleware

var assetsPath *string

type Config struct {
	DataPath  string
	Newsmedia []media.MediaConfig
}

var config Config

var mediaHandler media.MediaHandler

func main() {
	fmt.Println(os.Args)
	assetsPath = flag.String("assets_path", "./", " the path include config.json")
	flag.Parse()
	err := LoadConfig(*assetsPath + "/config.json")
	if err != nil || config.DataPath == "" {
		fmt.Println(err)
		return
	}

	router := gin.Default()
	api := router.Group("/api")
	{
		api.GET("/", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{
				"message": "go away！",
			})
		})
		api.Static("/images/", *assetsPath+"/assets/images/")
		api.Static("/audios/", config.DataPath)

		api.GET("/medialist", AuthMiddleware(), GetMediaList)
		api.POST("/medialist", AuthMiddleware(), GetMediaList)
		api.GET("/news/:mediaID", AuthMiddleware(), GetLatestNews)
		api.POST("/news/:mediaID", AuthMiddleware(), GetLatestNews)
	}
	router.Run(":8000")
}

func GetMediaList(c *gin.Context) {
	newsConfigPath := *assetsPath + "/newsmedia.json"
	mediaHandler.GetMediaList(c, newsConfigPath)
}

func GetLatestNews(c *gin.Context) {
	if mediaID, err := strconv.Atoi(c.Param("mediaID")); err == nil {
		mediaHandler.GetLatestNews(c, mediaID)
	} else {
		c.Error(errors.New("mediaID is nil!"))
	}
}

// AuthMiddleware intercepts the requests, and check for a valid jwt token
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get the client secret key
		// err := jwtMiddleWare.CheckJWT(c.Writer, c.Request)
		// if err != nil {
		// 	// Token not found
		// 	fmt.Println(err)
		// 	c.Abort()
		// 	c.Writer.WriteHeader(http.StatusUnauthorized)
		// 	c.Writer.Write([]byte("Unauthorized"))
		// 	return
		// }
	}
}

func LoadConfig(path string) error {
	if !utils.Exists(path) {
		fmt.Println("can't find config.json from assets_path!")
		return errors.New("can't find config.json from assets_path!")
	}
	jsonFile, err := os.Open(path)
	if err != nil {
		fmt.Println(err)
		return err
	}
	defer jsonFile.Close()
	byteValue, _ := ioutil.ReadAll(jsonFile)
	err = json.Unmarshal(byteValue, &config)
	if err != nil {
		return err
	}
	mediaHandler = media.MediaHandler{DataPath: config.DataPath, Newsmedia: config.Newsmedia}
	fmt.Println("Successfully Opened config.json:", config)
	return nil
}
