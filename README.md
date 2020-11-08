# NeteaseCloudMusicDownloader
下载网易云音乐歌单到本地，包括歌曲、专辑封面和歌词。相关文章在[这里](https://juejin.im/post/6874440262609797128)。

> 仅用作学习交流
## How to use

- 先在网页端歌单页面端抓到 `https://music.163.com/weapi/v6/playlist/detail` 的返回 json，保存在 `playlist.json` 中，并把 json 文件放在与脚本相同的目录下
- 执行脚本
```shell
$ ruby download_playlist.rb
```
- 在 `Download Music` 目录下查看下载结果
