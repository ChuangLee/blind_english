package main

import (
	"bytes"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"time"
	"unicode/utf8"

	logging "github.com/op/go-logging"
)

var log = logging.MustGetLogger("example")

var format = logging.MustStringFormatter(
	`%{color}%{time:15:04:05.000} %{shortfunc} > %{level:.4s} %{id:03x}%{color:reset} %{message}`,
)
var logPath = "logs/"

var crawledSavePath = "thingsCrawled/"
var crawledPath = "pholcus_pkg/text_out/"
var crawledFilesPath = "pholcus_pkg/file_out/"

func main() {
	os.MkdirAll(logPath, os.ModePerm)
	dateStr := time.Now().Format("2006-01-02")
	logFile, err := os.OpenFile(logPath+dateStr+".log", os.O_CREATE|os.O_APPEND|os.O_RDWR, 0666)
	if err != nil {
		fmt.Println(err)
	}
	backendFile := logging.NewLogBackend(logFile, "", 0)
	backendFileLeveled := logging.AddModuleLevel(backendFile)
	backendFileLeveled.SetLevel(logging.INFO, "")
	//暂时不向系统日志输出
	// backend2 := logging.NewLogBackend(os.Stderr, "", 0)
	// backend2Formatter := logging.NewBackendFormatter(backend2, format)
	// logging.SetBackend(backend1Leveled, backend2Formatter)
	logging.SetBackend(backendFileLeveled)
	log.Info("args:", os.Args)

	// outpath := flag.String("outpath", "thingsCrawled/", " 输出目录")
	// flag.Parse()
	args := os.Args
	argsPass := []string{}
	for _, arg := range args {
		if strings.HasPrefix(arg, "-outpath=") {
			crawledSavePath = strings.Replace(arg, "-outpath=", "", -1)
		} else if strings.Contains(arg, "=") {
			argsPass = append(argsPass, arg)
		}
	}

	os.MkdirAll(crawledSavePath, os.ModePerm)
	argsPass = append([]string{"-_ui=cmd", "-a_mode=0"}, argsPass...)
	fmt.Println(argsPass)
	// 重试3次
	trytime := 3
	for trytime > 0 {
		log.Info("try times:", 3-trytime)
		err = RunCrawler(argsPass, dateStr)
		if err != nil {
			log.Error(err)
			trytime--
			continue
		}
		trytime = -1
	}
	if trytime == -1 {

	}
}

func RunCrawler(args []string, dateStr string) error {
	ShellCmdTimeout(600, "./BlindCrawler", args...)
	// ShellCmdTimeout(600, "./BlindCrawler", "-_ui=cmd", "-c_spider=0,1", "-a_mode=0")
	if !Exists(crawledPath) {
		return errors.New("crawledPath does't exists!")
	}
	timeDirs, err := ioutil.ReadDir(crawledPath)
	if err != nil {
		log.Error(err)
		return err
	}
	if len(timeDirs) <= 0 {
		return errors.New("timeDirs does't exists!")
	}
	timeDir := timeDirs[len(timeDirs)-1].Name()
	timeDir = crawledPath + timeDir + "/"
	spiderDirs, err := ioutil.ReadDir(timeDir)
	if err != nil {
		log.Error(err)
	}
	if len(spiderDirs) <= 0 {
		//存在就说明抓取成功
		os.RemoveAll(crawledPath)
		return errors.New("there is dir_time, but spiderDir not exists!")
	}
	for _, fi := range spiderDirs {
		if fi.IsDir() {
			spiderDir := fi.Name()
			crawledSaveName := strings.Split(spiderDir, "__")[0]
			savedPath := crawledSavePath + crawledSaveName + "/" + dateStr + "/"
			os.MkdirAll(savedPath, os.ModePerm)
			err = CopyDir(crawledFilesPath+crawledSaveName, savedPath)
			if err != nil {
				log.Error(err)
			}
			err = CopyDir(timeDir+spiderDir, savedPath)
			if err != nil {
				log.Error(err)
			}
			err = AlignAudio(savedPath)
			if err != nil {
				log.Error(err)
			}
		}
	}
	os.RemoveAll(crawledFilesPath)
	os.RemoveAll(crawledPath)
	return nil
}

//对齐音频和文稿，使用aeneas
func AlignAudio(savedPath string) error {
	//python -m aeneas.tools.execute_task path_name.mp3  ./text.txt  "task_language=eng|is_text_type=plain|os_task_file_format=aud" output/my.aud
	err := filepath.Walk(savedPath, func(path string, f os.FileInfo, err error) error {
		if f == nil {
			return nil
		}
		filename := f.Name()
		if strings.HasSuffix(filename, ".2align") {
			nameNoSuffix := filename[:utf8.RuneCountInString(filename)-7]
			mp3name := savedPath + nameNoSuffix + ".mp3"
			outputName := savedPath + nameNoSuffix + ".aud"
			filename = savedPath + filename
			// shellString := "python -m aeneas.tools.execute_task " + mp3name + " " + filename + " \"task_language=eng|is_text_type=plain|os_task_file_format=aud\" " + outputName
			// log.Info(shellString)
			args_aeneas := []string{
				"-m",
				"aeneas.tools.execute_task",
				mp3name,
				filename,
				"task_language=eng|is_text_type=plain|os_task_file_format=aud",
				outputName,
			}
			ShellCmdTimeout(60, "python", args_aeneas...)
		}
		return nil
	})
	if err != nil {
		return err
	}
	return nil
}

//copy 文件夹下所有文件到指定目录，不包含当前文件夹
func CopyFiles(dirPath string, destDirPath string) error {
	err := filepath.Walk(dirPath, func(path string, f os.FileInfo, err error) error {
		if !f.IsDir() {
			copyFile(path, destDirPath+"/"+f.Name())
		}
		return nil
	})
	if err != nil {
		return err
	}
	return nil
}

