package utils

import (
	"io/ioutil"
	"os"
	"sort"
)

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

type fileInfo []os.FileInfo

func (self fileInfo) Less(i, j int) bool {
	return self[i].ModTime().Unix() > self[j].ModTime().Unix()
}
func (self fileInfo) Len() int {
	return len(self)
}
func (self fileInfo) Swap(i, j int) {
	self[i], self[j] = self[j], self[i]
}

// dirs contained in the path, sorted by modification time
func ReadDirByTime(path string) ([]os.FileInfo, error) {
	list, err := ioutil.ReadDir(path)
	if err != nil {
		return nil, err
	}
	sort.Sort(fileInfo(list))
	return list, err
}
