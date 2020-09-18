require 'net/http'
require 'uri'
require 'json'
require 'fileutils'
require 'pathname'

def download (id, file_path)
    uri = URI("http://music.163.com/song/media/outer/url?id=#{id}.mp3")
    request = Net::HTTP::Get.new(uri)

    Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.request request
        file_location = response['Location']
        save_file file_location, file_path
    end
end

def save_file(from_url, to_path)
    uri = URI(from_url)
    request = Net::HTTP::Get.new(uri)
    Net::HTTP.start(uri.host, uri.port) do |http|
        http.request request do |response|
            open to_path, 'w' do |io|
                response.read_body do |chunk|
                    io.write chunk
                end
            end
        end
    end
end

# playlist.json 即是 https://music.163.com/weapi/v6/playlist/detail 接口的返回，在浏览器上手动抓一下
file = File.open 'playlist.json'
data = JSON.load file
tracks = data['playlist']['tracks']
tracks.each do |track|
    id = track['id']
    name = track['name']
    artist = track['ar'].reduce('') do |artist_name, ar|
        if artist_name.empty?
            artist_name = ar['name']
        else
            artist_name = artist_name + '&' + n['name']
        end
    end
    file_name = name + ' - ' + artist + '.mp3'
    dir_name = 'Download Music'
    file_path = dir_name + '/' + file_name.gsub('/', ' ')
    FileUtils.mkdir dir_name unless Pathname(dir_name).exist?
    download id, file_path
end