/**
 * 拷贝文件夹,同时拷贝文件夹中的文件
 * @param srcPath  		需要拷贝的文件夹路径: D:/test
 * @param destPath		拷贝到的位置: D/backup/
 */
func CopyDir(srcPath string, destPath string) error {
	//检测目录正确性
	if srcInfo, err := os.Stat(srcPath); err != nil {
		log.Error(err)
		return err
	} else {
		if !srcInfo.IsDir() {
			e := errors.New(srcPath + ":srcPath不是一个正确的目录！")
			log.Error(err)
			return e
		}
	}
	if destInfo, err := os.Stat(destPath); err != nil {
		fmt.Println(err.Error())
		return err
	} else {
		if !destInfo.IsDir() {
			e := errors.New(destPath + ":destInfo不是一个正确的目录！")
			log.Error(err)
			return e
		}
	}

	err := filepath.Walk(srcPath, func(path string, f os.FileInfo, err error) error {
		if f == nil {
			return err
		}
		if !f.IsDir() {
			path := strings.Replace(path, "\\", "/", -1)
			destNewPath := strings.Replace(path, srcPath, destPath, -1)
			// fmt.Println("复制文件:" + path + " 到 " + destNewPath)
			copyFile(path, destNewPath)
		}
		return nil
	})
	if err != nil {
		fmt.Printf(err.Error())
	}
	return err
}

//生成目录并拷贝文件
func copyFile(src, dest string) (w int64, err error) {
	srcFile, err := os.Open(src)
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	defer srcFile.Close()
	//分割path目录
	destSplitPathDirs := strings.Split(dest, "/")

	//检测是否存在目录
	destSplitPath := ""
	for index, dir := range destSplitPathDirs {
		if index < len(destSplitPathDirs)-1 {
			destSplitPath = destSplitPath + dir + "/"
			b, _ := pathExists(destSplitPath)
			if b == false {
				fmt.Println("创建目录:" + destSplitPath)
				//创建目录
				err := os.Mkdir(destSplitPath, os.ModePerm)
				if err != nil {
					fmt.Println(err)
				}
			}
		}
	}
	dstFile, err := os.Create(dest)
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	defer dstFile.Close()
	return io.Copy(dstFile, srcFile)
}

//检测文件夹路径是否存在
func pathExists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil {
		return true, nil
	}
	if os.IsNotExist(err) {
		return false, nil
	}
	return false, err
}

//获取指定目录下的所有文件和目录
func GetFilesAndDirs(dirPth string) (files []string, dirs []string, err error) {
	dir, err := ioutil.ReadDir(dirPth)
	if err != nil {
		return nil, nil, err
	}

	PthSep := string(os.PathSeparator)
	//suffix = strings.ToUpper(suffix) //忽略后缀匹配的大小写

	for _, fi := range dir {
		if fi.IsDir() { // 目录, 递归遍历
			dirs = append(dirs, dirPth+PthSep+fi.Name())
			GetFilesAndDirs(dirPth + PthSep + fi.Name())
		} else {
			// 过滤指定格式
			ok := strings.HasSuffix(fi.Name(), ".go")
			if ok {
				files = append(files, dirPth+PthSep+fi.Name())
			}
		}
	}

	return files, dirs, nil
}

// 判断所给路径文件/文件夹是否存在
func Exists(path string) bool {
	_, err := os.Stat(path) //os.Stat获取文件信息
	if err != nil {
		if os.IsExist(err) {
			return true
		}
		return false
	}
	return true
}

// 删除输出的\x00和多余的空格
func trimOutput(buffer bytes.Buffer) string {
	return strings.TrimSpace(string(bytes.TrimRight(buffer.Bytes(), "\x00")))
}

// 实时打印输出
func traceOutput(out *bytes.Buffer) {
	offset := 0
	t := time.NewTicker(time.Second)
	defer t.Stop()
	for {
		<-t.C
		result := bytes.TrimRight((*out).Bytes(), "\x00")
		size := len(result)
		if size == 0 {
			continue
		}
		rows := bytes.Split(bytes.TrimSpace(result), []byte{'\n'})
		nRows := len(rows)
		newRows := rows[offset:nRows]
		if result[size-1] != '\n' {
			newRows = rows[offset : nRows-1]
		}
		if len(newRows) < offset {
			continue
		}
		for _, row := range newRows {
			log.Info(string(row))
		}
		offset += len(newRows)
	}
}

// 运行Shell命令，设定超时时间（秒）
func ShellCmdTimeout(timeout int, cmd string, args ...string) (stdout, stderr string, e error) {
	if len(cmd) == 0 {
		e = fmt.Errorf("cannot run a empty command")
		return
	}
	var out, err bytes.Buffer
	command := exec.Command(cmd, args...)
	command.Stdout = &out
	command.Stderr = &err
	command.Start()
	// 启动routine等待结束
	done := make(chan error)
	go func() { done <- command.Wait() }()
	// 启动routine持续打印输出
	// go traceOutput(&out)
	// 设定超时时间，并select它
	after := time.After(time.Duration(timeout) * time.Second)
	select {
	case <-after:
		command.Process.Signal(syscall.SIGINT)
		time.Sleep(time.Second)
		command.Process.Kill()
		log.Error("运行命令（%s）超时，超时设定：%v 秒。",
			fmt.Sprintf(`%s %s`, cmd, strings.Join(args, " ")), timeout)
	case <-done:
	}
	stdout = trimOutput(out)
	log.Info(stdout)
	stderr = trimOutput(err)
	if stderr != "" {
		log.Error(stderr)
	}

	return
}
