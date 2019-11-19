package utils

import (
	"errors"
	"io/ioutil"
	"strconv"
	"strings"
	"unicode/utf8"

	"github.com/henrylee2cn/pholcus/logs"
)

/*Array2String join all the str in strArrays
 * @param {type}
 * @return:
 */
func Array2String(strArrays []string) string {
	var strBuilder strings.Builder
	for _, str := range strArrays {
		strBuilder.WriteString(str)
		strBuilder.WriteString("\n")
	}
	return strings.Trim(strBuilder.String(), "\n")
}

/*Minimum return the minimum value*/
func Minimum(first interface{}, rest ...interface{}) interface{} {
	minimum := first

	for _, v := range rest {
		switch v.(type) {
		case int:
			if v := v.(int); v < minimum.(int) {
				minimum = v
			}
		case float64:
			if v := v.(float64); v < minimum.(float64) {
				minimum = v
			}
		case string:
			if v := v.(string); v < minimum.(string) {
				minimum = v
			}
		}
	}
	return minimum
}

/*SplitSpeaker 如果是以 SB: 形式开头，则：前面是讲述人*/
func SplitSpeaker(paragrap string) (content string, speaker string) {
	//SOMEBODYNAME: 类型
	colonIndex := strings.Index(paragrap, ":")
	if colonIndex < 0 {
		return paragrap, ""
	}
	lowerIndex := strings.IndexFunc(paragrap[:colonIndex], func(r rune) bool {
		ascii := int(rune(r))
		return ascii >= 97 && ascii <= 122
	})
	if lowerIndex < 0 {
		content = paragrap[colonIndex+1:]
		content = strings.Trim(content, " \n")
		speaker = paragrap[:colonIndex+1]
	} else {
		content = paragrap
	}
	return
}

/*IndexOfAny str中是否包含seps中的任何一个*/
func IndexOfAny(str string, seps []string) int {
	index := -1
	for _, sep := range seps {
		currentIndex := strings.Index(str, sep)
		if currentIndex == -1 {
			continue
		}
		if index == -1 {
			index = currentIndex
		} else {
			index = Minimum(index, currentIndex).(int)
		}
	}
	return index
}

/*RemoveParentheses 去除（）中的话，一般是旁白*/
func RemoveParentheses(str string) string {
	indexLeft := strings.Index(str, "(")
	if indexLeft < 0 {
		return str
	}
	indexRight := strings.Index(str, ")")
	if indexRight > indexLeft {
		leftStr := str[:indexLeft]
		rightStr := str[indexRight+1:]
		//去除)后的.
		if strings.HasPrefix(rightStr, ".") || strings.HasPrefix(rightStr, ",") {
			rightStr = rightStr[1:]
		}
		return RemoveParentheses(leftStr + rightStr)
	}
	return str
}

/*SplitParagraph 把段落按句分行*/
func SplitParagraph(paragraph string) []string {
	var sentences []string
	paragraph = strings.Trim(paragraph, " \n")
	paragraph = RemoveParentheses(paragraph)
	for utf8.RuneCountInString(paragraph) > 0 {
		spliterIndex := 0
		//长度过小 可能是人名中的. 不需分段
		for spliterIndex < 10 {
			stringTmp := paragraph[spliterIndex:]
			spliterIndexTemp := IndexOfAny(stringTmp, []string{". ", ","})
			if spliterIndexTemp >= 0 {
				spliterIndex += spliterIndexTemp + 1
			} else {
				//已经搜索到了结尾
				spliterIndex = -1
				break
			}
		}

		if spliterIndex < 10 {
			//已经搜索到了结尾
			sentences = append(sentences, paragraph)
			break
		}
		sentences = append(sentences, paragraph[:spliterIndex])
		paragraph = paragraph[spliterIndex:]
	}
	return sentences
}

/*SplitTranscript 把文章按句分行，方便语音同步*/
func SplitTranscript(transcript string) ([]string, []string, error) {
	var sentences []string
	var speakers []string
	if utf8.RuneCountInString(transcript) <= 0 {
		return sentences, speakers, errors.New("transcript is nil!")
	}
	// var strBuilder strings.Builder
	paragraphs := strings.Split(transcript, "\n")
	for _, paragraph := range paragraphs {
		paragraph = strings.Trim(paragraph, " \n")
		if utf8.RuneCountInString(paragraph) <= 0 {
			continue
		}
		content, speaker := SplitSpeaker(paragraph)
		if utf8.RuneCountInString(speaker) > 0 {
			speakers = append(speakers, strconv.Itoa(len(sentences))+" "+speaker)
		}
		if utf8.RuneCountInString(content) > 0 {
			sentencesOfPara := SplitParagraph(content)
			if len(sentencesOfPara) > 0 {
				sentences = append(sentences, sentencesOfPara...)
			}
		}
	}
	return sentences, speakers, nil
}

/*SplitTranscriptAndSave 拆分文稿并保存 */
func SplitTranscriptAndSave(transcript string, mp3Name string, fileDir string) {
	if utf8.RuneCountInString(mp3Name) < 5 {
		return
	}
	filename := fileDir + mp3Name[:utf8.RuneCountInString(mp3Name)-4]
	if utf8.RuneCountInString(transcript) > 0 {
		transcrisptFile := filename + ".transcript"
		err := ioutil.WriteFile(transcrisptFile, []byte(transcript), 0644)
		if err != nil {
			logs.Log.Alert("error:write transcrisptFile: " + err.Error())
		}
	} else {
		return
	}
	//每句每行处理 文稿，为了对齐音频
	sentences, speakers, err := SplitTranscript(transcript)
	transcript2Align := Array2String(sentences)
	speakers2Align := Array2String(speakers)
	if err != nil {
		logs.Log.Error(err.Error())
	}
	if utf8.RuneCountInString(transcript2Align) > 0 {
		splittedTranscript := filename + ".2align"
		err = ioutil.WriteFile(splittedTranscript, []byte(transcript2Align), 0644)
		if err != nil {
			logs.Log.Alert("error:write splittedTranscript: " + err.Error())
		}
	}
	if utf8.RuneCountInString(speakers2Align) > 0 {
		speakerFile := filename + ".speaker"
		err = ioutil.WriteFile(speakerFile, []byte(speakers2Align), 0644)
		if err != nil {
			logs.Log.Alert("error:write transcrisptFile: " + err.Error())
		}
	}
}
