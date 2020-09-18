# NeteaseCloudMusicDownloader
下载网易云音乐歌单到本地

> 仅用作学习交流
## How to use

- 先在网页端抓到 `https://music.163.com/weapi/v6/playlist/detail` 的返回 json，保存在 `playlist.json` 中，并把 json 文件放在与脚本相同的目录下
- 执行脚本
```shell
$ ruby download_playlist.rb
```
- 在 `Download Music` 目录下查看下载结果
