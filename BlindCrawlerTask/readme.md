
安装FFmpeg eSpeak
apt install ffmpeg
安装 espeak-1.48.04 
依赖 aeneas portaudio（Gcc5以上报错，改代码报错的地方加（char）强转）

pip install numpy
pip install aeneas

添加定时任务
30 16 * * * cd /home/kaka/run/crawler && ./BlindCrawlerTask -c_spider=0 -outpath=/home/kaka/operation/crawled/
30 5 * * * cd /home/kaka/run/crawler && ./BlindCrawlerTask -c_spider=1 -outpath=/home/kaka/operation/crawled/

启动服务器 默认8000端口
nohup ./server &
