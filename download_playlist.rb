require 'net/http'
require 'uri'
require 'json'
require 'fileutils'
require 'pathname'
require 'date'

def download_music (id, file_path)
    uri = URI "http://music.163.com/song/media/outer/url?id=#{id}.mp3"

    request = Net::HTTP::Get.new(uri)
    Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.request request
        file_location = response['Location']
        save_file file_location, file_path
    end
end

def save_file (from_url, to_path)
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

def download_lyric (id, file_path)
    uri = URI "http://music.163.com/api/song/media?id=#{id}"

    response = Net::HTTP.get uri

    json = JSON.parse response
    lyric = json['lyric']
    return if lyric.nil?
    file = File.open file_path, 'w'
    file << process_lyric(json['lyric'])
    file.close
end

def save_music_info (info, file_path)
    file = File.open file_path, 'w'
    file.puts(JSON.pretty_generate(info))
    file.close
end

def process_lyric (lyrics)
    lyrics.lines.map do |line|
        line = line.lstrip
        if line =~ /^\[[a-z_]+:/
            next ''
        end
        (line.gsub /^(\[[0-9\.:]*\])*/, '').lstrip
    end.reject do |line|
        line.empty?
    end.join ''
end

begin
    file = File.open 'playlist.json'
rescue Exception => ex
    puts '未能找到 playlist.json，请先在网页端抓取 https://music.163.com/weapi/v6/playlist/detail 的返回结果，并保存到 playlist.json 中'
    exit 0
end
data = JSON.load file
tracks = data['playlist']['tracks']
tracks.each do |track|
    id = track['id']
    name = track['name']
    artist = track['ar'].reduce('') do |artist_name, ar|
        if artist_name.empty?
            artist_name = ar['name']
        else
            artist_name = artist_name + '&' + ar['name']
        end
    end
    pic = track['al']['picUrl']
    file_name = (name + ' - ' + artist).gsub('/', ' ')
    date = Date.strptime(track['publishTime'].to_s, '%Q') unless track['publishTime'] == 0
    info = {
        'album' => track['al']['name'],
        'title' => name,
        'artist' => artist,
        'alias' => track['alia'].first,
        'year' => date.nil? ? nil : date.year,
    }
    dir_name = 'Download Music'
    file_path = dir_name + '/' + file_name + '.mp3'
    pic_path = dir_name + '/' + file_name + '.jpg'
    lyric_path = dir_name + '/' + file_name + '.txt'
    info_path = dir_name + '/' + file_name + ' - info' + '.json'
    FileUtils.mkdir dir_name unless Pathname(dir_name).exist?
    puts "#{file_name} Downloading..."
    download_music id, file_path
    save_file pic, pic_path
    download_lyric id, lyric_path
    save_music_info info, info_path
    puts "#{file_name} Success"
end